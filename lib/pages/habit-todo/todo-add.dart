import 'package:flutter/material.dart';

class TodoAdd extends StatefulWidget {
  final Function(String, String, int, DateTime) hozzaadTeendo;

  const TodoAdd({super.key, required this.hozzaadTeendo});

  @override
  _TodoAddState createState() => _TodoAddState();
}

class _TodoAddState extends State<TodoAdd> {
  final TextEditingController _cimController = TextEditingController();
  final TextEditingController _megjegyzesController = TextEditingController();
  int _kivalasztottNehezseg = 1;
  DateTime? _kivalasztottHatarido;

  void _hozzaadas() {
    final cim = _cimController.text;
    final megjegyzes = _megjegyzesController.text;
    if (cim.isNotEmpty && _kivalasztottHatarido != null) {
      widget.hozzaadTeendo(
          cim, megjegyzes, _kivalasztottNehezseg, _kivalasztottHatarido!);
      Navigator.of(context).pop();
    }
  }

  void _valasszHataridot() async {
    DateTime? datum = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
            onPressed: _hozzaadas,
            child: const Text(
              'Hozzáadás',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
        title: const Text('Teendő hozzáadása'),
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
                _kivalasztottHatarido == null
                    ? 'Határidő kiválasztása'
                    : 'Határidő: ${_kivalasztottHatarido!.toLocal().toString().split(' ')[0]}',
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