import 'package:flutter/material.dart';
import 'package:habiquest/utils/theme/AppColors.dart';

class HabitAdd extends StatefulWidget {
  final Function(String, String, int, DateTime) hozzaadTeendo;

  const HabitAdd({super.key, required this.hozzaadTeendo});

  @override
  _HabitAddState createState() => _HabitAddState();
}

class _HabitAddState extends State<HabitAdd> {
  final TextEditingController _cimController = TextEditingController();
  final TextEditingController _megjegyzesController = TextEditingController();
  double _kivalasztottNehezseg = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        actions: [
          TextButton(
            onPressed: () => {},
            child: const Text(
              'Hozzáadás',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
        title: const Text('Teendő hozzáadása'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputField(_cimController, 'Cím'),
            const SizedBox(height: 16),
            _buildInputField(_megjegyzesController, 'Megjegyzés', maxLines: 5),
            const SizedBox(height: 16),
            const Text("Nehézség"),
            _buildNehezsegValaszto(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label,
      {int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      cursorColor: AppColors.white,
      controller: controller,
      decoration: InputDecoration(
        labelStyle: const TextStyle(color: AppColors.white),
        labelText: label,
      ),
    );
  }

  Widget _buildNehezsegValaszto() {
    return Column(
      children: [
        Text(
          _nehezsegSzoveg(_kivalasztottNehezseg.round()),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        SizedBox(
          width: double.infinity,
          child: Slider(
            inactiveColor: Theme.of(context).colorScheme.onPrimary,
            activeColor: _nehezsegSzin(_kivalasztottNehezseg.round()),
            value: _kivalasztottNehezseg,
            max: 3,
            divisions: 3,
            label: _kivalasztottNehezseg.round().toString(),
            onChanged: (double value) {
              setState(() {
                _kivalasztottNehezseg = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Color _nehezsegSzin(int nehezseg) {
    switch (nehezseg) {
      case 0:
        return Colors.blue;
      case 1:
        return Colors.green;
      case 2:
        return Colors.yellow;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _nehezsegSzoveg(int nehezseg) {
    switch (nehezseg) {
      case 0:
        return "Nagyon könnyű";
      case 1:
        return "Nem olyan nehéz";
      case 2:
        return "Megeröltető";
      case 3:
        return "Komfort zónán kívüli";
      default:
        return "";
    }
  }
}
