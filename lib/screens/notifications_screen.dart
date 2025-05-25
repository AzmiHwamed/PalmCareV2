import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final supabase = Supabase.instance.client;
  final List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadInitialNotifications();
    _listenToNotifications();
  }

  void _loadInitialNotifications() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from('notifications')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    setState(() {
      _notifications.addAll(response);
    });
  }

  void _listenToNotifications() {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    supabase
        .channel('public:notifications')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          callback: (payload) {
            final newNotification = payload.newRecord;
            setState(() {
              _notifications.insert(0, newNotification);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('🔔 إشعار جديد: ${newNotification['title']}'),
                backgroundColor: Colors.deepOrange,
              ),
            );
          },
        )
        .subscribe();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        backgroundColor: Colors.deepOrange,
      ),
      body: _notifications.isEmpty
          ? const Center(child: Text('لا توجد إشعارات بعد.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final notif = _notifications[index];
                return ListTile(
                  leading: Icon(
                    Icons.notifications_active,
                    color: Colors.deepOrange.shade400,
                  ),
                  title: Text(notif['title'] ?? 'إشعار'),
                  subtitle: Text(notif['message'] ?? ''),
                  trailing: Text(
                    notif['created_at']?.toString().substring(0, 16) ?? '',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                );
              },
            ),
    );
  }
}
