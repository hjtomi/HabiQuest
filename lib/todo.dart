import 'package:flutter/material.dart';

void main() => runApp(TeendoApp());

class TeendoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blueGrey,
        ),
      ),
      home: TeendoLista(),
    );
  }
}

class TeendoLista extends StatefulWidget {
  @override
  _TeendoListaState createState() => _TeendoListaState();
}

class _TeendoListaState extends State<TeendoLista> {
  List<Map<String, dynamic>> _teendok = [];

  void _hozzaadTeendo(String cim, String megjegyzes, int nehezseg, DateTime hatarido) {
    setState(() {
      _teendok.add({
        'cim': cim,
        'megjegyzes': megjegyzes,
        'nehezseg': nehezseg,
        'hatarido': hatarido,
        'kesz': false,
      });
    });
  }

  void _szerkesztTeendo(int index, String cim, String megjegyzes, int nehezseg, DateTime hatarido) {
    setState(() {
      _teendok[index] = {
        'cim': cim,
        'megjegyzes': megjegyzes,
        'nehezseg': nehezseg,
        'hatarido': hatarido,
        'kesz': false,
      };
    });
  }

  void _kijelolKeszre(int index) {
    setState(() {
      _teendok.removeAt(index);
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teendő Lista'),
        backgroundColor: Colors.blueGrey,
      ),
      body: ListView.builder(
        itemCount: _teendok.length,
        itemBuilder: (context, index) {
          final teendo = _teendok[index];
          return Card(
            color: _nehezsegSzin(teendo['nehezseg']),
            child: ListTile(
              title: Text(
                teendo['cim'],
                style: TextStyle(color: Colors.black), // Fekete szín a címhez
              ),
              subtitle: Text(
                'Határidő: ${teendo['hatarido'].toLocal().toString().split(' ')[0]}',
                style: TextStyle(color: Colors.black), // Fekete szín a szöveghez
              ),
              trailing: Checkbox(
                value: teendo['kesz'],
                onChanged: (_) => _kijelolKeszre(index),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TeendoSzerkesztes(
                      teendo: teendo,
                      index: index,
                      mentTeendo: _szerkesztTeendo,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TeendoHozzaadas(
                hozzaadTeendo: _hozzaadTeendo,
              ),
            ),
          );
        },
      ),
    );
  }
}

class TeendoHozzaadas extends StatefulWidget {
  final Function(String, String, int, DateTime) hozzaadTeendo;

  TeendoHozzaadas({required this.hozzaadTeendo});

  @override
  _TeendoHozzaadasState createState() => _TeendoHozzaadasState();
}

class _TeendoHozzaadasState extends State<TeendoHozzaadas> {
  final TextEditingController _cimController = TextEditingController();
  final TextEditingController _megjegyzesController = TextEditingController();
  int _kivalasztottNehezseg = 1;
  DateTime? _kivalasztottHatarido;

  void _hozzaadas() {
    final cim = _cimController.text;
    final megjegyzes = _megjegyzesController.text;
    if (cim.isNotEmpty && _kivalasztottHatarido != null) {
      widget.hozzaadTeendo(cim, megjegyzes, _kivalasztottNehezseg, _kivalasztottHatarido!);
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
            child: Text(
              'Hozzáadás',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
        title: Text('Teendő hozzáadása'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputField(_cimController, 'Cím'),
            SizedBox(height: 16),
            _buildInputField(_megjegyzesController, 'Megjegyzés', maxLines: 5),
            SizedBox(height: 16),
            _buildNehezsegValaszto(),
            SizedBox(height: 16),
            TextButton(
              onPressed: _valasszHataridot,
              child: Text(
                _kivalasztottHatarido == null
                    ? 'Határidő kiválasztása'
                    : 'Határidő: ${_kivalasztottHatarido!.toLocal().toString().split(' ')[0]}',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label, {int maxLines = 1}) {
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
            backgroundColor: _kivalasztottNehezseg == nehezseg ? _nehezsegSzin(nehezseg) : Colors.grey[600],
            radius: 20,
            child: Text(
              nehezseg.toString(),
              style: TextStyle(color: Colors.white),
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

class TeendoSzerkesztes extends StatefulWidget {
  final Map<String, dynamic> teendo;
  final int index;
  final Function(int, String, String, int, DateTime) mentTeendo;

  TeendoSzerkesztes({required this.teendo, required this.index, required this.mentTeendo});

  @override
  _TeendoSzerkesztesState createState() => _TeendoSzerkesztesState();
}

class _TeendoSzerkesztesState extends State<TeendoSzerkesztes> {
  late TextEditingController _cimController;
  late TextEditingController _megjegyzesController;
  late int _kivalasztottNehezseg;
  late DateTime _kivalasztottHatarido;

  @override
  void initState() {
    super.initState();
    _cimController = TextEditingController(text: widget.teendo['cim']);
    _megjegyzesController = TextEditingController(text: widget.teendo['megjegyzes']);
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
            child: Text(
              'Mentés',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
        title: Text('Teendő szerkesztése'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputField(_cimController, 'Cím'),
            SizedBox(height: 16),
            _buildInputField(_megjegyzesController, 'Megjegyzés', maxLines: 5),
            SizedBox(height: 16),
            _buildNehezsegValaszto(),
            SizedBox(height: 16),
            TextButton(
              onPressed: _valasszHataridot,
              child: Text(
                'Határidő: ${_kivalasztottHatarido.toLocal().toString().split(' ')[0]}',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label, {int maxLines = 1}) {
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
            backgroundColor: _kivalasztottNehezseg == nehezseg ? _nehezsegSzin(nehezseg) : Colors.grey[600],
            radius: 20,
            child: Text(
              nehezseg.toString(),
              style: TextStyle(color: Colors.white),
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
