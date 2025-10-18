import 'package:flutter_test/flutter_test.dart';
import 'package:org_app_caravella/data/participant_service.dart';
import 'package:org_app_caravella/data/model/expense_participant.dart';
import 'package:org_app_caravella/data/model/expense_group.dart';
import 'package:org_app_caravella/data/model/expense_category.dart';
import 'package:org_app_caravella/data/expense_group_repository.dart';
import 'package:org_app_caravella/data/storage_errors.dart';

// Mock repository for testing
class MockExpenseGroupRepository implements IExpenseGroupRepository {
  final List<ExpenseParticipant> _mockParticipants;
  
  MockExpenseGroupRepository(this._mockParticipants);

  @override
  Future<StorageResult<List<ExpenseParticipant>>> getAllParticipants() async {
    return StorageResult.success(_mockParticipants);
  }

  @override
  Future<StorageResult<List<ExpenseParticipant>>> searchParticipants(String query) async {
    final lowerQuery = query.toLowerCase();
    final filtered = _mockParticipants
        .where((p) => p.name.toLowerCase().contains(lowerQuery))
        .toList();
    return StorageResult.success(filtered);
  }

  // Implement other required methods with minimal implementations
  @override
  Future<StorageResult<List<ExpenseGroup>>> getAllGroups() async => StorageResult.success([]);
  
  @override
  Future<StorageResult<List<ExpenseGroup>>> getActiveGroups() async => StorageResult.success([]);
  
  @override
  Future<StorageResult<List<ExpenseGroup>>> getArchivedGroups() async => StorageResult.success([]);
  
  @override
  Future<StorageResult<ExpenseGroup?>> getGroup(String id) async => StorageResult.success(null);
  
  @override
  Future<StorageResult<void>> saveGroup(ExpenseGroup group) async => StorageResult.success(null);
  
  @override
  Future<StorageResult<void>> deleteGroup(String id) async => StorageResult.success(null);
  
  @override
  Future<StorageResult<void>> saveGroups(List<ExpenseGroup> groups) async => StorageResult.success(null);
  
  @override
  Future<StorageResult<void>> archiveGroup(String id) async => StorageResult.success(null);
  
  @override
  Future<StorageResult<void>> unarchiveGroup(String id) async => StorageResult.success(null);
  
  @override
  Future<StorageResult<void>> pinGroup(String id) async => StorageResult.success(null);
  
  @override
  Future<StorageResult<void>> unpinGroup(String id) async => StorageResult.success(null);
  
  @override
  StorageResult<void> validateGroup(ExpenseGroup group) => StorageResult.success(null);
  
  @override
  Future<StorageResult<List<String>>> checkDataIntegrity() async => StorageResult.success([]);
  
  @override
  Future<StorageResult<List<ExpenseCategory>>> getAllCategories() async => StorageResult.success([]);
  
  @override
  Future<StorageResult<List<ExpenseCategory>>> searchCategories(String query) async => StorageResult.success([]);
}

void main() {
  group('ParticipantService Tests', () {
    late ParticipantService participantService;
    late List<ExpenseParticipant> mockParticipants;

    setUp(() {
      mockParticipants = [
        ExpenseParticipant(
          id: '1',
          name: 'Alice',
          createdAt: DateTime(2024, 1, 1),
        ),
        ExpenseParticipant(
          id: '2', 
          name: 'Bob',
          createdAt: DateTime(2024, 1, 2),
        ),
        ExpenseParticipant(
          id: '3',
          name: 'Alice', // Duplicate name with different ID
          createdAt: DateTime(2024, 1, 3), // More recent
        ),
        ExpenseParticipant(
          id: '4',
          name: 'Charlie',
          createdAt: DateTime(2024, 1, 4),
        ),
      ];
      
      final mockRepository = MockExpenseGroupRepository(mockParticipants);
      participantService = ParticipantService(mockRepository);
    });

    test('getAllParticipants should return deduplicated participants', () async {
      final participants = await participantService.getAllParticipants();
      
      // Should deduplicate by name (case-insensitive) and keep most recent
      expect(participants.length, equals(3)); // Alice, Bob, Charlie
      
      // Should keep the more recent Alice (id: 3)
      final alice = participants.firstWhere((p) => p.name == 'Alice');
      expect(alice.id, equals('3'));
      expect(alice.createdAt, equals(DateTime(2024, 1, 3)));
    });

    test('searchParticipants should return filtered participants', () async {
      final results = await participantService.searchParticipants('al');
      
      // Should find Alice (case-insensitive)
      expect(results.length, equals(1));
      expect(results.first.name, equals('Alice'));
    });

    test('getParticipantSuggestions should prioritize exact matches', () async {
      final suggestions = await participantService.getParticipantSuggestions('Alice');
      
      // Should return exact match first
      expect(suggestions.isNotEmpty, isTrue);
      expect(suggestions.first.name, equals('Alice'));
    });

    test('findParticipantByName should find existing participant', () async {
      final found = await participantService.findParticipantByName('alice'); // case-insensitive
      
      expect(found, isNotNull);
      expect(found!.name, equals('Alice'));
      expect(found.id, equals('3')); // Should find the most recent one
    });

    test('createOrReuseParticipant should reuse UUID for existing name', () async {
      final participant = await participantService.createOrReuseParticipant('Alice');
      
      // Should reuse existing UUID
      expect(participant.id, equals('3'));
      expect(participant.name, equals('Alice'));
    });

    test('createOrReuseParticipant should create new UUID for new name', () async {
      final participant = await participantService.createOrReuseParticipant('David');
      
      // Should create new UUID (not '1', '2', '3', or '4')
      expect(['1', '2', '3', '4'].contains(participant.id), isFalse);
      expect(participant.name, equals('David'));
    });

    test('cache should be invalidated after invalidateCache call', () {
      participantService.invalidateCache();
      
      expect(participantService.hasCachedParticipants, isFalse);
      expect(participantService.cachedParticipantCount, equals(0));
    });
  });
}