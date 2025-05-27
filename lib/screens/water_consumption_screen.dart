import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class WaterConsumptionScreen extends StatefulWidget {
  const WaterConsumptionScreen({Key? key}) : super(key: key);

  @override
  State<WaterConsumptionScreen> createState() => _WaterConsumptionScreenState();
}

class _WaterConsumptionScreenState extends State<WaterConsumptionScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> waterConsumptionData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchWaterConsumptionData();
  }

  Future<void> fetchWaterConsumptionData() async {
    try {
      final today = DateTime.now();
      final pastTwoDays = today.subtract(const Duration(days: 2));
      final nextTwoDays = today.add(const Duration(days: 2));

      final response = await supabase
          .from('plannings')
          .select(
            'plant_name, irrigation_amount, irrigation_frequency, start_date, end_date',
          );

      final data = response as List<dynamic>;

      final processedData =
          data.map((planning) {
            final startDate = DateTime.parse(planning['start_date']);
            final endDate = DateTime.parse(planning['end_date']);
            final irrigationAmount =
                (planning['irrigation_amount'] as num).toDouble();
            final irrigationFrequency = planning['irrigation_frequency'] as int;

            final totalDays = endDate.difference(startDate).inDays + 1;
            final totalWaterConsumption =
                (totalDays / irrigationFrequency) * irrigationAmount;

            double pastTwoDaysConsumption = 0;
            double nextTwoDaysConsumption = 0;
            double untilTodayConsumption = 0;

            for (int i = 0; i < totalDays; i++) {
              final currentDate = startDate.add(Duration(days: i));
              final isIrrigationDay = i % irrigationFrequency == 0;

              if (isIrrigationDay) {
                if (currentDate.isBefore(today.add(const Duration(days: 1)))) {
                  untilTodayConsumption += irrigationAmount;
                }
                if (currentDate.isAfter(pastTwoDays) &&
                    currentDate.isBefore(today)) {
                  pastTwoDaysConsumption += irrigationAmount;
                }
                if (currentDate.isAfter(today) &&
                    currentDate.isBefore(nextTwoDays)) {
                  nextTwoDaysConsumption += irrigationAmount;
                }
              }
            }
            print('Plant: ${planning['plant_name']}');
            print('Total until today: $untilTodayConsumption');
            print('Past 2 days: $pastTwoDaysConsumption');
            print('Next 2 days: $nextTwoDaysConsumption');

            return {
              'plant_name': planning['plant_name'],
              'total_consumption_until_today': untilTodayConsumption,
              'past_two_days_consumption': pastTwoDaysConsumption,
              'next_two_days_consumption': nextTwoDaysConsumption,
            };
          }).toList();

      setState(() {
        waterConsumptionData = processedData;
        isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildBarChart() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: waterConsumptionData.length * 80,
        height: 300,
        child: BarChart(
          BarChartData(
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < waterConsumptionData.length) {
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          waterConsumptionData[index]['plant_name'],
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
            barGroups:
                waterConsumptionData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final data = entry.value;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: data['total_consumption_until_today'] ?? 0.0,
                        color: Colors.blueAccent,
                        width: 20,
                      ),
                    ],
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }

  Widget buildLineChart() {
    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < waterConsumptionData.length) {
                    return SideTitleWidget(
                      meta: meta,
                      child: Text(
                        waterConsumptionData[index]['plant_name'],
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots:
                  waterConsumptionData
                      .asMap()
                      .entries
                      .map(
                        (entry) => FlSpot(
                          entry.key.toDouble(),
                          entry.value['past_two_days_consumption'],
                        ),
                      )
                      .toList(),
              isCurved: true,
              color: Colors.green,
              barWidth: 2,
              dotData: FlDotData(show: true),
            ),
            LineChartBarData(
              spots:
                  waterConsumptionData
                      .asMap()
                      .entries
                      .map(
                        (entry) => FlSpot(
                          entry.key.toDouble(),
                          entry.value['next_two_days_consumption'],
                        ),
                      )
                      .toList(),
              isCurved: true,
              color: Colors.orange,
              barWidth: 2,
              dotData: FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPlantDetails() {
    return Column(
      children:
          waterConsumptionData.map((data) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(
                  data['plant_name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      '💧 Total till today: ${data['total_consumption_until_today'] != null ? data['total_consumption_until_today'].toStringAsFixed(2) : '0.00'} L',
                    ),
                    Text(
                      '📆 Past 2 days: ${data['past_two_days_consumption'].toStringAsFixed(2)} L',
                    ),
                    Text(
                      '📆 Next 2 days: ${data['next_two_days_consumption'].toStringAsFixed(2)} L',
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بيانات استهلاك المياه'),
        backgroundColor: Colors.blueAccent,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'إجمالي استهلاك المياه حتى اليوم',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      buildBarChart(),
                      const SizedBox(height: 24),
                      const Text(
                        'المقارنة بين اليومين السابقين والقادمين',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      buildLineChart(),
                      const SizedBox(height: 24),
                      const Text(
                        'تفاصيل النباتات',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      buildPlantDetails(),
                    ],
                  ),
                ),
              ),
    );
  }
}
