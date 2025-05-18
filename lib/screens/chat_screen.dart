import 'package:flutter/material.dart';
import 'dart:async';
import '../services/chat_api_service.dart';
import '../models/message.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final clientId = ModalRoute.of(context)?.settings.arguments as int?;
    
    if (clientId == null) {
      return Scaffold(
        body: Center(
          child: Text('Erreur: ID client non fourni'),
        ),
      );
    }

    return _ChatScreenContent(clientId: clientId);
  }
}

class _ChatScreenContent extends StatefulWidget {
  final int clientId;

  const _ChatScreenContent({required this.clientId});

  @override
  _ChatScreenContentState createState() => _ChatScreenContentState();
}

class _ChatScreenContentState extends State<_ChatScreenContent> {
  final ChatApiService _chatService = ChatApiService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Message> _messages = [];
  int? _driverId;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initializeChat();
    _setupMessagePolling();
  }

  void _setupMessagePolling() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _loadMessages());
  }

  Future<void> _initializeChat() async {
    final prefs = await SharedPreferences.getInstance();
    _driverId = prefs.getInt('driverId');
    if (_driverId != null) {
      _loadMessages();
    }
  }

  Future<void> _loadMessages() async {
    if (_driverId == null || widget.clientId == null) return;
    
    try {
      final messages = await _chatService.getMessages(_driverId!, widget.clientId);
      setState(() => _messages = messages);
    } catch (e) {
      // Gérer l'erreur silencieusement pour le polling
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _driverId == null || widget.clientId == null) return;

    try {
      await _chatService.sendMessage(
        senderId: _driverId!,
        receiverId: widget.clientId,
        message: _messageController.text,
      );
      _messageController.clear();
      await _loadMessages();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'envoi du message')),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message.senderId == _driverId;
                
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(message.message),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Votre message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
