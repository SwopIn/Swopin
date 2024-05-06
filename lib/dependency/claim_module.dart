import '../data/claim/daily_claim_repository.dart';

class ClaimModule {
  static DailyClaimRepository? _repository;

  static DailyClaimRepository claimRepository() {
    _repository ??= DailyClaim();
    return _repository!;
  }
}