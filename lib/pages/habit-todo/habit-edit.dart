import 'package:flutter/material.dart';

class HabitEdit extends StatefulWidget {
  final Map<String, dynamic> teendo;
  final int index;
  final Function(int, String, String, int, DateTime) mentTeendo;

  const HabitEdit(
      {super.key,
      required this.teendo,
      required this.index,
      required this.mentTeendo});

  @override
  _HabitEditState createState() => _HabitEditState();
}

class _HabitEditState extends State<HabitEdit> {
  late TextEditingController _cimController;
  late TextEditingController _megjegyzesController;
  late int _kivalasztottNehezseg;
  late DateTime _kivalasztottHatarido;

  @override
  void initState() {
    super.initState();
    _cimController = TextEditingController(text: widget.teendo['cim']);
    _megjegyzesController =
        TextEditingController(text: widget.teendo['megjegyzes']);
    _kivalasztottNehezseg = widget.teendo['nehezseg'];
    _kivalasztottHatarido = widget.teendo['hatarido'];
  }

  void _mentes() {
    widget.mentTeendo(
      widget.index,
      _cimController.text,
      _megjegyzesController.text,
      _kivalasztottNehezseg,
      _kivalasztottHatarido,
    );
    Navigator.of(context).pop();
  }

  void _valasszHataridot() async {
    DateTime? datum = await showDatePicker(
      context: context,
      initialDate: _kivalasztottHatarido,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (datum != null) {
      setState(() {
        _kivalasztottHatarido = datum;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: _mentes,
            child: const Text(
              'Mentés',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
        title: const Text('Teendő szerkesztése'),
        backgroundColor: Colors.blueGrey,
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
            _buildNehezsegValaszto(),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _valasszHataridot,
              child: Text(
                'Határidő: ${_kivalasztottHatarido.toLocal().toString().split(' ')[0]}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label,
      {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildNehezsegValaszto() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(5, (index) {
        final nehezseg = index + 1;
        return GestureDetector(
          onTap: () {
            setState(() {
              _kivalasztottNehezseg = nehezseg;
            });
          },
          child: CircleAvatar(
            backgroundColor: _kivalasztottNehezseg == nehezseg
                ? _nehezsegSzin(nehezseg)
                : Colors.grey[600],
            radius: 20,
            child: Text(
              nehezseg.toString(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      }),
    );
  }

  Color _nehezsegSzin(int nehezseg) {
    switch (nehezseg) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.yellow;
      case 4:
        return Colors.orange;
      case 5:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
