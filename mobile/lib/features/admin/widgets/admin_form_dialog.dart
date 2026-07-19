import 'package:flutter/material.dart';

/// Shows a validated admin form dialog. Returns true only when saved.
Future<bool> showAdminFormDialog({
  required BuildContext context,
  required String title,
  required List<Widget> fields,
  required bool Function() validate,
  String confirmLabel = 'حفظ',
}) {
  return showDialog<bool>(
        context: context,
        builder: (ctx) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: fields,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (validate()) {
                    Navigator.pop(ctx, true);
                  }
                },
                child: Text(confirmLabel),
              ),
            ],
          ),
        ),
      ).then((value) => value == true);
}
