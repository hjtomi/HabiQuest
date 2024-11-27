import 'package:flutter/material.dart';

class CharacterMenuPage extends StatefulWidget {
  const CharacterMenuPage({super.key});

  @override
  _CharacterMenuPageState createState() => _CharacterMenuPageState();
}

class _CharacterMenuPageState extends State<CharacterMenuPage> {
  // Data structure for items
  final Map<String, List<String>> items = {
    'Hats': ['Hat 1', 'Hat 2', 'Hat 3', 'Hat 4'],
    'Shirts': ['Shirt 1', 'Shirt 2', 'Shirt 3', 'Shirt 4'],
    'Pants': ['Pants 1', 'Pants 2', 'Pants 3', 'Pants 4'],
  };

  // Selected items
  String selectedHat = 'Hat 1';
  String selectedShirt = 'Shirt 1';
  String selectedPants = 'Pants 1';

  // Update the selection
  void updateSelection(String category, String newItem) {
    setState(() {
      if (category == 'Hats') {
        selectedHat = newItem;
      } else if (category == 'Shirts') {
        selectedShirt = newItem;
      } else if (category == 'Pants') {
        selectedPants = newItem;
      }
    });
  }

  // Show item options in a popup dialog
  void showItemOptions(String category) {
    final options = items[category] ?? [];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select a $category"),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 2,
              ),
              itemCount: options.length,
              itemBuilder: (BuildContext context, int index) {
                return ElevatedButton(
                  onPressed: () {
                    updateSelection(category, options[index]);
                    Navigator.pop(context); // Close the dialog
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(options[index]),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog without selection
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  Widget buildStickFigure() {
  return Stack(
    alignment: Alignment.center,
    children: [
      CustomPaint(
        size: const Size(300, 500), // Larger size for the stick figure
        painter: StickFigurePainter(sizeFactor: 2.0), // Scaled size
      ),
      Positioned(
        top: 60, // Adjusted positions for text based on new size
        child: Text(
          selectedHat,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      Positioned(
        top: 200,
        child: Text(
          selectedShirt,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      Positioned(
        top: 400,
        child: Text(
          selectedPants,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    ],
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Character Menu"),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Left-hand side: Character display with stick figure
              Expanded(
                flex: 5,
                child: Center(
                  child: buildStickFigure(),
                ),
              ),
              // Right-hand side: Menu options
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    MenuButton(
                      label: "Hats",
                      onPressed: () => showItemOptions("Hats"),
                    ),
                    const SizedBox(height: 16),
                    MenuButton(
                      label: "Shirts",
                      onPressed: () => showItemOptions("Shirts"),
                    ),
                    const SizedBox(height: 16),
                    MenuButton(
                      label: "Pants",
                      onPressed: () => showItemOptions("Pants"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget for reusable menu buttons
class MenuButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const MenuButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Theme.of(context).colorScheme.onSecondary,
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}

// Custom painter for stick figure
class StickFigurePainter extends CustomPainter {
  final double sizeFactor; // Scale the stickman size

  StickFigurePainter({this.sizeFactor = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white // Set color to white
      ..strokeWidth = 4.0 * sizeFactor // Thicker lines for a larger figure
      ..style = PaintingStyle.stroke;

    // Scaled positions
    final headRadius = 20.0 * sizeFactor;
    final headCenter = Offset(size.width / 2, 50 * sizeFactor);
    final bodyStart = Offset(size.width / 2, 70 * sizeFactor);
    final bodyEnd = Offset(size.width / 2, 150 * sizeFactor);
    final armStartLeft = Offset(size.width / 2 - 30 * sizeFactor, 100 * sizeFactor);
    final armEndRight = Offset(size.width / 2 + 30 * sizeFactor, 100 * sizeFactor);
    final legStartLeft = Offset(size.width / 2, 150 * sizeFactor);
    final legEndLeft = Offset(size.width / 2 - 30 * sizeFactor, 200 * sizeFactor);
    final legEndRight = Offset(size.width / 2 + 30 * sizeFactor, 200 * sizeFactor);

    // Draw head
    canvas.drawCircle(headCenter, headRadius, paint);

    // Draw body
    canvas.drawLine(bodyStart, bodyEnd, paint);

    // Draw arms
    canvas.drawLine(armStartLeft, armEndRight, paint);

    // Draw legs
    canvas.drawLine(legStartLeft, legEndLeft, paint);
    canvas.drawLine(legStartLeft, legEndRight, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
