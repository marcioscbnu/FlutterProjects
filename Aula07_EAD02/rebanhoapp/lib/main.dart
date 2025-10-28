import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart'; // Necessário para ValueListenable
import 'package:hive/hive.dart'; // HIVE: núcleo (caixas, adapters, etc.)
import 'package:hive_flutter/hive_flutter.dart'; // HIVE: init em Flutter
import 'package:flutter/services.dart'; // para SystemNavigator.pop()

/// ===============
/// Formatter RFID
/// ===============
/// Força o padrão 999-000000000000 (3 dígitos, hífen, 15 dígitos)
class RfidMaskFormatter extends TextInputFormatter {
  static final _digits = RegExp(r'\d');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // remove tudo que não é dígito
    final onlyDigits = newValue.text.characters
        .where((c) => _digits.hasMatch(c))
        .toList();
    // limita a 18 dígitos (3 + 15)
    final limited = onlyDigits.take(18).toList();

    // monta com hífen após os 3 primeiros dígitos
    final buf = StringBuffer();
    for (var i = 0; i < limited.length; i++) {
      if (i == 3) buf.write('-');
      buf.write(limited[i]);
    }
    final formatted = buf.toString();

    // calcula posição do cursor
    int selectionIndex = formatted.length;
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }

  static bool isValid(String v) => RegExp(r'^\d{3}-\d{15}$').hasMatch(v);
}

/// =========================
/// Domínio
/// =========================
class Ovelha {
  final String rfidOvelha; // Agora String para acomodar a máscara
  final String racaOvelha; // Santa Inês / Dorper / Texel
  final int idadeOvelha;
  bool
  indVacinada; // true = vacinada; false = não vacinada (mantido no enunciado)

  Ovelha({
    required this.rfidOvelha,
    required this.racaOvelha,
    required this.idadeOvelha,
    required this.indVacinada,
  });

  Ovelha copyWith({
    String? rfidOvelha,
    String? racaOvelha,
    int? idadeOvelha,
    bool? indVacinada,
  }) {
    return Ovelha(
      rfidOvelha: rfidOvelha ?? this.rfidOvelha,
      racaOvelha: racaOvelha ?? this.racaOvelha,
      idadeOvelha: idadeOvelha ?? this.idadeOvelha,
      indVacinada: indVacinada ?? this.indVacinada,
    );
  }
}

/// =========================
/// Adapter manual (sem build_runner)
/// =========================
/// HIVE: ensina o Hive a serializar/deserializar Ovelha
class OvelhaAdapter extends TypeAdapter<Ovelha> {
  @override
  final int typeId = 0; // HIVE: ID único do adapter no app

  @override
  Ovelha read(BinaryReader reader) {
    // HIVE: a ordem de leitura DEVE bater com a ordem de escrita abaixo
    final rfid = reader.readString(); // HIVE: lê String (RFID)
    final raca = reader.readString(); // HIVE: lê String (raça)
    final idade = reader.readInt(); // HIVE: lê int (idade)
    final vac = reader.readBool(); // HIVE: lê bool (vacinada)
    return Ovelha(
      rfidOvelha: rfid,
      racaOvelha: raca,
      idadeOvelha: idade,
      indVacinada: vac,
    );
  }

  @override
  void write(BinaryWriter writer, Ovelha obj) {
    // HIVE: escreva na MESMA ordem do read()
    writer
      ..writeString(obj.rfidOvelha) // HIVE: grava String
      ..writeString(obj.racaOvelha) // HIVE: grava String
      ..writeInt(obj.idadeOvelha) // HIVE: grava int
      ..writeBool(obj.indVacinada); // HIVE: grava bool
  }
}

/// =========================
/// Camada de Dados
/// =========================
class HiveOvelhaDataSource {
  static const String boxOvelhas = 'ovelhas'; // HIVE: nome da caixa

  // HIVE: referência tipada da caixa (precisa estar aberta no main())
  Box<Ovelha> get _box => Hive.box<Ovelha>(boxOvelhas);

  // HIVE: lê todos os registros e ordena por RFID (String)
  List<Ovelha> getAll() =>
      _box.values.toList()
        ..sort((a, b) => a.rfidOvelha.compareTo(b.rfidOvelha));

  // HIVE: put(key, value) — chave = RFID (String). Faz upsert.
  Future<void> put(Ovelha o) => _box.put(o.rfidOvelha, o);

  // HIVE: listenable() — notifica a UI quando a caixa muda (atualiza lista)
  ValueListenable<Box<Ovelha>> listenable() => _box.listenable();
}

class OvelhaRepository {
  final HiveOvelhaDataSource ds;
  OvelhaRepository(this.ds);

  List<Ovelha> listar() => ds.getAll(); // HIVE: leitura
  Future<void> salvar(Ovelha o) => ds.put(o); // HIVE: gravação (upsert)
  // Sem excluir(): você pediu para remover exclusão.
}

/// =========================
/// App
/// =========================
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter(); // HIVE: inicializa Hive no ambiente Flutter
  Hive.registerAdapter(
    OvelhaAdapter(),
  ); // HIVE: registra o adapter antes de abrir a box
  await Hive.openBox<Ovelha>(HiveOvelhaDataSource.boxOvelhas);
  // HIVE: abre (ou cria) a box "ovelhas" de tipo Ovelha

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final repo = OvelhaRepository(HiveOvelhaDataSource());
    return MaterialApp(
      title: 'Rebanho • Hive',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: OvelhasPage(repo: repo),
    );
  }
}

class OvelhasPage extends StatelessWidget {
  final OvelhaRepository repo;
  const OvelhasPage({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    final ds = repo.ds;
    return Scaffold(
      appBar: AppBar(title: const Text('Rebanho (Hive)')),
      body: ValueListenableBuilder(
        valueListenable: ds.listenable(), // HIVE: notificação reativa
        builder: (context, _, __) {
          final itens = repo.listar(); // HIVE: leitura de todos os registros
          if (itens.isEmpty) {
            return const Center(child: Text('Nenhuma ovelha cadastrada.'));
          }
          return ListView.separated(
            itemCount: itens.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final o = itens[index];
              return ListTile(
                leading: CircleAvatar(child: Text(o.idadeOvelha.toString())),
                title: Text('#${o.rfidOvelha} — ${o.racaOvelha}'),
                subtitle: Text('Vacinada: ${o.indVacinada ? "Sim" : "Não"}'),
                trailing: IconButton(
                  tooltip: 'Editar',
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => FormOvelhaPage(repo: repo, ovelha: o),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => FormOvelhaPage(repo: repo)));
        },
        label: const Text('Adicionar'),
        icon: const Icon(Icons.add),
      ),

      // 🔻 Botão fixo no rodapé para fechar o app
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            icon: const Icon(Icons.exit_to_app),
            label: const Text('Fechar aplicativo'),
            onPressed: () {
              SystemNavigator.pop(); // fecha o app (Android). Em iOS, retorna à tela anterior.
            },
          ),
        ),
      ),
    );
  }
}

class FormOvelhaPage extends StatefulWidget {
  final OvelhaRepository repo;
  final Ovelha? ovelha;
  const FormOvelhaPage({super.key, required this.repo, this.ovelha});

  @override
  State<FormOvelhaPage> createState() => _FormOvelhaPageState();
}

class _FormOvelhaPageState extends State<FormOvelhaPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController _rfidCtrl;
  late final TextEditingController _idadeCtrl;

  // Estado da UI
  bool _vacinada = false;

  // “Checkbox” exclusivo para raça (apenas uma pode ficar true)
  bool _santaInes = false;
  bool _dorper = false;
  bool _texel = false;

  // máscara do RFID
  final _rfidMask = RfidMaskFormatter();

  @override
  void initState() {
    super.initState();
    final o = widget.ovelha;

    _rfidCtrl = TextEditingController(text: o?.rfidOvelha ?? '');
    _idadeCtrl = TextEditingController(text: o?.idadeOvelha.toString() ?? '');
    _vacinada = o?.indVacinada ?? false;

    // define a raça selecionada (exclusiva)
    switch (o?.racaOvelha) {
      case 'Santa Inês':
        _santaInes = true;
        break;
      case 'Dorper':
        _dorper = true;
        break;
      case 'Texel':
        _texel = true;
        break;
    }
  }

  @override
  void dispose() {
    _rfidCtrl.dispose();
    _idadeCtrl.dispose();
    super.dispose();
  }

  // Retorna a raça selecionada com base nos checkboxes
  String _racaSelecionada() {
    if (_santaInes) return 'Santa Inês';
    if (_dorper) return 'Dorper';
    if (_texel) return 'Texel';
    return '';
  }

  void _toggleRaca(String qual, bool value) {
    // Exclusividade “estilo checkbox”: liga um, desliga os outros
    setState(() {
      _santaInes = qual == 'Santa Inês' ? value : false;
      _dorper = qual == 'Dorper' ? value : false;
      _texel = qual == 'Texel' ? value : false;

      // se o usuário desmarcar o que estava ligado, mantém pelo menos um selecionado?
      // Aqui deixamos possível ficar sem seleção; o validator vai exigir uma.
    });
  }

  Future<void> _salvar() async {
    // validação básica
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha os campos obrigatórios.')),
      );
      return;
    }
    final raca = _racaSelecionada();
    if (raca.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a raça (uma opção).')),
      );
      return;
    }

    try {
      final rfid = _rfidCtrl.text.trim(); // já vem formatado (máscara)
      final idade = int.parse(_idadeCtrl.text.trim());

      final nova = Ovelha(
        rfidOvelha: rfid,
        racaOvelha: raca,
        idadeOvelha: idade,
        indVacinada: _vacinada,
      );

      await widget.repo.salvar(
        nova,
      ); // HIVE: upsert no box com key = rfid (String)
      if (!mounted) return;
      Navigator.of(
        context,
      ).pop(true); // volta à lista (ValueListenableBuilder vai recarregar)
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.ovelha != null;

    return Scaffold(
      appBar: AppBar(title: Text(editando ? 'Editar Ovelha' : 'Nova Ovelha')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // RFID com máscara 999-000000000000
              TextFormField(
                controller: _rfidCtrl,
                decoration: const InputDecoration(
                  labelText: 'RFID (999-000000000000)',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _rfidMask,
                ],
                enabled: !editando, // RFID é chave no Hive
                validator: (v) {
                  final value = (v ?? '').trim();
                  if (value.isEmpty) return 'Informe o RFID';
                  if (!RfidMaskFormatter.isValid(value)) {
                    return 'Formato inválido. Use 999-000000000000';
                  }
                  return null;
                },
              ),

              // Checkbox exclusivo para raça (uma escolhida)
              const SizedBox(height: 16),
              const Text(
                'Raça (selecione uma):',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              CheckboxListTile(
                title: const Text('Santa Inês'),
                value: _santaInes,
                onChanged: (v) => _toggleRaca('Santa Inês', v ?? false),
              ),
              CheckboxListTile(
                title: const Text('Dorper'),
                value: _dorper,
                onChanged: (v) => _toggleRaca('Dorper', v ?? false),
              ),
              CheckboxListTile(
                title: const Text('Texel'),
                value: _texel,
                onChanged: (v) => _toggleRaca('Texel', v ?? false),
              ),

              // Idade e Vacinada
              const SizedBox(height: 8),
              TextFormField(
                controller: _idadeCtrl,
                decoration: const InputDecoration(labelText: 'Idade (anos)'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Informe a idade';
                  final n = int.tryParse(v.trim());
                  if (n == null) return 'Idade inválida';
                  if (n < 0) return 'Idade deve ser >= 0';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Vacinada'),
                value: _vacinada,
                onChanged: (val) => setState(() => _vacinada = val),
              ),

              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _salvar,
                icon: const Icon(Icons.save),
                label: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
