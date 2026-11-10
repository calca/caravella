/// Data written by a newer version of the app, in a format this one can't
/// read without losing information: a sync delta (see
/// `DeltaBuilder.schemaVersion`) or a backup (see
/// `BackupArchive.formatVersion`). The fix is to update the app.
class NewerFormatException extends FormatException {
  /// The format version found in the data.
  final int version;

  NewerFormatException(String what, this.version)
    : super('$what format $version is newer than this app can read');
}
