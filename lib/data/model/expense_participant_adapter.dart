import 'package:hive/hive.dart';
import 'expense_participant.dart';

class ExpenseParticipantAdapter extends TypeAdapter<ExpenseParticipant> {
  @override
  final int typeId = 2;

  @override
  ExpenseParticipant read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExpenseParticipant(
      id: fields[0] as String,
      name: fields[1] as String,
      createdAt: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ExpenseParticipant obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseParticipantAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
