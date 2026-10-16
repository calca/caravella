import 'package:caravella_core/caravella_core.dart';
import 'package:in_app_review/in_app_review.dart';

/// [StoreReviewClient] backed by the Play In-App Review API.
class InAppReviewClient implements StoreReviewClient {
  const InAppReviewClient();

  InAppReview get _review => InAppReview.instance;

  @override
  Future<bool> isAvailable() => _review.isAvailable();

  @override
  Future<void> requestReview() => _review.requestReview();

  @override
  Future<void> openStoreListing() => _review.openStoreListing();
}
