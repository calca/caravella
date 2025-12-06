import 'package:hive/hive.dart';
import 'expense_group.dart';
import 'expense_details.dart';
import 'expense_participant.dart';
import 'expense_category.dart';

class ExpenseGroupAdapter extends TypeAdapter<ExpenseGroup> {
  @override
  final int typeId = 4;

  @override
  ExpenseGroup read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExpenseGroup(
      id: fields[0] as String,
      title: fields[1] as String,
      expenses: (fields[2] as List).cast<ExpenseDetails>(),
      participants: (fields[3] as List).cast<ExpenseParticipant>(),
      startDate: fields[4] as DateTime?,
      endDate: fields[5] as DateTime?,
      currency: fields[6] as String,
      categories: (fields[7] as List).cast<ExpenseCategory>(),
      timestamp: fields[8] as DateTime,
      pinned: fields[9] as bool,
      archived: fields[10] as bool,
      file: fields[11] as String?,
      color: fields[12] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, ExpenseGroup obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.expenses)
      ..writeByte(3)
      ..write(obj.participants)
      ..writeByte(4)
      ..write(obj.startDate)
      ..writeByte(5)
      ..write(obj.endDate)
      ..writeByte(6)
      ..write(obj.currency)
      ..writeByte(7)
      ..write(obj.categories)
      ..writeByte(8)
      ..write(obj.timestamp)
      ..writeByte(9)
      ..write(obj.pinned)
      ..writeByte(10)
      ..write(obj.archived)
      ..writeByte(11)
      ..write(obj.file)
      ..writeByte(12)
      ..write(obj.color);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseGroupAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
