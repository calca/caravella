import 'package:caravella_core/caravella_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

/// Wraps [GoogleSignIn] for the `drive.appdata` scope and bridges an
/// authenticated [GoogleSignInAccount] into an `http.Client` usable by
/// `googleapis`'s generated [drive.DriveApi] client.
///
/// The iOS OAuth client ID is optional here: pass it via
/// [GoogleDriveAuthService.new] when building for iOS (see
/// `docs/GOOGLE_DRIVE_SYNC_SETUP.md`). Android needs no client ID in code —
/// it's resolved from the OAuth Android client registered against the
/// app's package name + signing certificate SHA-1 in Google Cloud Console.
class GoogleDriveAuthService {
  static const _tag = 'sync.channel.cloud.auth';

  /// Drive scope: a hidden, per-app folder invisible in the user's normal
  /// Drive UI and inaccessible to other apps — the intended scope for
  /// app-private sync data (see the setup guide's "Which scope" section).
  static const List<String> scopes = [drive.DriveApi.driveAppdataScope];

  final GoogleSignIn _googleSignIn;

  GoogleDriveAuthService({String? iosClientId})
      : _googleSignIn = GoogleSignIn(
          scopes: scopes,
          clientId: iosClientId,
        );

  /// The currently signed-in account, if any (in-memory only — call
  /// [signInSilently] after process restart to restore a prior session).
  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  /// Attempts to restore a previous sign-in session without UI.
  Future<GoogleSignInAccount?> signInSilently() async {
    try {
      return await _googleSignIn.signInSilently();
    } catch (e, st) {
      LoggerService.warning(
        'Silent sign-in failed',
        name: _tag,
      );
      LoggerService.debug('$e\n$st', name: _tag);
      return null;
    }
  }

  /// Shows the Google sign-in UI. Returns `null` if the user cancels.
  Future<GoogleSignInAccount?> signIn() async {
    try {
      return await _googleSignIn.signIn();
    } catch (e, st) {
      LoggerService.error(
        'Sign-in failed',
        name: _tag,
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  /// Signs out and revokes the local session (Drive access is not revoked
  /// server-side — the user can do that from their Google Account settings).
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    LoggerService.info('Signed out of Google Drive sync', name: _tag);
  }

  /// Returns an authenticated `http.Client` for the current session,
  /// signing in silently first if needed. Returns `null` if no session
  /// could be established (never signed in, or the user revoked access).
  Future<http.Client?> authenticatedClient() async {
    final account = currentUser ?? await signInSilently();
    if (account == null) return null;

    final headers = await account.authHeaders;
    return _GoogleAuthClient(headers);
  }
}

/// Injects Google OAuth headers into every request — the documented pattern
/// for using `google_sign_in` with `googleapis`'s generated clients.
class _GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _inner = http.Client();

  _GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
