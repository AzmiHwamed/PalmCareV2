import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditPlanningScreen extends StatefulWidget {
  final String planningId;

  const EditPlanningScreen({Key? key, required this.planningId})
    : super(key: key);

  @override
  State<EditPlanningScreen> createState() => _EditPlanningScreenState();
}

class _EditPlanningScreenState extends State<EditPlanningScreen> {
  final supabase = Supabase.instance.client;

  final _plantNameController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _amountController = TextEditingController();
  final _frequencyController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPlanning();
  }

  Future<void> _loadPlanning() async {
    setState(() => _isLoading = true);
    try {
      final response =
          await supabase
              .from('plannings')
              .select()
              .eq('id', widget.planningId)
              .single();

      _plantNameController.text = response['plant_name'] ?? '';
      _startDateController.text = response['start_date'] ?? '';
      _endDateController.text = response['end_date'] ?? '';
      _amountController.text = response['irrigation_amount'].toString();
      _frequencyController.text = response['irrigation_frequency'] ?? '';
    } catch (e) {
      setState(() => _errorMessage = 'فشل في تحميل البيانات: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updatePlanning() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await supabase
          .from('plannings')
          .update({
            'plant_name': _plantNameController.text.trim(),
            'start_date': _startDateController.text.trim(),
            'end_date': _endDateController.text.trim(),
            'irrigation_amount': int.parse(_amountController.text),
            'irrigation_frequency': _frequencyController.text.trim(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', widget.planningId);

      Navigator.pushNamed(context, "/planningList");
    } catch (e) {
      setState(() {
        _errorMessage = 'خطأ أثناء التحديث: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _plantNameController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _amountController.dispose();
    _frequencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل التخطيط'),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: _plantNameController,
                        decoration: const InputDecoration(
                          labelText: 'اسم الزرع',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _startDateController,
                        decoration: const InputDecoration(
                          labelText: 'تاريخ البداية (yyyy-mm-dd)',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _endDateController,
                        decoration: const InputDecoration(
                          labelText: 'تاريخ النهاية (yyyy-mm-dd)',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'كمية الماء',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _frequencyController,
                        decoration: const InputDecoration(
                          labelText: 'تكرار السقي',
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_errorMessage != null)
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _updatePlanning,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                        ),
                        child: const Text('تحديث التخطيط'),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
