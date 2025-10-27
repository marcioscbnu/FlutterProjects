import 'dart:convert';
import 'dart:io';

import 'package:mysql_client/mysql_client.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

// -----------------------------------------------------------------------------
// Configuração do banco (credenciais no código)
// -----------------------------------------------------------------------------
const String _dbHost = '127.0.0.1';
const int _dbPort = 3306;
const String _dbUser = 'usuario'; // <- ajuste
const String _dbPassword = 'senha'; // <- ajuste
const String _dbDatabase = 'biblioteca';

Future<MySQLConnection> _openConn() async {
  final conn = await MySQLConnection.createConnection(
    host: _dbHost,
    port: _dbPort,
    userName: _dbUser,
    password: _dbPassword,
    databaseName: _dbDatabase,
    secure: true, // se seu usuário usa caching_sha2_password, mantenha true
  );
  await conn.connect();
  return conn;
}

// Converte uma linha do mysql_client para Map<String, dynamic>
Map<String, dynamic> _rowToLivro(dynamic row) {
  final idStr = row.colByName('idlivro')?.toString();
  final autor = row.colByName('autor')?.toString() ?? '';
  final titulo = row.colByName('titulo')?.toString() ?? '';
  final tema = row.colByName('tema')?.toString() ?? '';
  return {
    'idlivro': int.tryParse(idStr ?? '') ?? 0,
    'autor': autor,
    'titulo': titulo,
    'tema': tema,
  };
}

void main(List<String> args) async {
  final router = Router();

  // Healthcheck
  router.get('/health', (Request req) => Response.ok('OK'));

  // GET /livros -> lista todos (com anti-cache)
  router.get('/livros', (Request req) async {
    final conn = await _openConn();
    try {
      final rs = await conn.execute(
        'SELECT idlivro, autor, titulo, tema FROM livro ORDER BY idlivro DESC',
      );
      final data = [for (final row in rs.rows) _rowToLivro(row)];
      return Response.ok(
        jsonEncode(data),
        headers: {
          'Content-Type': 'application/json',
          'Cache-Control': 'no-store', // <-- evita cache no navegador/proxy
        },
      );
    } finally {
      await conn.close();
    }
  });

  // GET /livros/<id> -> 1 registro (com anti-cache)
  router.get('/livros/<id|[0-9]+>', (Request req, String id) async {
    final conn = await _openConn();
    try {
      final rs = await conn.execute(
        'SELECT idlivro, autor, titulo, tema FROM livro WHERE idlivro = :id',
        {'id': id.toString()},
      );
      if (rs.rows.isEmpty) {
        return Response(
          404,
          body: jsonEncode({'error': 'Livro não encontrado'}),
          headers: {
            'Content-Type': 'application/json',
            'Cache-Control': 'no-store'
          },
        );
      }
      final data = _rowToLivro(rs.rows.first);
      return Response.ok(
        jsonEncode(data),
        headers: {
          'Content-Type': 'application/json',
          'Cache-Control': 'no-store'
        },
      );
    } finally {
      await conn.close();
    }
  });

  // POST /livros -> cria
  router.post('/livros', (Request req) async {
    final body = await req.readAsString();
    Map<String, dynamic> json;
    try {
      json = (jsonDecode(body) as Map).map((k, v) => MapEntry('$k', v));
    } catch (_) {
      return Response(400,
          body: jsonEncode({'error': 'JSON inválido'}),
          headers: {'Content-Type': 'application/json'});
    }

    final autor = (json['autor'] ?? '').toString().trim();
    final titulo = (json['titulo'] ?? '').toString().trim();
    final tema = (json['tema'] ?? '').toString().trim();

    if (autor.isEmpty || titulo.isEmpty || tema.isEmpty) {
      return Response(400,
          body:
              jsonEncode({'error': 'Campos obrigatórios: autor, titulo, tema'}),
          headers: {'Content-Type': 'application/json'});
    }

    final conn = await _openConn();
    try {
      final rs = await conn.execute(
        'INSERT INTO livro (autor, titulo, tema) VALUES (:autor, :titulo, :tema)',
        {'autor': autor, 'titulo': titulo, 'tema': tema},
      );
      final insertedIdStr = rs.lastInsertID?.toString() ?? '0';
      final id = int.tryParse(insertedIdStr) ?? 0;

      return Response(
        201,
        body: jsonEncode(
            {'idlivro': id, 'autor': autor, 'titulo': titulo, 'tema': tema}),
        headers: {'Content-Type': 'application/json'},
      );
    } finally {
      await conn.close();
    }
  });

  // PUT /livros/<id> -> atualiza
  router.put('/livros/<id|[0-9]+>', (Request req, String id) async {
    final body = await req.readAsString();
    Map<String, dynamic> json;
    try {
      json = (jsonDecode(body) as Map).map((k, v) => MapEntry('$k', v));
    } catch (_) {
      return Response(400,
          body: jsonEncode({'error': 'JSON inválido'}),
          headers: {'Content-Type': 'application/json'});
    }

    final autor = (json['autor'] ?? '').toString().trim();
    final titulo = (json['titulo'] ?? '').toString().trim();
    final tema = (json['tema'] ?? '').toString().trim();

    if (autor.isEmpty || titulo.isEmpty || tema.isEmpty) {
      return Response(400,
          body:
              jsonEncode({'error': 'Campos obrigatórios: autor, titulo, tema'}),
          headers: {'Content-Type': 'application/json'});
    }

    final conn = await _openConn();
    try {
      final rs = await conn.execute(
        'UPDATE livro SET autor = :autor, titulo = :titulo, tema = :tema WHERE idlivro = :id',
        {'autor': autor, 'titulo': titulo, 'tema': tema, 'id': id.toString()},
      );
      if ((rs.affectedRows ?? 0) == 0) {
        return Response(404,
            body: jsonEncode({'error': 'Livro não encontrado'}),
            headers: {'Content-Type': 'application/json'});
      }
      return Response.ok(
        jsonEncode({
          'idlivro': int.tryParse(id) ?? 0,
          'autor': autor,
          'titulo': titulo,
          'tema': tema
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } finally {
      await conn.close();
    }
  });

  // DELETE /livros/<id> -> remove
  router.delete('/livros/<id|[0-9]+>', (Request req, String id) async {
    final conn = await _openConn();
    try {
      final rs = await conn.execute(
        'DELETE FROM livro WHERE idlivro = :id',
        {'id': id.toString()},
      );
      if ((rs.affectedRows ?? 0) == 0) {
        return Response(404,
            body: jsonEncode({'error': 'Livro não encontrado'}),
            headers: {'Content-Type': 'application/json'});
      }
      return Response.ok(jsonEncode({'ok': true}),
          headers: {'Content-Type': 'application/json'});
    } finally {
      await conn.close();
    }
  });

  // Servidor
  final handler =
      const Pipeline().addMiddleware(logRequests()).addHandler(router);
  final int port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8080;
  final String host = InternetAddress.anyIPv4.address;

  final server = await shelf_io.serve(handler, host, port);
  print(
      '========================================================================');
  print('Servidor rodando em http://${server.address.address}:${server.port}');
  print('Banco: $_dbUser@$_dbHost:$_dbPort/$_dbDatabase (mysql_client)');
  print('Rotas:');
  print('  GET    /health');
  print('  GET    /livros');
  print('  GET    /livros/<id>');
  print('  POST   /livros');
  print('  PUT    /livros/<id>');
  print('  DELETE /livros/<id>');
  print(
      '========================================================================');
}
