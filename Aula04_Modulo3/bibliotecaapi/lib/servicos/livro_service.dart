import 'package:bibliotecaapi/modelos/livro.dart';
import 'api_client.dart';

class LivroService {
  static Future<List<Livro>> listar() async {
    final t = DateTime.now().millisecondsSinceEpoch;
    final list = await ApiClient.getJsonList('/livros?t=$t'); // evita cache
    return list.map((e) => Livro.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<Livro> obter(int id) async {
    final t = DateTime.now().millisecondsSinceEpoch;
    final j = await ApiClient.getJson('/livros/$id?t=$t'); // evita cache
    return Livro.fromJson(j);
  }

  static Future<Livro> criar(Livro livro) async {
    final j = await ApiClient.postJson('/livros', livro.toJson());
    return Livro.fromJson(j);
  }

  static Future<Livro> atualizar(Livro livro) async {
    if (livro.idlivro == null)
      throw Exception('idlivro obrigatório para atualizar');
    final j = await ApiClient.putJson(
      '/livros/${livro.idlivro}',
      livro.toJson(),
    );
    return Livro.fromJson(j);
  }

  static Future<void> excluir(int id) async {
    await ApiClient.delete('/livros/$id');
  }
}
