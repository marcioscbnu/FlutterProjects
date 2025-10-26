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
      title: 'Formulário de Aluno',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      // A primeira tela a ser exibida é o nosso formulário.
      home: const FormularioAlunoPage(),
    );
  }
}

// 3. TELA DO FORMULÁRIO (StatefulWidget)
// Usamos StatefulWidget porque a tela precisa gerenciar o estado dos inputs (o texto digitado)
class FormularioAlunoPage extends StatefulWidget {
  const FormularioAlunoPage({super.key});

  @override
  _FormularioAlunoPageState createState() => _FormularioAlunoPageState();
}

// 4. CLASSE DE ESTADO (Onde a lógica do formulário reside)
class _FormularioAlunoPageState extends State<FormularioAlunoPage> {

  // Variáveis para Gerenciar o Formulário:

  // GlobalKey: Identificador único que o Flutter usa para controlar o estado do widget Form.
  // É crucial para chamar os métodos validate() e save().
  final _formKey = GlobalKey<FormState>();

  // TextEditingController: Usado para obter e controlar o texto inserido nos campos.
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _idadeController = TextEditingController();

  // Variável de estado para exibir a mensagem de sucesso
  String _mensagemDeStatus = '';

  // 5. FUNÇÃO PARA PROCESSAR OS DADOS
  void _submeterFormulario() {
    // _formKey.currentState!.validate() executa todos os 'validators' dos TextFormField.
    if (_formKey.currentState!.validate()) {
      // Se todos os validadores retornarem NULL (ou seja, passaram na validação):

      // Captura os valores dos controladores
      final nome = _nomeController.text;
      final idade = _idadeController.text; // Idade é uma string, mas será tratada como int na vida real.
      final idadeInt = int.tryParse(idade);
      if (idadeInt != null && idadeInt < 18){
           setState(() {
          _mensagemDeStatus = 'Idade deve ser maior que 18';
        });
      } else {
        // Atualiza o estado para mostrar a mensagem de sucesso na tela.
        setState(() {
          _mensagemDeStatus = 'Sucesso! Aluno: $nome, Idade: $idade.';
        });
      }

      // Na vida real, aqui você chamaria uma API, salvaria em um banco de dados, etc.

    } else {
      // Se a validação falhar, a mensagem de erro já aparece automaticamente
      // abaixo do campo que falhou.
      setState(() {
        _mensagemDeStatus = 'Erro: Por favor, preencha os campos obrigatórios.';
      });
    }
  }

  @override
  void dispose() {
    // MÉTODOS DE LIMPEZA:
    // Garante que os controladores sejam liberados da memória quando o widget for destruído.
    _nomeController.dispose();
    _idadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold: Fornece a estrutura visual da tela (AppBar, Body).
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Aluno'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white, // Define a cor do texto/ícones na AppBar
      ),
      // Body: Conteúdo principal da tela.
      body: SingleChildScrollView( // Permite que a tela role se o teclado abrir
        padding: const EdgeInsets.all(20.0),
        child: Form( // 6. O WIDGET FORM: Contém todos os campos
          key: _formKey, // Liga a chave GlobalKey ao widget Form
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            // Estica os elementos horizontalmente
            children: <Widget>[

              // 7. CAMPO DE TEXTO: NOME DO ALUNO
              TextFormField(
                controller: _nomeController, // Liga o controlador ao campo
                decoration: const InputDecoration(
                  labelText: 'Nome Completo',
                  hintText: 'Ex: João da Silva',
                  border: OutlineInputBorder(),
                ),

                // 8. O VALIDATOR: Verifica se o campo está vazio
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'O nome do aluno não pode ser vazio.'; // Mensagem de erro se falhar
                  }
                  return null; // Retorna null se for válido (Sucesso)
                },
              ),

              const SizedBox(height: 20), // Espaçamento vertical

              // 9. CAMPO DE TEXTO: IDADE DO ALUNO
              TextFormField(
                controller: _idadeController, // Liga o controlador ao campo
                keyboardType: TextInputType.number, // Abre o teclado numérico
                decoration: const InputDecoration(
                  labelText: 'Idade',
                  hintText: 'Ex: 18',
                  border: OutlineInputBorder(),
                ),
                // 10. O VALIDATOR: Verifica se o campo está vazio E se é um número
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'A idade é obrigatória.';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Por favor, insira um número válido.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),

              // 11. O BOTÃO DE SUBMISSÃO
              ElevatedButton(
                onPressed: _submeterFormulario, // Chama a função que contém a lógica de validação
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text('CADASTRAR ALUNO', style: TextStyle(fontSize: 16)),
              ),

              const SizedBox(height: 30),

              // 12. EXIBIÇÃO DA MENSAGEM DE STATUS
              Text(
                _mensagemDeStatus,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _mensagemDeStatus.startsWith('Sucesso') ? Colors.green[700] : Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}