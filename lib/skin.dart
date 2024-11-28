import 'package:flutter/material.dart';

class CharacterSelector extends StatefulWidget {
  const CharacterSelector({super.key});

  @override
  _CharacterSelectorState createState() => _CharacterSelectorState();
}

class _CharacterSelectorState extends State<CharacterSelector> {
  // Paths to character images stored in the lib/characters folder
  final List<String> characterImages = [
    'lib/assets/skins/skin-1.png',
    'lib/assets/skins/skin-2.png',
    'lib/assets/skins/skin-3.png',
  ];

  int currentIndex = 0;

  void _onLeftSwipe() {
    setState(() {
      currentIndex = (currentIndex > 0) ? currentIndex - 1 : characterImages.length - 1;
    });
  }

  void _onRightSwipe() {
    setState(() {
      currentIndex = (currentIndex < characterImages.length - 1) ? currentIndex + 1 : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Character'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Character Display
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    characterImages[currentIndex],
                    fit: BoxFit.contain,
                    width: 600,
                    height: 475,
                  ),
                  // Swipe arrows
                  Positioned(
                    left: 1,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_left, size: 150, color: Colors.white),
                      onPressed: _onLeftSwipe,
                    ),
                  ),
                  Positioned(
                    right: 1,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_right, size: 150, color: Colors.white),
                      onPressed: _onRightSwipe,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Current Character Label
            Text(
              'Character ${currentIndex + 1}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Select Button
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Character ${currentIndex + 1} selected!')),
                );
              },
              child: const Text('Select Character'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
