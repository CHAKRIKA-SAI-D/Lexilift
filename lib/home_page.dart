import 'package:flutter/material.dart';
import 'feature_page.dart';

class HomePage extends StatelessWidget {
  final String selectedFont;
  final Function(String) onFontChanged;

  const HomePage({
    super.key,
    required this.selectedFont,
    required this.onFontChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🔹 App Logo
              Image.asset(
                'assets/image.png',
                height: 150,
              ),
              const SizedBox(height: 30),

              // 🔹 Font Toggle Dropdown
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Font: ",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: selectedFont,
                    items: const [
                      DropdownMenuItem(value: "Normal", child: Text("Normal")),
                      DropdownMenuItem(
                          value: "OpenDyslexic", child: Text("OpenDyslexic")),
                      DropdownMenuItem(value: "Lexend", child: Text("Lexend")),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        onFontChanged(value);
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // 🔹 Main Heading
              const Text(
                'Scan • Read • Listen',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),

              // 🔹 Tagline
              const Text(
                'A Dyslexia-Friendly Reading Companion',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 60),

              // 🔹 Get Started Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FeaturePage(
                        selectedFont: selectedFont,
                        onFontChanged: onFontChanged,
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Get Started',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
