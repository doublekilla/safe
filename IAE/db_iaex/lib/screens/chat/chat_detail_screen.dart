import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/chat_provider.dart';

/// Private chat detail screen
class ChatDetailScreen extends StatefulWidget {
  final int conversationId;
  final String name;
  const ChatDetailScreen({super.key, required this.conversationId, required this.name});
  @override State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _msgController = TextEditingController();
  final Set<int> _selectedMessageIds = {};
  bool _isSelecting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<ChatProvider>().loadMessages(widget.conversationId));
  }

  @override
  void dispose() { _msgController.dispose(); super.dispose(); }

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

  void _send() {
    if (_msgController.text.trim().isEmpty) return;
    context.read<ChatProvider>().sendMessage(message: _msgController.text.trim(), receiverId: widget.conversationId);
    _msgController.clear();
  }

  void _toggleSelect(int messageId) {
    setState(() {
      if (_selectedMessageIds.contains(messageId)) {
        _selectedMessageIds.remove(messageId);
        if (_selectedMessageIds.isEmpty) _isSelecting = false;
      } else {
        _selectedMessageIds.add(messageId);
      }
    });
  }

  void _cancelSelection() {
    setState(() {
      _selectedMessageIds.clear();
      _isSelecting = false;
    });
  }

  void _deleteSelected() {
    if (_selectedMessageIds.isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Messages'),
        content: Text('Delete ${_selectedMessageIds.length} message(s)?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final ids = _selectedMessageIds.toList();
              final success = await context.read<ChatProvider>().deleteMessages(ids);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Messages deleted')));
              }
              _cancelSelection();
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.errorRed)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardSurface,
        leading: _isSelecting
            ? IconButton(icon: const Icon(Icons.close_rounded), onPressed: _cancelSelection)
            : IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
        title: _isSelecting
            ? Text('${_selectedMessageIds.length} selected')
            : Text(widget.name),
        actions: [
          if (_isSelecting)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.errorRed),
              onPressed: _deleteSelected,
            )
          else
            IconButton(
              icon: const Icon(Icons.info_outline_rounded, color: AppColors.textPrimary),
              onPressed: () => context.push('/friend/${widget.conversationId}'),
            ),
        ],
      ),
      body: Consumer<ChatProvider>(builder: (context, prov, _) {
        return Column(children: [
          Expanded(
            child: prov.messages.isEmpty
                ? Center(child: Text('Start a conversation', style: TextStyle(fontSize: 13, color: AppColors.textMuted)))
                : ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: prov.messages.length,
                    itemBuilder: (context, index) {
                      final msg = prov.messages[index];
                      final prevMsg = index < prov.messages.length - 1 ? prov.messages[index + 1] : null;
                      
                      final isMe = msg.isMe;
                      final isSelected = _selectedMessageIds.contains(msg.id);
                      
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

                      Widget messageWidget;

                      if (msg.type == 'activity_invite' && msg.linkedActivityId != null) {
                        messageWidget = GestureDetector(
                          onLongPress: () {
                            setState(() {
                              _isSelecting = true;
                              _selectedMessageIds.add(msg.id);
                            });
                          },
                          onTap: _isSelecting
                              ? () => _toggleSelect(msg.id)
                              : () => context.push('/activity/${msg.linkedActivityId}'),
                          child: Container(
                            color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent,
                            child: Align(
                              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(14),
                                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                                decoration: BoxDecoration(
                                  color: AppColors.softGray,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                                ),
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Row(children: [
                                    const Icon(Icons.event_rounded, size: 16, color: AppColors.textPrimary),
                                    const SizedBox(width: 6),
                                    const Text('Activity Invitation', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                  ]),
                                  const SizedBox(height: 6),
                                  Text(msg.linkedActivityTitle ?? 'View Activity', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Tap to view details →', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                      Text(_formatTime(msg.time), style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                    ],
                                  ),
                                ]),
                              ),
                            ),
                          ),
                        );
                      } else {
                        messageWidget = GestureDetector(
                          onLongPress: () {
                            setState(() {
                              _isSelecting = true;
                              _selectedMessageIds.add(msg.id);
                            });
                          },
                          onTap: _isSelecting ? () => _toggleSelect(msg.id) : null,
                          child: Container(
                            color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                              children: [
                                if (_isSelecting)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Icon(
                                      isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                      size: 20,
                                      color: isSelected ? AppColors.primary : AppColors.textMuted,
                                    ),
                                  ),
                                Flexible(
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                                    decoration: BoxDecoration(
                                      color: isMe ? AppColors.buttonPrimary : AppColors.cardSurface,
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(18),
                                        topRight: const Radius.circular(18),
                                        bottomLeft: isMe ? const Radius.circular(18) : const Radius.circular(4),
                                        bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(18),
                                      ),
                                      boxShadow: [BoxShadow(color: const Color(0xFF101820).withValues(alpha: 0.04), blurRadius: 10)],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Wrap(
                                          alignment: WrapAlignment.end,
                                          crossAxisAlignment: WrapCrossAlignment.end,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(right: 12.0, bottom: 2.0),
                                              child: Text(msg.message, style: TextStyle(fontSize: 14, color: isMe ? Colors.white : AppColors.textPrimary, height: 1.4)),
                                            ),
                                            Text(_formatTime(msg.time), style: TextStyle(fontSize: 10, color: isMe ? Colors.white54 : AppColors.textMuted)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

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
                  ),
          ),
          // Input bar
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            decoration: BoxDecoration(color: AppColors.cardSurface, boxShadow: [BoxShadow(color: const Color(0xFF101820).withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, -4))]),
            child: SafeArea(
              child: Row(children: [
                IconButton(icon: const Icon(Icons.attach_file_rounded, color: AppColors.textMuted, size: 22), onPressed: () {}),
                Expanded(child: TextField(
                  controller: _msgController,
                  decoration: InputDecoration(
                    hintText: 'Type a message...', hintStyle: const TextStyle(fontSize: 14, color: AppColors.textMuted),
                    filled: true, fillColor: AppColors.softGray,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  onSubmitted: (_) => _send(),
                )),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _send,
                  child: Container(
                    width: 44, height: 44,
                    decoration: const BoxDecoration(color: AppColors.buttonPrimary, shape: BoxShape.circle),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ]),
            ),
          ),
        ]);
      }),
    );
  }
}