import 'package:flutter/material.dart';

class GererPlanningScreen extends StatelessWidget {
  const GererPlanningScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("📅 إدارة التخطيط"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // خلفية تشير للفلاحة (نخيل، مزرعة، إلخ)
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  "assets/images/farm_background.jpg",
                ), // تأكد من وجود الصورة
                fit: BoxFit.cover,
              ),
            ),
          ),
          // تعتيم خفيف للخلفية
          Container(color: Colors.black.withOpacity(0.4)),
          // المحتوى الرئيسي
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildButton(context, "📋 قائمة التخطيطات", "/planningList"),
                _buildButton(context, "➕ إضافة تخطيط", "/addPlanning"),
                _buildButton(context, "📜 سجل التخطيطات", "/planningHistory"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, String title, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, route);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade700,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          shadowColor: Colors.black45,
          elevation: 8,
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 4,
                color: Colors.black38,
                offset: Offset(1, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
