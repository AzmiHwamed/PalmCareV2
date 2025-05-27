import 'package:flutter/material.dart';

class PanelBatteryMonitoringPage extends StatelessWidget {
  const PanelBatteryMonitoringPage({super.key});

  // Dummy data for now – replace with actual values from your backend
  final double totalKilowatts = 1250.75;
  final double batteryPercentage = 76.5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مراقبة حالة الألواح والبطارية'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.solar_power, size: 80, color: Colors.orange),
            const SizedBox(height: 30),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.bolt,
                  color: Color.fromARGB(255, 73, 248, 125),
                  size: 36,
                ),
                title: const Text('إجمالي الطاقة المستهلكة'),
                subtitle: Text('$totalKilowatts ك.و.س'),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.battery_charging_full,
                  color: Colors.green,
                  size: 36,
                ),
                title: const Text('نسبة شحن البطارية'),
                subtitle: Text('$batteryPercentage٪'),
              ),
            ),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.battery_charging_full,
                  color: Colors.green,
                  size: 36,
                ),
                title: const Text('نسبة شحن البطارية'),
                subtitle: Text('78%'),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: const Text(
                '🚧 هذه الميزة لا تزال قيد التطوير 🚧',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
