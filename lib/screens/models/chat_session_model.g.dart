part of 'chat_session_model.dart';


class ChatSessionAdapter extends TypeAdapter<ChatSession> {
  @override
  final int typeId = 1;

  @override
  ChatSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++)
        reader.readByte(): reader.read(),
    };

    return ChatSession(
      sessionId: fields[0] as String,
      title: fields[1] as String,
      createdAt: fields[2] as DateTime,
      messages: (fields[3] as List).cast<MessageModel>(),
      learningSummary: fields[4] as String? ?? "",
      projectName: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ChatSession obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.sessionId)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.messages)
      ..writeByte(4)
      ..write(obj.learningSummary)
      ..writeByte(5)
      ..write(obj.projectName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ChatSessionAdapter &&
              runtimeType == other.runtimeType &&
              typeId == other.typeId;
}
