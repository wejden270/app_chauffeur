import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/message.dart';
import '../helpers/api_service.dart';

class ChatApiService {
  final String baseUrl = ApiService.baseUrl;

  Future<void> sendMessage({
    required int senderId,
    required int receiverId,
    required String message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send-message-notification'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'sender_id': senderId,
          'receiver_id': receiverId,
          'message': message,
          'sender_type': 'driver',
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Échec de l\'envoi du message');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Message>> getMessages(int user1Id, int user2Id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/messages?user1_id=$user1Id&user2_id=$user2Id'),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        List<Message> messages = (data['messages'] as List)
            .map((msg) => Message.fromJson(msg))
            .toList();
        return messages;
      } else {
        throw Exception('Échec du chargement des messages');
      }
    } catch (e) {
      rethrow;
    }
  }
}
