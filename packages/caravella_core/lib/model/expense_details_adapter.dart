import 'package:hive/hive.dart';
import 'expense_details.dart';
import 'expense_category.dart';
import 'expense_participant.dart';
import 'expense_location.dart';

class ExpenseDetailsAdapter extends TypeAdapter<ExpenseDetails> {
  @override
  final int typeId = 3;

  @override
  ExpenseDetails read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExpenseDetails(
      id: fields[0] as String,
      category: fields[1] as ExpenseCategory,
      amount: fields[2] as double?,
      paidBy: fields[3] as ExpenseParticipant,
      date: fields[4] as DateTime,
      note: fields[5] as String?,
      name: fields[6] as String?,
      location: fields[7] as ExpenseLocation?,
    );
  }

  @override
  void write(BinaryWriter writer, ExpenseDetails obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.paidBy)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.note)
      ..writeByte(6)
      ..write(obj.name)
      ..writeByte(7)
      ..write(obj.location);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseDetailsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
