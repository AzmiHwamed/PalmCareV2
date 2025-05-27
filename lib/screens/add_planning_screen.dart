import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddPlanningScreen extends StatefulWidget {
  const AddPlanningScreen({Key? key}) : super(key: key);

  @override
  State<AddPlanningScreen> createState() => _AddPlanningScreenState();
}

class _AddPlanningScreenState extends State<AddPlanningScreen> {
  final supabase = Supabase.instance.client;

  final _plantNameController = TextEditingController();
  final _irrigationAmountController = TextEditingController();
  final _frequencyController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;
  String? _error;

  Future<void> _submitPlanning() async {
    final user = supabase.auth.currentUser;
    print('Current user: ${user?.email}');

    if (user == null) {
      setState(() => _error = 'لم يتم العثور على المستخدم.');
      return;
    }

    final plantName = _plantNameController.text.trim();
    final irrigationAmount = int.tryParse(
      _irrigationAmountController.text.trim(),
    );
    final frequency = _frequencyController.text.trim();

    if (plantName.isEmpty ||
        irrigationAmount == null ||
        frequency.isEmpty ||
        _startDate == null ||
        _endDate == null) {
      setState(() => _error = 'يرجى تعبئة جميع الحقول بشكل صحيح.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await supabase.from('plannings').insert({
        'plant_name': plantName,
        'start_date': _startDate!.toIso8601String(),
        'end_date': _endDate!.toIso8601String(),
        'irrigation_amount': irrigationAmount,
        'irrigation_frequency': frequency,
        'user_id': user.id,
      });

      Navigator.pop(context); // رجوع بعد الإضافة
    } catch (e) {
      setState(() => _error = 'حدث خطأ أثناء الإضافة: $e');
      print('Error adding planning: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  void dispose() {
    _plantNameController.dispose();
    _irrigationAmountController.dispose();
    _frequencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة تخطيط جديد'),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _plantNameController,
                decoration: const InputDecoration(
                  labelText: 'اسم الزرع',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _irrigationAmountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'كمية الري (لتر)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _frequencyController,
                decoration: const InputDecoration(
                  labelText: 'تكرار السقي (مثلاً: كل 3 أيام)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _startDate != null
                          ? 'تاريخ البداية: ${_startDate!.toLocal()}'.split(
                            ' ',
                          )[0]
                          : 'اختر تاريخ البداية',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _pickDate(isStart: true),
                    child: const Text('اختيار'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _endDate != null
                          ? 'تاريخ النهاية: ${_endDate!.toLocal()}'.split(
                            ' ',
                          )[0]
                          : 'اختر تاريخ النهاية',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _pickDate(isStart: false),
                    child: const Text('اختيار'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitPlanning,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          'حفظ التخطيط',
                          style: TextStyle(fontSize: 18),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
