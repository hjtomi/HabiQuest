import 'package:flutter/material.dart';
import 'package:habiquest/firebase/query/habitHandle.dart';
import 'package:habiquest/utils/theme/AppColors.dart';

enum Calendar { daily, weekly, monthly }

enum Difficulties { easy, moderate, hard }

const List<(Difficulties, String)> difficultyOptions = <(Difficulties, String)>[
  (Difficulties.easy, 'Könnyű'),
  (Difficulties.moderate, 'Mérsékelt'),
  (Difficulties.hard, 'Nehéz'),
];

class HabitAdd extends StatefulWidget {
  const HabitAdd({super.key});

  @override
  _HabitAddState createState() => _HabitAddState();
}

class _HabitAddState extends State<HabitAdd> {
  final TextEditingController _cimController = TextEditingController();
  final TextEditingController _megjegyzesController = TextEditingController();
  Difficulties _selectedDifficulty = Difficulties.moderate;
  Calendar _selectedFrequency = Calendar.daily;
  final int _repetitions = 1;
  DateTime? _startDate;
  final bool _isComplete = false;
  final int _streak = 0;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: const Text('Szokás hozzáadása'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildInputField(_cimController, 'Cím'),
                const SizedBox(height: 16),
                _buildInputField(_megjegyzesController, 'Megjegyzés',
                    maxLines: 5),
                const SizedBox(height: 16),
                _buildDifficultySelector(),
                const SizedBox(height: 16),
                _buildFrequencySelector(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: BottomAppBar(
          child: FilledButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                await firestoreAddOrUpdateHabit({
                  'cim': _cimController.text,
                  'megjegyzes': _megjegyzesController.text,
                  'nehezseg': _selectedDifficulty.index,
                  'gyakorisag': _convertFrequency(_selectedFrequency),
                  'ismetles': _repetitions,
                  'kezdes': _startDate,
                  'kesz': _isComplete,
                  'streak': _streak,
                });
                Navigator.of(context).pop();
              }
            },
            child: const Text(
              'Hozzáadás',
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ),
      ),
    );
  }

  int _convertFrequency(Calendar frequency) {
    switch (frequency) {
      case Calendar.daily:
        return 1;
      case Calendar.weekly:
        return 2;
      case Calendar.monthly:
        return 3;
    }
  }

  int _daysInMonth(int month) {
    const daysInMonth = {
      1: 31,
      2: 28,
      3: 31,
      4: 30,
      5: 31,
      6: 30,
      7: 31,
      8: 31,
      9: 30,
      10: 31,
      11: 30,
      12: 31,
    };
    return daysInMonth[month] ?? 30;
  }

  Widget _buildInputField(TextEditingController controller, String label,
      {int maxLines = 1}) {
    return TextFormField(
      validator: (value) =>
          label != "Megjegyzés" && (value == null || value.isEmpty)
              ? 'Nem lehet üres a(z) ${label.toLowerCase()}'
              : null,
      maxLines: maxLines,
      cursorColor: AppColors.white,
      controller: controller,
      decoration: InputDecoration(
        labelStyle: const TextStyle(color: AppColors.white),
        labelText: label,
      ),
    );
  }

  Widget _buildDifficultySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch, // Ensure full width
      mainAxisAlignment: MainAxisAlignment.center, // Center vertically
      children: [
        const Text(
          "Nehézség kiválasztása",
          textAlign: TextAlign.start, // Center-align the text
        ),
        SegmentedButton<Difficulties>(
          showSelectedIcon: false,
          segments: difficultyOptions
              .map((option) => ButtonSegment<Difficulties>(
                    value: option.$1,
                    label: Text(option.$2),
                  ))
              .toList(),
          selected: <Difficulties>{_selectedDifficulty},
          onSelectionChanged: (Set<Difficulties> newSelection) {
            setState(() {
              _selectedDifficulty = newSelection.first;
            });
          },
        ),
      ],
    );
  }

  Widget _buildFrequencySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch, // Ensure full width
      mainAxisAlignment: MainAxisAlignment.center, // Center vertically
      children: [
        const Text(
          "Gyakoriság kiválasztása",
          textAlign: TextAlign.start, // Center-align the text
        ),
        SegmentedButton<Calendar>(
          showSelectedIcon: false,
          segments: const <ButtonSegment<Calendar>>[
            ButtonSegment<Calendar>(
                value: Calendar.daily, label: Text('Naponta')),
            ButtonSegment<Calendar>(
                value: Calendar.weekly, label: Text('Hetente')),
            ButtonSegment<Calendar>(
                value: Calendar.monthly, label: Text('Havonta')),
          ],
          selected: <Calendar>{_selectedFrequency},
          onSelectionChanged: (Set<Calendar> newSelection) {
            setState(() {
              _selectedFrequency = newSelection.first;
            });
          },
        ),
      ],
    );
  }
}
