import 'package:flutter/material.dart';

class WaterConsumptionScreen extends StatelessWidget {
  const WaterConsumptionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // لاحقًا يمكننا إضافة الرسوم البيانية هنا باستخدام مكتبة مثل charts_flutter أو fl_chart
    return Scaffold(
      appBar: AppBar(
        title: const Text('بيانات استهلاك المياه'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Text(
          'هنا ستُعرض بيانات استهلاك المياه قريبًا',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
