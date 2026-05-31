import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/chat_provider.dart';
import '../../models/chat_message.dart';

/// Group chat screen — community or activity group chat
class GroupChatScreen extends StatefulWidget {
  final int groupId;
  final String groupName;
  const GroupChatScreen({super.key, required this.groupId, required this.groupName});
  @override State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final _msgController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = context.read<ChatProvider>();
      prov.loadGroupMessages(widget.groupId);
      prov.listenToGroupMessages(widget.groupId);
    });
  }

  @override void dispose() { 
    context.read<ChatProvider>().leaveGroupMessages(widget.groupId);
    _msgController.dispose(); 
    super.dispose(); 
  }

  DateTime? _parseTimeSafe(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return null;
    try {
      return DateTime.parse(timeStr).toLocal();
    } catch (_) {
      return null;
    }
  }

  String _formatDateSeparator(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDate = DateTime(date.year, date.month, date.day);
    final difference = today.difference(msgDate).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return DateFormat('EEEE').format(date);
    } else {
      return DateFormat('d MMM').format(date);
    }
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '';
    try {
      final dt = DateTime.parse(timeStr).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return timeStr;
    }
  }

  Future<void> _sendMessage() async {
    if (_msgController.text.trim().isEmpty) return;
    final prov = context.read<ChatProvider>();
    final success = await prov.sendMessage(
      message: _msgController.text.trim(),
      groupId: widget.groupId,
    );
    if (success) {
      _msgController.clear();
      // No need to reload, sending automatically adds to provider list and updates UI
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardSurface,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.groupName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ]),
        actions: [IconButton(icon: const Icon(Icons.info_outline_rounded), onPressed: () => context.push('/community/${widget.groupId}'))],
      ),
      body: Column(children: [
        // Messages
        Expanded(
          child: Consumer<ChatProvider>(builder: (context, prov, _) {
            if (prov.isLoading && prov.messages.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: AppColors.textMuted));
            }
            if (prov.messages.isEmpty) {
              return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.chat_bubble_outline_rounded, size: 48, color: AppColors.textMuted.withValues(alpha: 0.4)),
                const SizedBox(height: 12),
                const Text('No messages yet', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                const Text('Start the conversation!', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ]));
            }
            return ListView.builder(
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: prov.messages.length,
              itemBuilder: (context, index) {
                final msg = prov.messages[index];
                final prevMsg = index < prov.messages.length - 1 ? prov.messages[index + 1] : null;
                
                final isMe = msg.isMe;

                bool showDateSeparator = false;
                final msgDate = _parseTimeSafe(msg.time);
                if (msgDate != null) {
                  if (prevMsg == null) {
                    showDateSeparator = true;
                  } else {
                    final prevDate = _parseTimeSafe(prevMsg.time);
                    if (prevDate == null ||
                        msgDate.year != prevDate.year ||
                        msgDate.month != prevDate.month ||
                        msgDate.day != prevDate.day) {
                      showDateSeparator = true;
                    }
                  }
                }

                Widget messageWidget = _buildMessage(msg, isMe);

                if (showDateSeparator && msgDate != null) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          _formatDateSeparator(msgDate),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                        ),
                      ),
                      messageWidget,
                    ],
                  );
                }

                return messageWidget;
              },
            );
          }),
        ),
        // Input bar
        Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          decoration: BoxDecoration(color: AppColors.cardSurface, boxShadow: [BoxShadow(color: const Color(0xFF101820).withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, -4))]),
          child: SafeArea(child: Row(children: [
            IconButton(icon: const Icon(Icons.attach_file_rounded, color: AppColors.textMuted, size: 22), onPressed: () {}),
            Expanded(child: TextField(
              controller: _msgController,
              decoration: InputDecoration(hintText: 'Type a message...', hintStyle: const TextStyle(fontSize: 14, color: AppColors.textMuted),
                filled: true, fillColor: AppColors.softGray, border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
              onSubmitted: (_) => _sendMessage(),
            )),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(width: 44, height: 44, decoration: const BoxDecoration(color: AppColors.buttonPrimary, shape: BoxShape.circle), child: const Icon(Icons.send_rounded, color: Colors.white, size: 20)),
            ),
          ])),
        ),
      ]),
    );
  }

  Widget _buildMessage(ChatMessage msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? AppColors.buttonPrimary : AppColors.cardSurface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          boxShadow: isMe ? [] : [BoxShadow(color: const Color(0xFF101820).withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe) ...[
              Text(msg.senderName, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.buttonPrimary)),
              const SizedBox(height: 4),
            ],
            Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 12.0, bottom: 2.0),
                  child: Text(msg.message, style: TextStyle(fontSize: 13, color: isMe ? Colors.white : AppColors.textPrimary)),
                ),
                Text(_formatTime(msg.time), style: TextStyle(fontSize: 10, color: isMe ? Colors.white70 : AppColors.textMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
