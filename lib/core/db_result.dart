// lib/core/db_result.dart

/// Standardized Database Result wrapper providing 3-tier feedback:
/// 1. Cloud Success (isSuccess: true, isOfflineQueued: false)
/// 2. Offline Queued (isSuccess: true, isOfflineQueued: true)
/// 3. Server Error (isSuccess: false, errorMessage: '...')
class DbResult {
  final bool isSuccess;
  final String? errorMessage;
  final bool isOfflineQueued;

  const DbResult.success()
      : isSuccess = true,
        errorMessage = null,
        isOfflineQueued = false;

  const DbResult.offline()
      : isSuccess = true,
        errorMessage = null,
        isOfflineQueued = true;

  const DbResult.failure(this.errorMessage)
      : isSuccess = false,
        isOfflineQueued = false;

  @override
  String toString() {
    if (isOfflineQueued) return 'DbResult.offline()';
    if (isSuccess) return 'DbResult.success()';
    return 'DbResult.failure($errorMessage)';
  }
}
