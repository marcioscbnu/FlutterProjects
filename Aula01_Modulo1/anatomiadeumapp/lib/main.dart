import 'package:flutter/material.dart';

void main() {
  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Estrutura Básica Flutter',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Widget> _opcoesDeTela = <Widget>[
    Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Consegui alterar e fazer funcionar meu primeiro app e Flutter',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    ),
    const Center(
      child: Text('Configurações da App', style: TextStyle(fontSize: 24)),
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _indiceSelecionado = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Meu Primeiro App',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
}
