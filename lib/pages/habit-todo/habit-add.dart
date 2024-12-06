import 'package:flutter/material.dart';
import 'package:habiquest/firebase/query/habitHandle.dart';
import 'package:habiquest/utils/theme/AppColors.dart';

enum Calendar { daily, weekly, monthly }

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
  Calendar calendarView = Calendar.daily;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        actions: [
          TextButton(
            onPressed: () async => {
              if (_formKey.currentState!.validate())
                {
                  await firestoreAddHabit({
                    'cim': _cimController.text,
                    'megjegyzes': _megjegyzesController.text,
                    'nehezseg': _kivalasztottNehezseg,
                    'gyakorisag': calendarView.name,
                  }),
                  Navigator.of(context).pop()
                }
            },
            child: const Text(
              'Hozzáadás',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
        title: const Text('Teendő hozzáadása'),
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
                const Text("Nehézség"),
                _buildNehezsegValaszto(),
                const SizedBox(height: 16),
                const Text("Gyakoriság"),
                const SizedBox(height: 16),
                _buildGyakorisagValaszto(),
              ],
            ),
          ),
        ),
      ),
    );
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

  Widget _buildGyakorisagValaszto() {
    return SegmentedButton<Calendar>(
      segments: const <ButtonSegment<Calendar>>[
        ButtonSegment<Calendar>(
            value: Calendar.daily,
            label: Text('Naponta'),
            icon: Icon(Icons.today_rounded)),
        ButtonSegment<Calendar>(
            value: Calendar.weekly,
            label: Text('Hetente'),
            icon: Icon(Icons.calendar_view_week)),
        ButtonSegment<Calendar>(
            value: Calendar.monthly,
            label: Text('Havonta'),
            icon: Icon(Icons.calendar_view_month)),
      ],
      selected: <Calendar>{calendarView},
      onSelectionChanged: (Set<Calendar> newSelection) {
        setState(() {
          calendarView = newSelection.first;
        });
      },
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
            activeColor: Theme.of(context).colorScheme.secondary,
            value: _kivalasztottNehezseg,
            max: 3,
            divisions: 3,
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
