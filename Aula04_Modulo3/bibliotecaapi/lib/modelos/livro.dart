class Livro {
  final int? idlivro;
  final String autor;
  final String titulo;
  final String tema;

  const Livro({
    this.idlivro,
    required this.autor,
    required this.titulo,
    required this.tema,
  });

  factory Livro.fromJson(Map<String, dynamic> j) => Livro(
    idlivro: j['idlivro'] is int
        ? j['idlivro']
        : int.tryParse('${j['idlivro']}'),
    autor: j['autor'] ?? '',
    titulo: j['titulo'] ?? '',
    tema: j['tema'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    if (idlivro != null) 'idlivro': idlivro,
    'autor': autor,
    'titulo': titulo,
    'tema': tema,
  };
}
