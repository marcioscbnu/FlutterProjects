import 'package:flutter/material.dart';
import 'package:bibliotecaapi/modelos/livro.dart';
import 'package:bibliotecaapi/servicos/livro_service.dart';

class LivroFormPage extends StatefulWidget {
  const LivroFormPage({super.key});

  @override
  State<LivroFormPage> createState() => _LivroFormPageState();
}

class _LivroFormPageState extends State<LivroFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _autor = TextEditingController();
  final _titulo = TextEditingController();
  final _tema = TextEditingController();

  Livro? _livroEdicao;

  @override
  void dispose() {
    _autor.dispose();
    _titulo.dispose();
    _tema.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is Livro && _livroEdicao == null) {
      _livroEdicao = args;
      _autor.text = args.autor;
      _titulo.text = args.titulo;
      _tema.text = args.tema;
    }
  }

  Future<void> _salvar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final novo = Livro(
      idlivro: _livroEdicao?.idlivro,
      autor: _autor.text.trim(),
      titulo: _titulo.text.trim(),
      tema: _tema.text.trim(),
    );

    try {
      if (_livroEdicao == null) {
        await LivroService.criar(novo);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Livro cadastrado')));
      } else {
        await LivroService.atualizar(novo);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Livro atualizado')));
      }
      if (mounted) Navigator.pop(context, true); // sinaliza “mudou”
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final editando = _livroEdicao != null;
    return Scaffold(
      appBar: AppBar(title: Text(editando ? 'Editar Livro' : 'Novo Livro')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _autor,
                decoration: const InputDecoration(labelText: 'Autor'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe o autor' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titulo,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe o título' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tema,
                decoration: const InputDecoration(labelText: 'Tema'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe o tema' : null,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _salvar,
                icon: const Icon(Icons.save),
                label: Text(editando ? 'Salvar alterações' : 'Cadastrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
