import 'package:flutter/material.dart';
import 'package:bibliotecaapi/modelos/livro.dart';

class LivroDetalhesPage extends StatelessWidget {
  const LivroDetalhesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    final livro = args is Livro ? args : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do Livro')),
      body: livro == null
          ? const Center(child: Text('Livro inválido'))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ID: ${livro.idlivro ?? '-'}'),
                  const SizedBox(height: 8),
                  Text('Autor: ${livro.autor}'),
                  const SizedBox(height: 8),
                  Text('Título: ${livro.titulo}'),
                  const SizedBox(height: 8),
                  Text('Tema: ${livro.tema}'),
                ],
              ),
            ),
    );
  }
}
