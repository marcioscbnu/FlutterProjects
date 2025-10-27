import 'package:flutter/material.dart';

void main() => runApp(const Aplicativo());

class Aplicativo extends StatelessWidget {
  const Aplicativo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Rota inicial (tela de origem)
      initialRoute: '/',
      // Mapa de rotas nomeadas
      routes: {
        '/': (_) => const PaginaOrigem(),
        '/destino': (_) => const PaginaDestino(),
      },
    );
  }
}

/// Tela de ORIGEM: tem um botão que navega por nome para '/destino'
/// e envia uma mensagem nos 'arguments'.
class PaginaOrigem extends StatelessWidget {
  const PaginaOrigem({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Origem')),
      body: Center(
        child: ElevatedButton(
          // Ao pressionar, navega usando rota nomeada
          onPressed: () {
            Navigator.pushNamed(
              context, // contexto atual
              '/destino', // nome da rota de destino
              arguments: null, // dado enviado
            );
          },
          child: const Text('Ir para Destino'),
        ),
      ),
    );
  }
}

/// Tela de DESTINO: lê os 'arguments' enviados pela origem
/// e exibe o texto; tem um botão para voltar.
class PaginaDestino extends StatelessWidget {
  const PaginaDestino({super.key});

  @override
  Widget build(BuildContext context) {
    // Recupera o que foi enviado em 'arguments'
    final args = ModalRoute.of(context)!.settings.arguments;
    // Faz uma validação simples de tipo; se não vier String, usa padrão
    final mensagem = args is String ? args : 'Sem mensagem';

    return Scaffold(
      appBar: AppBar(title: const Text('Destino')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(mensagem, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            ElevatedButton(
              // Volta para a origem (pop desempilha a tela atual)
              onPressed: () => Navigator.pop(context),
              child: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
}
