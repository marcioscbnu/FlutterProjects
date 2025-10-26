import 'package:flutter/material.dart';

// 1. PONTO DE ENTRADA DO PROGRAMA
void main() {
  // Inicia o aplicativo e carrega o widget raiz.
  runApp(const MeuApp());
}

// 2. WIDGET RAIZ (StatelessWidget)
class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp configura o tema, navegação e configurações globais.
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Formulário de Aluno (Modal)',
      theme: ThemeData(
        // Tema principal
        primarySwatch: Colors.indigo,
        // Configuração de cores para botões elevados
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      // A primeira tela a ser exibida é o nosso formulário.
      home: const FormularioAlunoPage(),
    );
  }
}

// 3. TELA DO FORMULÁRIO (StatefulWidget)
class FormularioAlunoPage extends StatefulWidget {
  const FormularioAlunoPage({super.key});

  @override
  _FormularioAlunoPageState createState() => _FormularioAlunoPageState();
}

// 4. CLASSE DE ESTADO (Onde a lógica do formulário reside)
class _FormularioAlunoPageState extends State<FormularioAlunoPage> {

  // Variáveis para Gerenciar o Formulário:
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _idadeController = TextEditingController();

  // 5. FUNÇÃO PARA MOSTRAR DIÁLOGOS (Modal)
  void _mostrarDialogoStatus(String titulo, String mensagem, Color cor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titulo, style: TextStyle(color: cor, fontWeight: FontWeight.bold)),
          content: Text(mensagem),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o modal
              },
            ),
          ],
        );
      },
    );
  }

  // 6. FUNÇÃO PARA PROCESSAR OS DADOS E VALIDAR A CONSISTÊNCIA
  void _submeterFormulario() {
    // 6.1. Validação básica (campos vazios, tipo de dado)
    if (_formKey.currentState!.validate()) {

      // Captura os valores dos controladores
      final nome = _nomeController.text;
      final idadeStr = _idadeController.text;
      final idade = int.tryParse(idadeStr);

      // 6.2. Validação de Consistência Aberta (Idade > 18)
      if (idade != null && idade < 18) {
        // Se a idade for menor que 18, mostra um erro específico em um modal
        _mostrarDialogoStatus(
            'Atenção: Idade Inconsistente',
            'O aluno tem apenas $idade anos. Este formulário requer alunos maiores de 18 anos. Por favor, verifique a informação.',
            Colors.redAccent
        );
        return; // Sai da função, não prossegue com o cadastro
      }

      // 6.3. Sucesso na Validação
      _mostrarDialogoStatus(
          'Cadastro Realizado!',
          'Sucesso! Aluno $nome, de $idade anos, cadastrado com êxito.',
          Colors.green[700]!
      );

      // Limpa os campos após o sucesso
      _nomeController.clear();
      _idadeController.clear();

    }
    // OBS: Se a validação básica falhar, o 'validator' do campo já exibe a mensagem de erro inline.
    // Não precisamos de um modal aqui, mas poderíamos adicionar um modal genérico de erro.
    else {
      _mostrarDialogoStatus(
          'Erro na Validação',
          'Por favor, corrija os erros marcados no formulário antes de prosseguir.',
          Colors.red
      );
    }
  }

  @override
  void dispose() {
    // Garante que os controladores sejam liberados da memória.
    _nomeController.dispose();
    _idadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold: Fornece a estrutura visual da tela (AppBar, Body).
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Aluno com Modais'),
      ),
      // Body: Conteúdo principal da tela.
      body: SingleChildScrollView( // Permite que a tela role se o teclado abrir
        padding: const EdgeInsets.all(20.0),
        child: Form( // O WIDGET FORM: Contém todos os campos
          key: _formKey, // Liga a chave GlobalKey ao widget Form
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Preencha os dados do aluno. A idade deve ser superior a 18 anos para o cadastro.',
                style: TextStyle(fontSize: 16, color: Colors.indigo),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              // CAMPO DE TEXTO: NOME DO ALUNO
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome Completo',
                  prefixIcon: Icon(Icons.access_alarms),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'O nome do aluno não pode ser vazio.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20), // Espaçamento vertical

              // CAMPO DE TEXTO: IDADE DO ALUNO
              TextFormField(
                controller: _idadeController,
                keyboardType: TextInputType.number, // Abre o teclado numérico
                decoration: const InputDecoration(
                  labelText: 'Idade',
                  prefixIcon: Icon(Icons.calendar_today),
                  hintText: 'Mínimo 18 anos',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                ),
                // O VALIDATOR: Verifica se o campo está vazio E se é um número válido
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'A idade é obrigatória.';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Por favor, insira um número inteiro válido.';
                  }
                  // A validação de consistência (idade < 18) é feita no _submeterFormulario
                  return null;
                },
              ),

              const SizedBox(height: 30),

              // O BOTÃO DE SUBMISSÃO
              ElevatedButton(
                onPressed: _submeterFormulario,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('CADASTRAR ALUNO', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
