import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/json_utils.dart';
import '../../../shared/services/notification_repository.dart';
import '../../admin/widgets/admin_feedback.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  String? _error;

  NotificationRepository get _repo =>
      NotificationRepository(context.read<AuthProvider>().api);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _repo.list();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = formatAdminError(e);
      });
    }
  }

  bool _isRead(Map<String, dynamic> item) => item['isRead'] == true;

  Future<void> _openNotification(Map<String, dynamic> item) async {
    final id = asInt(item['id']);
    if (_isRead(item)) return;

    try {
      await _repo.markRead(id);
      if (!mounted) return;
      setState(() {
        final index = _items.indexWhere((n) => asInt(n['id']) == id);
        if (index >= 0) {
          _items[index] = {..._items[index], 'isRead': true};
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(formatAdminError(e)),
          backgroundColor: AppColors.coralRed,
        ),
      );
    }
  }

  String _formatTime(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat('d/M/y — HH:mm').format(dt);
    } catch (_) {
      return iso;
    }
  }

  IconData _iconForTitle(String title) {
    if (title.contains('واجب')) return Icons.assignment;
    if (title.contains('وجب') || title.contains('وجبة')) return Icons.restaurant;
    if (title.contains('حضور') || title.contains('غياب')) {
      return Icons.fact_check;
    }
    if (title.contains('صورة')) return Icons.photo;
    if (title.contains('ملصق')) return Icons.emoji_events;
    if (title.contains('بث')) return Icons.live_tv;
    if (title.contains('رسالة') || title.contains('دردش')) return Icons.chat;
    return Icons.notifications;
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, size: 48, color: AppColors.coralRed),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _load, child: const Text('إعادة المحاولة')),
            ],
          ),
        ),
      );
    }
    if (_items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Center(child: Text('لا توجد إشعارات')),
        ],
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _items.length,
        itemBuilder: (_, i) {
          final item = _items[i];
          final read = _isRead(item);
          final title = item['title']?.toString() ?? '';
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: read ? null : AppColors.softSky.withValues(alpha: 0.35),
            child: ListTile(
              onTap: () => _openNotification(item),
              leading: CircleAvatar(
                backgroundColor: AppColors.kiddyBlue.withValues(alpha: 0.15),
                child: Icon(_iconForTitle(title), color: AppColors.kiddyBlue),
              ),
              title: Text(
                title,
                style: TextStyle(
                  fontWeight: read ? FontWeight.normal : FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(item['body']?.toString() ?? ''),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(item['createdAt']?.toString()),
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
              trailing: read
                  ? null
                  : const Icon(Icons.circle, size: 10, color: AppColors.coralRed),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الإشعارات'),
          actions: [
            IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }
}

/// Bell icon with unread badge for AppBar.
class NotificationsBellButton extends StatefulWidget {
  const NotificationsBellButton({super.key});

  @override
  State<NotificationsBellButton> createState() =>
      _NotificationsBellButtonState();
}

class _NotificationsBellButtonState extends State<NotificationsBellButton>
    with WidgetsBindingObserver {
  int _unread = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadCount();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadCount();
    }
  }

  Future<void> _loadCount() async {
    try {
      final count = await NotificationRepository(
        context.read<AuthProvider>().api,
      ).unreadCount();
      if (mounted) setState(() => _unread = count);
    } catch (_) {}
  }

  Future<void> _open() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
    _loadCount();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _open,
      tooltip: 'الإشعارات',
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_outlined, size: 26),
          if (_unread > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.coralRed,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  _unread > 9 ? '9+' : '$_unread',
                  style: const TextStyle(color: Colors.white, fontSize: 9),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
