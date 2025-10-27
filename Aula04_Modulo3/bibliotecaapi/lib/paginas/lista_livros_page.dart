import 'package:flutter/material.dart';
import 'package:bibliotecaapi/modelos/livro.dart';
import 'package:bibliotecaapi/servicos/livro_service.dart';
import 'package:bibliotecaapi/core/route_observer.dart';

class ListaLivrosPage extends StatefulWidget {
  const ListaLivrosPage({super.key});

  @override
  State<ListaLivrosPage> createState() => _ListaLivrosPageState();
}

class _ListaLivrosPageState extends State<ListaLivrosPage> with RouteAware {
  late Future<List<Livro>> _future;

  @override
  void initState() {
    super.initState();
    _future = LivroService.listar();
  }

  // Inscreve esta rota no observer quando ela entra no contexto
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  // Desinscreve ao destruir
  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  // Chamado quando outra rota acima desta é "popada" (voltamos a vê-la)
  @override
  void didPopNext() {
    // Voltou de /form ou /detalhes? Recarrega SEMPRE.
    _refresh();
  }

  Future<void> _refresh() async {
    setState(
      () => _future = LivroService.listar(),
    ); // novo Future -> FutureBuilder refaz
  }

  Future<void> _abrirCadastro([Livro? livro]) async {
    await Navigator.pushNamed(context, '/form', arguments: livro);
    if (!mounted) return;
    // Redundância: além do didPopNext, também recarregamos aqui
    await _refresh();
  }

  Future<void> _abrirDetalhes(Livro livro) async {
    await Navigator.pushNamed(context, '/detalhes', arguments: livro);
    if (!mounted) return;
    await _refresh();
  }

  Future<void> _excluir(Livro livro) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir livro'),
        content: Text('Tem certeza que deseja excluir "${livro.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await LivroService.excluir(livro.idlivro!);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Livro excluído')));
        _refresh();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Livros')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirCadastro(),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Livro>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(child: Text('Erro: ${snap.error}'));
            }
            final dados = snap.data ?? [];
            if (dados.isEmpty) {
              return const Center(child: Text('Nenhum livro cadastrado'));
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: dados.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final l = dados[i];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(l.idlivro?.toString() ?? '?'),
                  ),
                  title: Text(l.titulo),
                  subtitle: Text(l.autor),
                  onTap: () => _abrirDetalhes(l),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _abrirCadastro(l),
                        tooltip: 'Editar',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _excluir(l),
                        tooltip: 'Excluir',
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
