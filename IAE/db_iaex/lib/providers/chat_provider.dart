import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../core/services/api_client.dart';

import '../core/services/echo_service.dart';

/// Chat state management
class ChatProvider extends ChangeNotifier {
  final ApiClient _api;
  final EchoService? _echoService;
  EchoService? get echoService => _echoService;
  List<ChatConversation> _conversations = [];
  List<ChatMessage> _messages = [];
  bool _isLoading = false;

  ChatProvider({required ApiClient api, EchoService? echoService}) 
    : _api = api,
      _echoService = echoService;

  List<ChatConversation> get conversations => _conversations;
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  Future<void> loadConversations() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _api.get('/chat');
      if (res.isSuccess && res.data is List) {
        _conversations = (res.data as List).map((e) => ChatConversation.fromJson(e)).toList();
      }
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMessages(int conversationId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _api.get('/chat/private/$conversationId');
      if (res.isSuccess && res.data is List) {
        _messages = (res.data as List).map((e) => ChatMessage.fromJson(e)).toList();
      }
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadGroupMessages(int groupId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _api.get('/chat/groups/$groupId/messages');
      if (res.isSuccess && res.data is List) {
        _messages = (res.data as List).map((e) => ChatMessage.fromJson(e)).toList();
      }
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  void listenToGroupMessages(int groupId) {
    if (_echoService?.echo == null) return;
    _echoService!.echo!.private('sl-community.$groupId').listen('.chat.message.sent', (e) {
      if (e != null) {
        final newMsg = ChatMessage.fromJson(Map<String, dynamic>.from(e));
        if (!_messages.any((m) => m.id == newMsg.id)) {
          _messages.insert(0, newMsg);
          notifyListeners();
        }
      }
    });
  }

  void leaveGroupMessages(int groupId) {
    if (_echoService?.echo == null) return;
    _echoService!.echo!.leave('sl-community.$groupId');
  }

  Future<bool> sendMessage({required String message, int? receiverId, int? groupId, String type = 'text', int? linkedActivityId}) async {
    try {
      final body = <String, dynamic>{'message': message, 'type': type};
      if (receiverId != null) body['receiver_id'] = receiverId;
      if (groupId != null) body['group_id'] = groupId;
      if (linkedActivityId != null) body['linked_activity_id'] = linkedActivityId;
      final res = await _api.post('/chat/send', body: body);
      if (res.isSuccess) {
        final newMsg = ChatMessage.fromJson(res.data as Map<String, dynamic>);
        _messages.insert(0, newMsg);
        notifyListeners();
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> deletePrivateChat(int otherUserId) async {
    final response = await _api.delete('/chat/private/$otherUserId');
    if (response.isSuccess) {
      _conversations.removeWhere((c) => !c.isGroup && c.id == otherUserId);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> deleteMessages(List<int> messageIds) async {
    final response = await _api.post('/chat/messages/delete', body: {
      'message_ids': messageIds,
    });
    if (response.isSuccess) {
      _messages.removeWhere((m) => messageIds.contains(m.id));
      notifyListeners();
      return true;
    }
    return false;
  }
}
