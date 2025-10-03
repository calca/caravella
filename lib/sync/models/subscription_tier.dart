/// Subscription tier model for RevenueCat
enum SubscriptionTier {
  none,
  basic,
  premium,
}

/// Subscription limits configuration
class SubscriptionLimits {
  final int maxParticipantsPerGroup;
  final int maxSharedGroups;
  final bool unlimitedGroups;
  final bool unlimitedParticipants;

  const SubscriptionLimits({
    required this.maxParticipantsPerGroup,
    required this.maxSharedGroups,
    required this.unlimitedGroups,
    required this.unlimitedParticipants,
  });

  /// Get limits for a subscription tier
  static SubscriptionLimits forTier(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.none:
        return const SubscriptionLimits(
          maxParticipantsPerGroup: 0,
          maxSharedGroups: 0,
          unlimitedGroups: false,
          unlimitedParticipants: false,
        );
      case SubscriptionTier.basic:
        return const SubscriptionLimits(
          maxParticipantsPerGroup: 5,
          maxSharedGroups: 5,
          unlimitedGroups: false,
          unlimitedParticipants: false,
        );
      case SubscriptionTier.premium:
        return const SubscriptionLimits(
          maxParticipantsPerGroup: -1, // -1 = unlimited
          maxSharedGroups: -1, // -1 = unlimited
          unlimitedGroups: true,
          unlimitedParticipants: true,
        );
    }
  }

  /// Check if participant limit is reached
  bool isParticipantLimitReached(int currentCount) {
    if (unlimitedParticipants) return false;
    return currentCount >= maxParticipantsPerGroup;
  }

  /// Check if shared group limit is reached
  bool isGroupLimitReached(int currentCount) {
    if (unlimitedGroups) return false;
    return currentCount >= maxSharedGroups;
  }
}

/// Subscription status model
class SubscriptionStatus {
  final SubscriptionTier tier;
  final bool isActive;
  final DateTime? expirationDate;
  final String? productId;

  const SubscriptionStatus({
    required this.tier,
    required this.isActive,
    this.expirationDate,
    this.productId,
  });

  SubscriptionLimits get limits => SubscriptionLimits.forTier(tier);

  /// Check if user can share a group
  bool canShareGroup(int currentSharedGroupsCount) {
    if (!isActive) return false;
    return !limits.isGroupLimitReached(currentSharedGroupsCount);
  }

  /// Check if user can add participant to group
  bool canAddParticipant(int currentParticipantsCount) {
    if (!isActive) return false;
    return !limits.isParticipantLimitReached(currentParticipantsCount);
  }
}
