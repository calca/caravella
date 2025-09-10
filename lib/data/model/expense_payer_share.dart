import 'expense_participant.dart';

/// Represents a single payer contribution for an expense.
/// The share is the absolute amount this participant paid.
class ExpensePayerShare {
  final ExpenseParticipant participant;
  final double share;

  const ExpensePayerShare({required this.participant, required this.share});

  factory ExpensePayerShare.fromJson(Map<String, dynamic> json) =>
      ExpensePayerShare(
        participant: ExpenseParticipant.fromJson(
          json['participant'] as Map<String, dynamic>,
        ),
        share: (json['share'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
    'participant': participant.toJson(),
    'share': share,
  };

  ExpensePayerShare copyWith({
    ExpenseParticipant? participant,
    double? share,
  }) => ExpensePayerShare(
    participant: participant ?? this.participant,
    share: share ?? this.share,
  );
}
