import 'package:flutter/material.dart';
import 'package:bibliotecaapi/paginas/lista_livros_page.dart';
import 'package:bibliotecaapi/paginas/livro_form_page.dart';
import 'package:bibliotecaapi/paginas/livro_detalhes_page.dart';
import 'package:bibliotecaapi/core/route_observer.dart';

void main() => runApp(const AppLivros());

class AppLivros extends StatelessWidget {
  const AppLivros({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cadastro de Livros',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      initialRoute: '/',
      routes: {
        '/': (_) => const ListaLivrosPage(),
        '/form': (_) => const LivroFormPage(),
        '/detalhes': (_) => const LivroDetalhesPage(),
      },
      navigatorObservers: [routeObserver], // <-- obrigatório p/ didPopNext
    );
  }
}
