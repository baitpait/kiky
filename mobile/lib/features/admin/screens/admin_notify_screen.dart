import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/services/content_repository.dart';
import '../../../shared/services/notification_bell_refresh.dart';
import '../../../shared/widgets/labeled_dropdown.dart';
import '../widgets/admin_feedback.dart';
import '../widgets/safe_admin_feedback.dart';

class AdminNotifyScreen extends StatefulWidget {
  const AdminNotifyScreen({super.key});

  @override
  State<AdminNotifyScreen> createState() => _AdminNotifyScreenState();
}

class _AdminNotifyScreenState extends State<AdminNotifyScreen> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  String _target = 'all';
  bool _sending = false;

  Future<void> _send() async {
    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text.trim();
    if (title.isEmpty || body.isEmpty) {
      showAdminError(context, 'العنوان ونص الإشعار مطلوبان');
      return;
    }

    setState(() => _sending = true);
    try {
      await ContentRepository(context.read<AuthProvider>().api)
          .sendNotification({
        'title': title,
        'body': body,
        'target': _target,
      });
      if (mounted) {
        adminSuccess('تم إرسال الإشعار');
        NotificationBellRefresh.bump();
        _titleCtrl.clear();
        _bodyCtrl.clear();
      }
    } catch (e) {
      adminError(e);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('إرسال إشعارات')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'عنوان الإشعار'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _bodyCtrl,
                decoration: const InputDecoration(labelText: 'نص الإشعار'),
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              LabeledDropdown<String>(
                label: 'الاستهداف',
                value: _target,
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('الجميع')),
                  DropdownMenuItem(value: 'teachers', child: Text('معلمات')),
                  DropdownMenuItem(value: 'parents', child: Text('أولياء أمور')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _target = v);
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _sending ? null : _send,
                child: _sending
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('إرسال Push'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
