import 'package:flutter/material.dart';
import 'package:habiquest/firebase/query/habitHandle.dart';
import 'package:habiquest/utils/theme/AppColors.dart';

enum Calendar { daily, weekly, monthly }

class HabitAdd extends StatefulWidget {
  const HabitAdd({super.key});

  @override
  _HabitAddState createState() => _HabitAddState();
}

class _HabitAddState extends State<HabitAdd> {
  final TextEditingController _cimController = TextEditingController();
  final TextEditingController _megjegyzesController = TextEditingController();
  double _kivalasztottNehezseg = 1;
  int _kivalasztottGyakorisag = 1; 
  int _kivalasztottIsmetles = 1; 
  Calendar calendarView = Calendar.daily;
  DateTime? _kezdesIdo;
  bool _kesz = false;
  int _streak = 0;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        actions: [
          TextButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                await firestoreAddHabit({
                  'cim': _cimController.text,
                  'megjegyzes': _megjegyzesController.text,
                  'nehezseg': _kivalasztottNehezseg,
                  'gyakorisag': _convertGyakorisag(_kivalasztottGyakorisag),
                  'ismetles': _kivalasztottIsmetles,
                  'kezdes': _kezdesIdo,
                  'kesz': _kesz,
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
        ],
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
                _buildInputField(_megjegyzesController, 'Megjegyzés', maxLines: 5),
                const SizedBox(height: 16),
                _buildNehezsegValaszto(),
                const SizedBox(height: 16),
                _buildGyakorisagValaszto(),
                const SizedBox(height: 16),
                _buildIsmetlesValaszto(),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () async {
                    DateTime? datum = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (datum != null) {
                      setState(() {
                        _kezdesIdo = datum;
                      });
                    }
                  },
                  child: Text(
                    _kezdesIdo == null
                        ? 'Kezdés idejének kiválasztása'
                        : 'Kezdés ideje: ${_kezdesIdo!.toLocal().toString().split(' ')[0]}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _convertGyakorisag(int gyakorisag) {
    switch (gyakorisag) {
      case 0:
        return 1;
      case 1:
        return 7;
      case 2:
        final month = DateTime.now().month;
        return _daysInMonth(month);
      default:
        return 1;
    }
  }

  int _daysInMonth(int month) {
    const daysInMonth = {
      1: 31, 2: 28, 3: 31, 4: 30, 5: 31, 6: 30,
      7: 31, 8: 31, 9: 30, 10: 31, 11: 30, 12: 31
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
            inactiveColor: AppColors.white,
            activeColor: AppColors.secondary,
            value: _kivalasztottNehezseg,
            min: 1,
            max: 4,
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

  Widget _buildGyakorisagValaszto() {
    return SegmentedButton<Calendar>(
      segments: const <ButtonSegment<Calendar>>[
        ButtonSegment<Calendar>(value: Calendar.daily, label: Text('Naponta')),
        ButtonSegment<Calendar>(value: Calendar.weekly, label: Text('Hetente')),
        ButtonSegment<Calendar>(value: Calendar.monthly, label: Text('Havonta')),
      ],
      selected: <Calendar>{calendarView},
      onSelectionChanged: (Set<Calendar> newSelection) {
        setState(() {
          calendarView = newSelection.first;
        });
      },
    );
  }

  Widget _buildIsmetlesValaszto() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Ismétlődés (Hány alkalom):"),
        TextField(
          keyboardType: TextInputType.number,
          controller: TextEditingController(text: _kivalasztottIsmetles.toString()),
          onChanged: (value) {
            setState(() {
              _kivalasztottIsmetles = int.tryParse(value) ?? 1;
            });
          },
          decoration: InputDecoration(
            labelText: "Ismétlődés",
            labelStyle: TextStyle(color: AppColors.white),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.secondary),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.secondary),
            ),
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