import 'package:hive/hive.dart';
import 'message_model.dart';

part 'chat_session_model.g.dart';

@HiveType(typeId: 1)
class ChatSession extends HiveObject{
  @HiveField(0)
  final String sessionId;

  @HiveField(1)
  String title;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  final List<MessageModel> messages;

  @HiveField(4)
  String learningSummary;

  @HiveField(5)
  String? projectName;

  ChatSession({
    required this.sessionId,
    required this.title,
    required this.createdAt,
    required this.messages,
    this.learningSummary = "",
    this.projectName
  });
}
