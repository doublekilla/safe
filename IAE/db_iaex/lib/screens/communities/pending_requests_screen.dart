import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/communities_provider.dart';
import '../../models/community.dart';
import '../../widgets/cards.dart';

class PendingRequestsScreen extends StatefulWidget {
  final int communityId;
  const PendingRequestsScreen({super.key, required this.communityId});

  @override
  State<PendingRequestsScreen> createState() => _PendingRequestsScreenState();
}

class _PendingRequestsScreenState extends State<PendingRequestsScreen> {
  List<CommunityMember>? _requests;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    final prov = context.read<CommunitiesProvider>();
    final requests = await prov.getPendingRequests(widget.communityId);
    if (mounted) {
      setState(() {
        _requests = requests;
        _isLoading = false;
      });
    }
  }

  Future<void> _approve(int userId) async {
    final success = await context.read<CommunitiesProvider>().approveRequest(widget.communityId, userId);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request approved')));
      _loadRequests();
    }
  }

  Future<void> _deny(int userId) async {
    final success = await context.read<CommunitiesProvider>().denyRequest(widget.communityId, userId);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request denied')));
      _loadRequests();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardSurface,
      appBar: AppBar(
        backgroundColor: AppColors.cardSurface,
        title: const Text('Pending Requests'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requests == null || _requests!.isEmpty
              ? const Center(child: Text('No pending requests', style: TextStyle(color: AppColors.textSecondary)))
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: _requests!.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final m = _requests![index];
                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                      leading: UserAvatar(name: m.name, imageUrl: m.avatar, size: 48),
                      title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      subtitle: const Text('Wants to join', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: Colors.red),
                            onPressed: () => _deny(m.id),
                          ),
                          IconButton(
                            icon: const Icon(Icons.check_circle_rounded, color: AppColors.buttonPrimary),
                            onPressed: () => _approve(m.id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
