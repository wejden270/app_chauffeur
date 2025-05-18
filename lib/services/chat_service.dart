import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/message.dart';
import '../helpers/api_service.dart';

class ChatService {
  final String baseUrl = ApiService.baseUrl;

  Future<void> sendMessage({
    required int senderId,
    required int receiverId,
    required String message,
    required String senderType,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sender_id': senderId,
          'receiver_id': receiverId,
          'message': message,
          'sender_type': senderType,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send message');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Message>> getMessages({
    required int user1Id,
    required int user2Id,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chat/messages?user1_id=$user1Id&user2_id=$user2Id'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['messages'] as List)
            .map((msg) => Message.fromJson(msg))
            .toList();
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      rethrow;
    }
  }
}
