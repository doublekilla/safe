import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/feed_provider.dart';
import '../../widgets/cards.dart';

import '../../providers/auth_provider.dart';
import '../../providers/communities_provider.dart';

/// Community feed screen — posts, likes, comments
class CommunityFeedScreen extends StatefulWidget {
  final int? communityId;
  const CommunityFeedScreen({super.key, this.communityId});
  @override State<CommunityFeedScreen> createState() => _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends State<CommunityFeedScreen> {
  final _postController = TextEditingController();
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<FeedProvider>().loadFeed(communityId: widget.communityId));
  }

  @override
  void dispose() { _postController.dispose(); super.dispose(); }

<<<<<<< HEAD
  bool _canPost(BuildContext context) {
=======
  bool _isAdmin(BuildContext context) {
>>>>>>> 2bf0c916ae27714e7e8ee712538323298f719d29
    if (widget.communityId == null) return false;
    final prov = context.read<CommunitiesProvider>();
    final com = prov.communities.where((c) => c.id == widget.communityId).firstOrNull ?? prov.selectedCommunity;
    if (com == null || com.id != widget.communityId) return false;
    
    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser == null) return false;

    if (com.adminUserId == currentUser.id) return true;
<<<<<<< HEAD
    if (com.isJoined) return true;
    
    final me = com.members.where((m) => m.id == currentUser.id).firstOrNull;
    return me != null;
=======
    final me = com.members.where((m) => m.id == currentUser.id).firstOrNull;
    return me != null && me.role == 'admin';
>>>>>>> 2bf0c916ae27714e7e8ee712538323298f719d29
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() { _selectedImagePath = pickedFile.path; });
    }
  }

  String _formatDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '';
    try {
      final date = DateTime.parse(isoString).toLocal();
      return DateFormat('dd MMM yyyy, HH:mm').format(date);
    } catch (_) {
      return isoString;
    }
  }

<<<<<<< HEAD
  void _showComments(BuildContext context, int postId, FeedProvider prov) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return _CommentsSheet(postId: postId, prov: prov);
      },
    );
  }

=======
>>>>>>> 2bf0c916ae27714e7e8ee712538323298f719d29
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: AppColors.cardSurface, title: const Text('Club Feed'), leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop())),
      body: Consumer<FeedProvider>(builder: (context, prov, _) {
<<<<<<< HEAD
        final canPost = _canPost(context);
        return CustomScrollView(slivers: [
          // Create post box
          if (canPost)
=======
        final isAdmin = _isAdmin(context);
        return CustomScrollView(slivers: [
          // Create post box
          if (isAdmin)
>>>>>>> 2bf0c916ae27714e7e8ee712538323298f719d29
            SliverToBoxAdapter(child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.cardSurface, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: const Color(0xFF101820).withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 4))]),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                TextField(
                  controller: _postController, maxLines: 3, minLines: 1,
                  decoration: const InputDecoration(hintText: 'Share a moment, result, or update...', border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none),
                ),
                if (_selectedImagePath != null) ...[
                  const SizedBox(height: 10),
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(File(_selectedImagePath!), height: 120, width: double.infinity, fit: BoxFit.contain),
                      ),
                      Positioned(
                        top: 4, right: 4,
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedImagePath = null),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                            child: const Icon(Icons.close, size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const Divider(color: AppColors.border),
                Row(children: [
                  TextButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_outlined, size: 18, color: AppColors.textSecondary),
                    label: const Text('Photo', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ),
                  const Spacer(),
                  SizedBox(height: 32, child: ElevatedButton(
                    onPressed: () async {
                      final text = _postController.text.trim();
                      if (text.isNotEmpty || _selectedImagePath != null) {
                        final success = await prov.createPost(
                          text: text,
                          communityId: widget.communityId,
                          imagePath: _selectedImagePath,
                        );
                        if (success) {
                          _postController.clear();
                          setState(() => _selectedImagePath = null);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonPrimary, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    child: const Text('Post', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  )),
                ]),
              ]),
            )),
          // Feed posts
          if (prov.isLoading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppColors.textMuted)))
          else if (prov.posts.isEmpty)
            const SliverFillRemaining(child: EmptyState(icon: Icons.feed_outlined, title: 'No posts yet', subtitle: 'Be the first to share something!'))
          else
            SliverList(delegate: SliverChildBuilderDelegate((context, index) {
              final post = prov.posts[index];
              final imageUrl = post.image;
              final fullImageUrl = imageUrl != null ? (imageUrl.startsWith('http') ? imageUrl : 'http://10.0.2.2:8000$imageUrl') : null;
              
              return Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.cardSurface, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: const Color(0xFF101820).withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 4))]),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Header
                  Row(children: [
                    UserAvatar(name: post.userName, imageUrl: post.userImage, size: 40),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(post.userName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
<<<<<<< HEAD
                      Builder(builder: (context) {
                        String role = 'Anggota';
                        final commProv = context.read<CommunitiesProvider>();
                        final com = commProv.communities.where((c) => c.id == (widget.communityId ?? post.communityId)).firstOrNull ?? commProv.selectedCommunity;
                        if (com != null && com.adminUserId == post.userId) {
                          role = 'Admin';
                        }
                        return Text(role, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary));
                      }),
=======
                      Text(post.communityName ?? '', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
>>>>>>> 2bf0c916ae27714e7e8ee712538323298f719d29
                    ])),
                    if (post.tag != null) Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.chipBackground, borderRadius: BorderRadius.circular(9999)),
                      child: Text(post.tag!.replaceAll('_', ' '), style: const TextStyle(fontSize: 10, color: AppColors.chipText)),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  // Content
                  if (post.text.isNotEmpty)
                    Text(post.text, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.5)),
                  if (fullImageUrl != null) ...[
                    const SizedBox(height: 12),
                    ClipRRect(borderRadius: BorderRadius.circular(16), child: Container(
                      height: 180, width: double.infinity, color: AppColors.softGray,
                      child: Image.network(fullImageUrl, fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.image_rounded, size: 40, color: AppColors.textMuted))),
                    )),
                  ],
                  const SizedBox(height: 12),
                  // Actions
                  Row(children: [
                    GestureDetector(
                      onTap: () => prov.toggleLike(post.id),
                      child: Row(children: [
                        Icon(post.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded, size: 20, color: post.isLiked ? AppColors.errorRed : AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text('${post.likes}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ]),
                    ),
<<<<<<< HEAD
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => _showComments(context, post.id, prov),
                      child: Row(children: [
                        const Icon(Icons.mode_comment_outlined, size: 20, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text('${post.comments}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ]),
                    ),
=======
>>>>>>> 2bf0c916ae27714e7e8ee712538323298f719d29
                    const Spacer(),
                    Text(_formatDate(post.createdAt), style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                  ]),
                ]),
              );
            }, childCount: prov.posts.length)),
        ]);
      }),
    );
  }
}
<<<<<<< HEAD

class _CommentsSheet extends StatefulWidget {
  final int postId;
  final FeedProvider prov;
  const _CommentsSheet({required this.postId, required this.prov});
  @override State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final _commentController = TextEditingController();
  List<Map<String, dynamic>> _comments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    final comments = await widget.prov.getComments(widget.postId);
    if (mounted) {
      setState(() {
        _comments = comments;
        _isLoading = false;
      });
    }
  }

  Future<void> _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    
    // Optimistic UI update could be done here, but let's wait for network
    final success = await widget.prov.addComment(widget.postId, text);
    if (success) {
      _commentController.clear();
      _loadComments();
    }
  }

  String _formatDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '';
    try {
      final date = DateTime.parse(isoString).toLocal();
      return DateFormat('dd MMM, HH:mm').format(date);
    } catch (_) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(children: [
          const Text('Comments', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const Divider(height: 30, color: AppColors.border),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.textMuted))
                : _comments.isEmpty
                    ? const Center(child: Text('No comments yet.', style: TextStyle(color: AppColors.textSecondary)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _comments.length,
                        itemBuilder: (context, index) {
                          final comment = _comments[index];
                          final user = comment['user'] ?? {};
                          final userName = user['name'] ?? 'User';
                          final userImage = user['sl_profile']?['profile_image'] ?? user['avatar'];
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              UserAvatar(name: userName, imageUrl: userImage, size: 36),
                              const SizedBox(width: 12),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Row(children: [
                                  Text(userName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                  const SizedBox(width: 8),
                                  Text(_formatDate(comment['created_at']), style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                ]),
                                const SizedBox(height: 4),
                                Text(comment['comment'] ?? '', style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4)),
                              ])),
                            ]),
                          );
                        },
                      ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            decoration: BoxDecoration(color: AppColors.cardSurface, border: Border(top: BorderSide(color: AppColors.border.withValues(alpha: 0.5)))),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Add a comment...',
                    hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.softGray,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                  ),
                  onSubmitted: (_) => _addComment(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _addComment,
                icon: const Icon(Icons.send_rounded, color: AppColors.buttonPrimary),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

=======
>>>>>>> 2bf0c916ae27714e7e8ee712538323298f719d29
