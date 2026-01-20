/// Storage-related error types for better error handling and debugging
abstract class StorageError implements Exception {
  final String message;
  final String? details;
  final Exception? cause;

  const StorageError(this.message, {this.details, this.cause});

  @override
  String toString() {
    if (details != null) {
      return '$runtimeType: $message - $details';
    }
    return '$runtimeType: $message';
  }
}

/// Thrown when a file operation fails (read, write, delete)
class FileOperationError extends StorageError {
  const FileOperationError(super.message, {super.details, super.cause});
}

/// Thrown when JSON serialization/deserialization fails
class SerializationError extends StorageError {
  const SerializationError(super.message, {super.details, super.cause});
}

/// Thrown when data validation fails
class ValidationError extends StorageError {
  final Map<String, String>? fieldErrors;

  const ValidationError(
    super.message, {
    this.fieldErrors,
    super.details,
    super.cause,
  });

  @override
  String toString() {
    if (fieldErrors != null && fieldErrors!.isNotEmpty) {
      final errors = fieldErrors!.entries
          .map((e) => '${e.key}: ${e.value}')
          .join(', ');
      return '$runtimeType: $message - Field errors: $errors';
    }
    return super.toString();
  }
}

/// Thrown when a requested entity is not found
class EntityNotFoundError extends StorageError {
  final String entityType;
  final String entityId;

  const EntityNotFoundError(this.entityType, this.entityId)
    : super('$entityType with id "$entityId" not found');
}

/// Thrown when a data integrity constraint is violated
class DataIntegrityError extends StorageError {
  const DataIntegrityError(super.message, {super.details, super.cause});
}

/// Thrown when concurrent modification occurs
class ConcurrentModificationError extends StorageError {
  const ConcurrentModificationError(
    super.message, {
    super.details,
    super.cause,
  });
}
