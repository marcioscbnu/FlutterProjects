import 'package:flutter/material.dart';

// ---------- PONTO DE ENTRADA ----------
void main() => runApp(const Aplicativo());

// ---------- APP (rotas nomeadas) ----------
class Aplicativo extends StatelessWidget {
  const Aplicativo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rotas Nomeadas',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (_) => const PaginaInicial(),
        '/detalhes': (_) => const PaginaDetalhes(),
        '/finalizacao': (_) => const PaginaFinalizacao(),
      },
      onUnknownRoute: (_) => MaterialPageRoute(
        builder: (_) => const PaginaNaoEncontrada(),
      ),
    );
  }
}

// ---------- MODELO DE DADOS ----------
class Produto {
  final String id;
  final String nome;
  final double preco;
  const Produto({required this.id, required this.nome, required this.preco});
}

// ---------- PÁGINA INICIAL ----------
class PaginaInicial extends StatelessWidget {
  const PaginaInicial({super.key});

  @override
  Widget build(BuildContext context) {
    final produtos = const [
      Produto(id: 'p1', nome: 'Teclado', preco: 349.90),
      Produto(id: 'p2', nome: 'Mouse', preco: 199.00),
      Produto(id: 'p3', nome: 'Headset', preco: 289.50),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Página Inicial')),
      body: ListView.separated(
        itemCount: produtos.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final produto = produtos[i];
          return ListTile(
            title: Text(produto.nome),
            subtitle: Text('R\$ ${produto.preco.toStringAsFixed(2)}'),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/detalhes',
                arguments: produto,
              );
            },
            trailing: IconButton(
              icon: const Icon(Icons.shopping_cart_checkout),
              onPressed: () async {
                final resultado = await Navigator.pushNamed(
                  context,
                  '/finalizacao',
                  arguments: produto,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Finalização: $resultado')),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}

// ---------- PÁGINA DETALHES ----------
class PaginaDetalhes extends StatelessWidget {
  const PaginaDetalhes({super.key});

  @override
  Widget build(BuildContext context) {
    final argumentos = ModalRoute.of(context)!.settings.arguments;
    final produto = argumentos is Produto
        ? argumentos
        : const Produto(id: 'x', nome: 'Produto inválido', preco: 0);

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do Produto')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${produto.id}'),
            Text('Nome: ${produto.nome}'),
            Text('Preço: R\$ ${produto.preco.toStringAsFixed(2)}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- PÁGINA FINALIZAÇÃO ----------
class PaginaFinalizacao extends StatefulWidget {
  const PaginaFinalizacao({super.key});
  @override
  State<PaginaFinalizacao> createState() => _EstadoPaginaFinalizacao();
}

class _EstadoPaginaFinalizacao extends State<PaginaFinalizacao> {
  bool aceitouTermos = false;

  @override
  Widget build(BuildContext context) {
    final produto = ModalRoute.of(context)!.settings.arguments as Produto;

    return Scaffold(
      appBar: AppBar(title: const Text('Finalização da Compra')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Confirmar compra de: ${produto.nome}'),
            Text('Preço: R\$ ${produto.preco.toStringAsFixed(2)}'),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Aceito os termos'),
              value: aceitouTermos,
              onChanged: (v) => setState(() => aceitouTermos = v),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, 'cancelado'),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: aceitouTermos
                        ? () => Navigator.pop(context, 'sucesso')
                        : null,
                    child: const Text('Finalizar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- PÁGINA 404 ----------
class PaginaNaoEncontrada extends StatelessWidget {
  const PaginaNaoEncontrada({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('404 — Rota não encontrada')),
    );
  }
}
