import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/services/content_repository.dart';

class ParentCalendarScreen extends StatefulWidget {
  const ParentCalendarScreen({super.key});

  @override
  State<ParentCalendarScreen> createState() => _ParentCalendarScreenState();
}

class _ParentCalendarScreenState extends State<ParentCalendarScreen> {
  List<Map<String, dynamic>> _events = [];
  List<Map<String, dynamic>> _banners = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ContentRepository(context.read<AuthProvider>().api);
    try {
      final events = await repo.publicCalendar();
      final banners = await repo.publicBanners();
      setState(() {
        _events = events;
        _banners = banners;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('التقويم والإعلانات'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'التقويم'),
                Tab(text: 'البانرات'),
              ],
            ),
          ),
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  children: [
                    _events.isEmpty
                        ? const Center(child: Text('لا أحداث'))
                        : ListView.builder(
                            itemCount: _events.length,
                            itemBuilder: (_, i) {
                              final e = _events[i];
                              return ListTile(
                                leading: const Icon(Icons.event,
                                    color: AppColors.kiddyBlue),
                                title: Text(e['title']?.toString() ?? ''),
                                subtitle: Text(
                                  (e['startDate'] as String?)
                                          ?.split('T')
                                          .first ??
                                      '',
                                ),
                              );
                            },
                          ),
                    _banners.isEmpty
                        ? const Center(child: Text('لا إعلانات'))
                        : ListView.builder(
                            itemCount: _banners.length,
                            itemBuilder: (_, i) {
                              final b = _banners[i];
                              return Card(
                                margin: const EdgeInsets.all(8),
                                child: ListTile(
                                  title: Text(b['title']?.toString() ?? ''),
                                  subtitle: Text(b['body']?.toString() ?? ''),
                                ),
                              );
                            },
                          ),
                  ],
                ),
        ),
      ),
    );
  }
}
