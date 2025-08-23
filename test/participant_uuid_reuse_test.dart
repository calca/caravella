// Comprehensive test for participant UUID reuse functionality
import 'package:flutter_test/flutter_test.dart';
import 'package:org_app_caravella/data/participant_service.dart';
import 'package:org_app_caravella/data/model/expense_participant.dart';
import 'package:org_app_caravella/data/expense_group_repository.dart';
import 'package:org_app_caravella/data/storage_errors.dart';

// Mock repository for testing UUID reuse
class MockExpenseGroupRepository implements IExpenseGroupRepository {
  final List<ExpenseParticipant> _participants = [
    ExpenseParticipant(
      id: 'uuid-alice-123',
      name: 'Alice',
      createdAt: DateTime(2024, 1, 1),
    ),
    ExpenseParticipant(
      id: 'uuid-bob-456',
      name: 'Bob',
      createdAt: DateTime(2024, 1, 2),
    ),
    ExpenseParticipant(
      id: 'uuid-alice-123', // Same UUID as Alice (case variation)
      name: 'alice', // lowercase
      createdAt: DateTime(2024, 1, 3),
    ),
  ];

  @override
  Future<StorageResult<List<ExpenseParticipant>>> getAllParticipants() async {
    return StorageResult.success(_participants);
  }

  @override
  Future<StorageResult<List<ExpenseParticipant>>> searchParticipants(String query) async {
    final lowerQuery = query.toLowerCase();
    final filtered = _participants
        .where((p) => p.name.toLowerCase().contains(lowerQuery))
        .toList();
    return StorageResult.success(filtered);
  }

  // Minimal implementations for other required methods
  @override
  Future<StorageResult<List<dynamic>>> getAllGroups() async => StorageResult.success([]);
  @override
  Future<StorageResult<List<dynamic>>> getActiveGroups() async => StorageResult.success([]);
  @override
  Future<StorageResult<List<dynamic>>> getArchivedGroups() async => StorageResult.success([]);
  @override
  Future<StorageResult<dynamic>> getGroup(String id) async => StorageResult.success(null);
  @override
  Future<StorageResult<void>> saveGroup(dynamic group) async => StorageResult.success(null);
  @override
  Future<StorageResult<void>> deleteGroup(String id) async => StorageResult.success(null);
  @override
  Future<StorageResult<void>> saveGroups(List<dynamic> groups) async => StorageResult.success(null);
  @override
  Future<StorageResult<List<dynamic>>> getAllCategories() async => StorageResult.success([]);
  @override
  Future<StorageResult<List<dynamic>>> searchCategories(String query) async => StorageResult.success([]);
}

void main() {
  group('Participant UUID Reuse Tests', () {
    late ParticipantService service;
    late MockExpenseGroupRepository repository;

    setUp(() {
      repository = MockExpenseGroupRepository();
      service = ParticipantService(repository);
    });

    test('should reuse UUID for existing participant (case-insensitive)', () async {
      // Test reusing UUID for 'Alice' when selecting 'alice'
      final participant = await service.createOrReuseParticipant('alice');
      
      expect(participant.id, equals('uuid-alice-123')); // Should reuse Alice's UUID
      expect(participant.name, equals('alice')); // Should preserve the input casing
    });

    test('should reuse UUID for existing participant (exact match)', () async {
      // Test reusing UUID for exact match
      final participant = await service.createOrReuseParticipant('Alice');
      
      expect(participant.id, equals('uuid-alice-123')); // Should reuse Alice's UUID
      expect(participant.name, equals('Alice')); // Should preserve the input casing
    });

    test('should create new participant for non-existing name', () async {
      // Test creating new participant for non-existing name
      final participant = await service.createOrReuseParticipant('Charlie');
      
      expect(participant.id, isNot(equals('uuid-alice-123'))); // Should have new UUID
      expect(participant.id, isNot(equals('uuid-bob-456'))); // Should have new UUID
      expect(participant.name, equals('Charlie'));
    });

    test('should find participant by name (case-insensitive)', () async {
      final aliceFound = await service.findParticipantByName('alice');
      final aliceExactFound = await service.findParticipantByName('Alice');
      final bobFound = await service.findParticipantByName('BOB');
      final charlieNotFound = await service.findParticipantByName('Charlie');

      expect(aliceFound, isNotNull);
      expect(aliceFound!.id, equals('uuid-alice-123'));
      
      expect(aliceExactFound, isNotNull);
      expect(aliceExactFound!.id, equals('uuid-alice-123'));
      
      expect(bobFound, isNotNull);
      expect(bobFound!.id, equals('uuid-bob-456'));
      
      expect(charlieNotFound, isNull);
    });

    test('should provide smart autocomplete suggestions', () async {
      final suggestions = await service.getParticipantSuggestions('al');
      
      expect(suggestions.length, equals(2)); // Alice and alice
      
      // Should prioritize exact matches first, then prefix matches
      expect(suggestions.first.name, equals('Alice')); // Prefix match should come first
    });

    test('should handle empty search query', () async {
      final suggestions = await service.getParticipantSuggestions('');
      
      expect(suggestions.length, equals(3)); // All participants
    });

    test('should cache participants correctly', () async {
      // First call
      final participants1 = await service.getAllParticipants();
      expect(service.hasCachedParticipants, isTrue);
      
      // Second call should use cache
      final participants2 = await service.getAllParticipants();
      expect(participants1, equals(participants2));
      
      // Cache invalidation
      service.invalidateCache();
      expect(service.hasCachedParticipants, isFalse);
    });
  });
}