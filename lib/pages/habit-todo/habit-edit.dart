import 'package:flutter/material.dart';
import 'package:habiquest/utils/theme/AppColors.dart';

enum Calendar { daily, weekly, monthly }

class HabitEdit extends StatefulWidget {
  final Map<String, dynamic> teendo;
  final int index;
  final Function(int, String, String, int, int, int, DateTime?, bool, int)
      mentTeendo;

  const HabitEdit({
    super.key,
    required this.teendo,
    required this.index,
    required this.mentTeendo,
  });

  @override
  _HabitEditState createState() => _HabitEditState();
}

class _HabitEditState extends State<HabitEdit> {
  late TextEditingController _cimController;
  late TextEditingController _megjegyzesController;
  double _kivalasztottNehezseg = 1;
  int _kivalasztottGyakorisag = 1;
  int _kivalasztottIsmetles = 1;
  Calendar calendarView = Calendar.daily;
  DateTime? _kezdesIdo;
  bool _kesz = false;
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _cimController = TextEditingController(text: widget.teendo['cim']);
    _megjegyzesController =
        TextEditingController(text: widget.teendo['megjegyzes']);
    _kivalasztottNehezseg = widget.teendo['nehezseg'].toDouble();
    _kivalasztottGyakorisag = widget.teendo['gyakorisag'];
    _kivalasztottIsmetles = widget.teendo['ismetles'];
    _kezdesIdo = DateTime.parse(widget.teendo['kezdes']);
    _kesz = widget.teendo['kesz'];
    _streak = widget.teendo['streak'];
    calendarView = Calendar.values.firstWhere(
      (e) => e.index == widget.teendo['gyakorisag'],
      orElse: () => Calendar.daily,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        actions: [
          TextButton(
            onPressed: () {
              widget.mentTeendo(
                widget.index,
                _cimController.text,
                _megjegyzesController.text,
                _kivalasztottNehezseg.toInt(),
                _convertGyakorisag(_kivalasztottGyakorisag),
                _kivalasztottIsmetles,
                _kezdesIdo,
                _kesz,
                _streak,
              );
              Navigator.of(context).pop();
            },
            child: const Text(
              'Mentés',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
        title: const Text('Szokás szerkesztése'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _cimController,
              decoration: const InputDecoration(labelText: 'Cím'),
            ),
            TextFormField(
              controller: _megjegyzesController,
              decoration: const InputDecoration(labelText: 'Megjegyzés'),
              maxLines: 5,
            ),
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
                  initialDate: _kezdesIdo ?? DateTime.now(),
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
                    ? 'Kezdés ideje kiválasztása'
                    : 'Kezdés ideje: ${_kezdesIdo!.toLocal().toString().split(' ')[0]}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _convertGyakorisag(int gyakorisag) {
    switch (gyakorisag) {
      case 0: // naponta
        return 1;
      case 1: // hetente
        return 7;
      case 2: // havonta
        final month = DateTime.now().month;
        return _daysInMonth(month);
      default:
        return 1;
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
      12: 31
    };
    return daysInMonth[month] ?? 30;
  }

  Widget _buildNehezsegValaszto() {
    return Column(
      children: [
        Text(
          _nehezsegSzoveg(_kivalasztottNehezseg.round()),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        Slider(
          value: _kivalasztottNehezseg,
          min: 1,
          max: 4,
          divisions: 3,
          onChanged: (value) {
            setState(() {
              _kivalasztottNehezseg = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildGyakorisagValaszto() {
    return SegmentedButton<Calendar>(
      segments: const <ButtonSegment<Calendar>>[
        ButtonSegment<Calendar>(value: Calendar.daily, label: Text('Naponta')),
        ButtonSegment<Calendar>(value: Calendar.weekly, label: Text('Hetente')),
        ButtonSegment<Calendar>(
            value: Calendar.monthly, label: Text('Havonta')),
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
      children: [
        const Text("Ismétlődés (Hány alkalom):"),
        TextField(
          keyboardType: TextInputType.number,
          controller:
              TextEditingController(text: _kivalasztottIsmetles.toString()),
          onChanged: (value) {
            setState(() {
              _kivalasztottIsmetles = int.tryParse(value) ?? 1;
            });
          },
          decoration: const InputDecoration(
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
