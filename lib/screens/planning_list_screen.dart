import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PlanningListScreen extends StatefulWidget {
  const PlanningListScreen({super.key});

  @override
  State<PlanningListScreen> createState() => _PlanningListScreenState();
}

class _PlanningListScreenState extends State<PlanningListScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _plannings = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPlannings();
  }

  Future<void> _fetchPlannings() async {
    try {
      final response = await supabase
          .from('plannings')
          .select('*')
          .eq('user_id', supabase.auth.currentUser?.id as Object)
          .order('created_at', ascending: false);

      setState(() {
        _plannings = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'فشل تحميل التخطيطات: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة التخطيطات'),
        backgroundColor: Colors.green[800],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/farm_background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
                : _plannings.isEmpty
                ? const Center(child: Text('لا توجد تخطيطات حتى الآن.'))
                : ListView.builder(
                  itemCount: _plannings.length,
                  itemBuilder: (context, index) {
                    final planning = _plannings[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.nature, color: Colors.green),
                        title: Text(planning['plant_name'] ?? ''),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('من: ${planning['start_date'] ?? ''}'),
                            Text('إلى: ${planning['end_date'] ?? ''}'),
                            Text(
                              'الكمية: ${planning['irrigation_amount'] ?? ''} لتر',
                            ),
                            Text(
                              'التكرار: ${planning['irrigation_frequency'] ?? ''}',
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/editPlanning',
                                  arguments: {'id': planning['id']},
                                );
                              },
                              child: const Text(
                                "✏️ تعديل تخطيط",
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
