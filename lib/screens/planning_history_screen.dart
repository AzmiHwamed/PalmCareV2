import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PlanningHistoryScreen extends StatefulWidget {
  final String userId;

  const PlanningHistoryScreen({Key? key, required this.userId})
    : super(key: key);

  @override
  State<PlanningHistoryScreen> createState() => _PlanningHistoryScreenState();
}

class _PlanningHistoryScreenState extends State<PlanningHistoryScreen> {
  final supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<dynamic> _planningHistory = [];

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    try {
      final response = await supabase
          .from('plannings')
          .select()
          .eq('user_id', supabase.auth.currentUser?.id as Object)
          .order('created_at', ascending: false);

      setState(() {
        _planningHistory = response;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تاريخ التخطيطات'),
        backgroundColor: Colors.green[700],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _planningHistory.isEmpty
              ? const Center(child: Text('لا يوجد أي تخطيط سابق.'))
              : ListView.builder(
                itemCount: _planningHistory.length,
                itemBuilder: (context, index) {
                  final planning = _planningHistory[index];
                  return Card(
                    margin: const EdgeInsets.all(10),
                    elevation: 4,
                    child: ListTile(
                      title: Text(planning['plant_name'] ?? 'غير محدد'),
                      subtitle: Text(
                        'من: ${planning['start_date']} إلى ${planning['end_date']}\n'
                        'الكمية: ${planning['irrigation_amount']} لتر\n'
                        'التكرار: ${planning['irrigation_frequency']}\n'
                        '${planning['created_at'] == planning['updated_at'] ? 'لم يحدث أي تغيير' : 'آخر تعديل: ${DateTime.parse(planning['updated_at']).toLocal().toString().split(' ')[0].split('-').reversed.join('/')}'}',
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
