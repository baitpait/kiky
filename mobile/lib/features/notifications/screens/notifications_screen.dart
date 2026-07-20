import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/json_utils.dart';
import '../../../shared/services/notification_repository.dart';
import '../../../shared/services/notification_bell_refresh.dart';
import '../../admin/widgets/admin_feedback.dart';
import '../notification_utils.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  bool _markingAll = false;
  String? _error;
  String _filter = 'all';

  NotificationRepository get _repo =>
      NotificationRepository(context.read<AuthProvider>().api);

  int get _unreadCount =>
      _items.where((item) => item['isRead'] != true).length;

  List<Map<String, dynamic>> get _visibleItems =>
      _items.where((item) => notificationMatchesFilter(item, _filter)).toList();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
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
      NotificationBellRefresh.bump();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = formatAdminError(e);
      });
    }
  }

  Future<void> _markAllRead() async {
    if (_unreadCount == 0 || _markingAll) return;
    setState(() => _markingAll = true);
    try {
      await _repo.markAllRead();
      if (!mounted) return;
      setState(() {
        _items = _items
            .map((item) => {...item, 'isRead': true})
            .toList();
      });
      NotificationBellRefresh.bump();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(formatAdminError(e)),
          backgroundColor: AppColors.coralRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _markingAll = false);
    }
  }

  Future<void> _openNotification(Map<String, dynamic> item) async {
    final id = asInt(item['id']);
    final title = item['title']?.toString() ?? '';
    final body = item['body']?.toString() ?? '';
    final category = item['category']?.toString();
    final style = styleForNotification(title, body, category: category);
    final read = item['isRead'] == true;

    if (!read) {
      try {
        await _repo.markRead(id);
        if (!mounted) return;
        setState(() {
          final index = _items.indexWhere((n) => asInt(n['id']) == id);
          if (index >= 0) {
            _items[index] = {..._items[index], 'isRead': true};
          }
        });
        NotificationBellRefresh.bump();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(formatAdminError(e)),
            backgroundColor: AppColors.coralRed,
          ),
        );
        return;
      }
    }

    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          margin: const EdgeInsets.all(AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: style.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(style.icon, color: style.color, size: 24),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          style.label,
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: style.color,
                          ),
                        ),
                        Text(
                          title,
                          style: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                body,
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 15,
                  height: 1.6,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                formatNotificationTimeFull(item['createdAt']?.toString()),
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('حسناً'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    if (_loading || _error != null || _items.isEmpty) {
      return const SizedBox.shrink();
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: notificationFilterLabels.entries.map((entry) {
          final selected = _filter == entry.key;
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: FilterChip(
              label: Text(entry.value),
              selected: selected,
              onSelected: (_) => setState(() => _filter = entry.key),
              selectedColor: AppColors.softSky,
              checkmarkColor: AppColors.kiddyBlue,
              labelStyle: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? AppColors.kiddyBlue : AppColors.textSecondary,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHeader() {
    if (_loading || _error != null || _items.isEmpty) return const SizedBox.shrink();
    if (_visibleItems.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text(
            'لا إشعارات في هذا التصنيف',
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _unreadCount > 0
                  ? '$_unreadCount غير مقروء'
                  : 'كل الإشعارات مقروءة',
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          if (_unreadCount > 0)
            TextButton.icon(
              onPressed: _markingAll ? null : _markAllRead,
              icon: _markingAll
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.done_all, size: 18),
              label: const Text('تحديد الكل كمقروء'),
            ),
        ],
      ),
    );
  }

  Widget _buildTile(Map<String, dynamic> item) {
    final read = item['isRead'] == true;
    final title = item['title']?.toString() ?? '';
    final body = item['body']?.toString() ?? '';
    final category = item['category']?.toString();
    final style = styleForNotification(title, body, category: category);
    final time = formatNotificationTime(item['createdAt']?.toString());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: Material(
        color: read ? Colors.white : AppColors.softSky.withValues(alpha: 0.55),
        elevation: read ? 0 : 1,
        shadowColor: style.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _openNotification(item),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: style.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(style.icon, color: style.color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: style.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              style.label,
                              style: TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: style.color,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            time,
                            style: const TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 15,
                          fontWeight: read ? FontWeight.w500 : FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 13,
                          height: 1.45,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!read) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 9,
                    height: 9,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: style.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
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
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: AppTheme.fontFamily),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _load,
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }
    if (_items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 100),
          Icon(
            Icons.notifications_none_outlined,
            size: 72,
            color: AppColors.borderLight,
          ),
          SizedBox(height: 16),
          Center(
            child: Text(
              'لا توجد إشعارات بعد',
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          SizedBox(height: 8),
          Center(
            child: Text(
              'ستظهر هنا تنبيهات الحضور والواجبات والرسائل',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _buildFilterBar(),
          _buildHeader(),
          for (final group in _groupedVisibleItems()) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Text(
                group.label,
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            for (final item in group.items) _buildTile(item),
          ],
        ],
      ),
    );
  }

  List<({String label, List<Map<String, dynamic>> items})> _groupedVisibleItems() {
    final order = ['اليوم', 'أمس', 'هذا الأسبوع', 'سابقاً'];
    final buckets = <String, List<Map<String, dynamic>>>{
      for (final key in order) key: [],
    };

    for (final item in _visibleItems) {
      final label = notificationGroupLabel(item['createdAt']?.toString());
      buckets.putIfAbsent(label, () => []).add(item);
    }

    return order
        .where((label) => buckets[label]!.isNotEmpty)
        .map((label) => (label: label, items: buckets[label]!))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الإشعارات'),
          actions: [
            if (_unreadCount > 0 && !_loading)
              IconButton(
                tooltip: 'تحديد الكل كمقروء',
                onPressed: _markingAll ? null : _markAllRead,
                icon: const Icon(Icons.done_all),
              ),
            IconButton(
              tooltip: 'تحديث',
              icon: const Icon(Icons.refresh),
              onPressed: _load,
            ),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }
}

/// Bell icon with unread badge — Web + Mobile via API.
class NotificationsBellButton extends StatefulWidget {
  const NotificationsBellButton({super.key});

  @override
  State<NotificationsBellButton> createState() =>
      _NotificationsBellButtonState();
}

class _NotificationsBellButtonState extends State<NotificationsBellButton>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  int _unread = 0;
  bool _loading = false;
  Timer? _pollTimer;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    NotificationBellRefresh.tick.addListener(_onRefreshTick);
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _pulse = Tween<double>(begin: 1, end: 1.12).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCount());
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) => _loadCount());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _pulseCtrl.dispose();
    NotificationBellRefresh.tick.removeListener(_onRefreshTick);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onRefreshTick() => _loadCount();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadCount();
    }
  }

  Future<void> _loadCount() async {
    if (_loading || !mounted) return;
    _loading = true;
    try {
      final api = context.read<AuthProvider>().api;
      final count = await NotificationRepository(api).unreadCount();
      if (mounted && count > _unread) {
        _pulseCtrl.forward(from: 0);
      }
      if (mounted) setState(() => _unread = count);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('NotificationsBellButton: unread count failed — $e');
      }
    } finally {
      _loading = false;
    }
  }

  Future<void> _open() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
    await _loadCount();
    NotificationBellRefresh.bump();
  }

  @override
  Widget build(BuildContext context) {
    final label = _unread > 99 ? '99+' : '$_unread';
    final hasUnread = _unread > 0;

    return IconButton(
      onPressed: _open,
      tooltip: hasUnread ? '$_unread إشعار غير مقروء' : 'الإشعارات',
      icon: ScaleTransition(
        scale: _pulse,
        child: Badge(
          isLabelVisible: hasUnread,
          backgroundColor: AppColors.kiddyBlue,
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          alignment: AlignmentDirectional.topStart,
          offset: const Offset(6, -4),
          label: Text(
            label,
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
          child: Icon(
            hasUnread ? Icons.notifications_active : Icons.notifications_outlined,
            size: 26,
          ),
        ),
      ),
    );
  }
}
