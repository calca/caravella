import 'package:hive/hive.dart';
import 'expense_location.dart';

class ExpenseLocationAdapter extends TypeAdapter<ExpenseLocation> {
  @override
  final int typeId = 0;

  @override
  ExpenseLocation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExpenseLocation(
      latitude: fields[0] as double?,
      longitude: fields[1] as double?,
      address: fields[2] as String?,
      name: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ExpenseLocation obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.latitude)
      ..writeByte(1)
      ..write(obj.longitude)
      ..writeByte(2)
      ..write(obj.address)
      ..writeByte(3)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseLocationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
