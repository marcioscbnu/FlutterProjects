import 'package:flutter/material.dart';
// MODIFICAÇÃO: Importa o pacote necessário para criar máscaras de entrada
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:flutter/services.dart'; // Necessário para TextInputFormatter

// Enum para gerenciar o estado da tela de autenticação
enum AuthScreen { login, register, recoverPassword }

void main() {
  runApp(const TelaAutorizacao());
}

class TelaAutorizacao extends StatelessWidget {
  const TelaAutorizacao({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Single Sign-On App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Configuração de tema simples para dar um bom visual aos campos
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 12.0,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: const AuthFlow(),
    );
  }
}

// --------------------------------------------------------------------------
// Lógica de Modais e Mensagens
// --------------------------------------------------------------------------

/// Exibe um modal de atenção simples.
void _showModal(
  BuildContext context,
  String title,
  String message, {
  Color color = Colors.red,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          title,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(message),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                child: const Text(
                  'OK',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

// --------------------------------------------------------------------------
// Widget principal que gerencia o fluxo de autenticação
// --------------------------------------------------------------------------

class AuthFlow extends StatefulWidget {
  const AuthFlow({super.key});

  @override
  State<AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends State<AuthFlow> {
  AuthScreen _currentScreen = AuthScreen.login;

  // Função para mudar a tela
  void _setScreen(AuthScreen screen) {
    setState(() {
      _currentScreen = screen;
    });
  }

  // Função que simula o Login e navega para o MainMenu
  void _handleLogin(String email, String password) {
    // Simulação de validação
    if (email.isEmpty || password.isEmpty) {
      _showModal(
        context,
        'ATENÇÃO!',
        'Informações obrigatórias! Preencha todos os campos.',
      );
      return;
    }

    // Simulação de credenciais
    // MODIFICAÇÃO: Converte o email para minúsculas para coincidir com a entrada no campo
    if (email.toLowerCase() == 'user@teste.com' && password == '123456') {
      // Login efetuado com sucesso!
      _showModal(
        context,
        'BEM-VINDO!',
        'Login efetuado com sucesso!',
        color: Colors.green,
      );

      // Navegação para a tela principal (sem navegação nomeada)
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MainMenuScreen()),
      ).then((_) {
        // Ao retornar do MainMenu, volta para a tela de Login
        _setScreen(AuthScreen.login);
      });
    } else {
      // Credenciais inválidas
      _showModal(context, 'ATENÇÃO!', 'Credenciais inválidas!');
    }
  }

  // Função para renderizar a tela atual
  // Widget responsável por decidir qual tela de autenticação será exibida
  Widget _buildScreen() {
    // Inicia a verificação do estado atual da tela (_currentScreen)
    switch (_currentScreen) {
      // -----------------------------------------------------------
      // Caso 1: A tela atual é a de Login
      // -----------------------------------------------------------
      case AuthScreen.login:
        // Retorna o widget da tela de Login (LoginScreen)
        return LoginScreen(
          // Propriedade 'onLogin': Passa a função que lida com a tentativa de login (e navegação)
          onLogin: _handleLogin,
          // Propriedade 'onRegisterRequest': Função passada para mudar o estado para a tela de Registro
          onRegisterRequest: () => _setScreen(AuthScreen.register),
          // Propriedade 'onRecoverRequest': Função passada para mudar o estado para a tela de Recuperação de Senha
          onRecoverRequest: () => _setScreen(AuthScreen.recoverPassword),
        );
      // -----------------------------------------------------------
      // Caso 2: A tela atual é a de Registro (Cadastro)
      // -----------------------------------------------------------
      case AuthScreen.register:
        // Retorna o widget da tela de Registro (RegisterScreen)
        return RegisterScreen(
          // Propriedade 'onRegisterSuccess': Função a ser chamada após o sucesso do cadastro
          onRegisterSuccess: () {
            // Volta o estado para a tela de Login
            _setScreen(AuthScreen.login);
            // Exibe um modal de notificação de sucesso para o usuário
            _showModal(
              context,
              'ATENÇÃO!',
              'Usuário salvo com sucesso!',
              color: Colors.green,
            );
          },
          // Propriedade 'onCancel': Função para cancelar o cadastro e voltar para a tela de Login
          onCancel: () => _setScreen(AuthScreen.login),
        );
      // -----------------------------------------------------------
      // Caso 3: A tela atual é a de Recuperação de Senha
      // -----------------------------------------------------------
      case AuthScreen.recoverPassword:
        // Retorna o widget da tela de Recuperação de Senha (RecoverPasswordScreen)
        return RecoverPasswordScreen(
          // Propriedade 'onPasswordRecovered': Função a ser chamada após a recuperação ser concluída
          onPasswordRecovered: () {
            // Volta o estado para a tela de Login
            _setScreen(AuthScreen.login);
            // Exibe um modal de notificação de que a senha foi restaurada
            _showModal(
              context,
              'ATENÇÃO!',
              'Senha restaurada. Faça login com a nova senha.',
              color: Colors.blue,
            );
          },
          // Propriedade 'onCancel': Função para cancelar a recuperação e voltar para a tela de Login
          onCancel: () => _setScreen(AuthScreen.login),
        );
    }
    // O Dart/Flutter exige que todos os caminhos retornem um Widget (embora o switch cubra todos os casos do Enum).
    // A estrutura do switch garante que um widget seja retornado para qualquer valor de AuthScreen.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SSO - Single Sign-On'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: _buildScreen(),
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------------------------------
// 1. TELA DE LOGIN
// --------------------------------------------------------------------------

class LoginScreen extends StatefulWidget {
  final Function(String email, String password) onLogin;
  final VoidCallback onRegisterRequest;
  final VoidCallback onRecoverRequest;

  const LoginScreen({
    super.key,
    required this.onLogin,
    required this.onRegisterRequest,
    required this.onRecoverRequest,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  // MODIFICAÇÃO: Variável para controlar a visibilidade da senha (olho de deus)
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text(
            'Login',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),

          // Campo Email
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
            ),
            // MODIFICAÇÃO: Converte o email para minúsculas e armazena
            onChanged: (value) => _email = value.toLowerCase(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email é obrigatório';
              }
              // MODIFICAÇÃO: Validação de formato de email usando RegExp
              const pattern =
                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
              final regExp = RegExp(pattern);
              if (!regExp.hasMatch(value)) {
                return 'Digite um formato de email válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 15),

          // Campo Senha
          TextFormField(
            // MODIFICAÇÃO: Controla se a senha está oculta
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Senha',
              prefixIcon: const Icon(Icons.lock),
              // MODIFICAÇÃO: Adiciona o 'olho de deus' (Toggle Password Visibility)
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  // Alterna o estado de visibilidade da senha
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
            onChanged: (value) => _password = value,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Senha é obrigatória';
              }
              return null;
            },
          ),
          const SizedBox(height: 30),

          // Botão ENTRAR
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                widget.onLogin(_email, _password);
              }
            },
            child: const Text('ENTRAR'),
          ),
          const SizedBox(height: 20),

          // Botão Registrar-se
          TextButton(
            onPressed: widget.onRegisterRequest,
            child: const Text('Registrar-se'),
          ),

          // Botão Esqueceu a senha?
          TextButton(
            onPressed: widget.onRecoverRequest,
            child: const Text('Esqueceu a senha?'),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------------------
// 2. TELA DE CADASTRO DE USUÁRIO
// --------------------------------------------------------------------------

class RegisterScreen extends StatefulWidget {
  final VoidCallback onRegisterSuccess;
  final VoidCallback onCancel;

  const RegisterScreen({
    super.key,
    required this.onRegisterSuccess,
    required this.onCancel,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _cpf = '';
  String _password = '';
  String _confirmPassword = '';

  // MODIFICAÇÃO: Máscara para CPF: 999.999.999-99
  final _cpfFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  // MODIFICAÇÃO: Máscara para Data de Nascimento: dd/mm/aaaa
  final _dateFormatter = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  // MODIFICAÇÃO: Variáveis para visibilidade das senhas
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // MODIFICAÇÃO: Validação personalizada da Data de Nasc. (dd/mm/aaaa e não pode ser futura)
  String? _validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Data de Nasc. é obrigatória';
    }

    // Verifica se a máscara foi preenchida
    if (value.length < 10) {
      return 'Formato: dd/mm/aaaa';
    }

    try {
      final parts = value.split('/');
      // Converte para int. Se falhar, vai para o catch.
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      // Cria um DateTime. Usamos UTC para evitar problemas de fuso horário.
      final inputDate = DateTime.utc(year, month, day);
      final currentDate = DateTime.now().toUtc();

      // Se a data for posterior ao dia atual (data de nascimento não pode ser futura)
      if (inputDate.isAfter(currentDate)) {
        return 'A data de nascimento não pode ser futura';
      }
    } catch (e) {
      // Falha na conversão da data
      return 'Data inválida (dd/mm/aaaa)';
    }

    return null;
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      if (_password != _confirmPassword) {
        _showModal(context, 'ATENÇÃO!', 'Senhas não conferem!');
        return;
      }
      // Simulação de salvamento
      widget.onRegisterSuccess();
    } else {
      _showModal(
        context,
        'ATENÇÃO!',
        'Informações obrigatórias! Preencha todos os campos.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text(
            'Cadastro Usuário',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),

          // Campo CPF - MODIFICAÇÃO: Com máscara 999.999.999-99
          TextFormField(
            keyboardType: TextInputType.number,
            // Aplica a máscara de CPF
            inputFormatters: [_cpfFormatter],
            decoration: const InputDecoration(
              labelText: 'CPF (999.999.999-99)',
              prefixIcon: Icon(Icons.person),
            ),
            onChanged: (value) => _cpf = value,
            validator: (value) {
              if (value == null || value.isEmpty || value.length < 14) {
                return 'CPF é obrigatório';
              }
              return null;
            },
          ),
          const SizedBox(height: 15),

          // Campo Nome - MODIFICAÇÃO: Tudo em Maiúsculas
          TextFormField(
            // Sugere ao teclado entrada em maiúsculas
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Nome',
              prefixIcon: Icon(Icons.badge),
            ),
            // Converte o texto para maiúsculas
            onChanged: (value) {
              // Manter o onChanged original ou modificá-lo para forçar maiúsculas
            },
            // MODIFICAÇÃO: Adiciona um TextInputFormatter para forçar maiúsculas em tempo real
            inputFormatters: [UpperCaseTextFormatter()],
          ),
          const SizedBox(height: 15),

          // Campo Email - MODIFICAÇÃO: Com validação de formato de email
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
            ),
            // Converte o email para minúsculas e armazena
            onChanged: (value) => {},
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email é obrigatório';
              }
              // Validação de formato de email usando RegExp
              const pattern =
                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
              final regExp = RegExp(pattern);
              if (!regExp.hasMatch(value)) {
                return 'Digite um formato de email válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 15),

          // Campo Senha - MODIFICAÇÃO: Com 'olho de deus' (Toggle Password Visibility)
          TextFormField(
            // Controla se a senha está oculta
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Senha',
              prefixIcon: const Icon(Icons.lock),
              // Adiciona o 'olho de deus'
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible =
                        !_isPasswordVisible; // Alterna o estado
                  });
                },
              ),
            ),
            onChanged: (value) => _password = value,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Senha é obrigatória';
              }
              return null;
            },
          ),
          const SizedBox(height: 15),

          // Campo Senha Conf. - MODIFICAÇÃO: Com 'olho de deus'
          TextFormField(
            // Controla se a senha está oculta
            obscureText: !_isConfirmPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Senha Conf.',
              prefixIcon: const Icon(Icons.lock_reset),
              // Adiciona o 'olho de deus'
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmPasswordVisible =
                        !_isConfirmPasswordVisible; // Alterna o estado
                  });
                },
              ),
            ),
            onChanged: (value) => _confirmPassword = value,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Confirmação de senha é obrigatória';
              }
              if (value != _password) {
                return 'As senhas não coincidem';
              }
              return null;
            },
          ),
          const SizedBox(height: 15),

          // Campo Data Nasc. - MODIFICAÇÃO: Com máscara dd/mm/aaaa e validação de data futura
          TextFormField(
            keyboardType: TextInputType.datetime,
            // Aplica a máscara de data
            inputFormatters: [_dateFormatter],
            decoration: const InputDecoration(
              labelText: 'Data Nasc.',
              prefixIcon: Icon(Icons.calendar_today),
            ),
            // Utiliza a função de validação personalizada
            validator: _validateDate,
          ),
          const SizedBox(height: 30),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              // Botão LIMPAR
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _formKey.currentState?.reset();
                    // MODIFICAÇÃO: Limpa o estado dos formatters
                    _cpfFormatter.clear();
                    _dateFormatter.clear();
                  },
                  child: const Text('LIMPAR'),
                ),
              ),
              const SizedBox(width: 15),
              // Botão SALVAR
              Expanded(
                child: ElevatedButton(
                  onPressed: _handleSave,
                  child: const Text('SALVAR'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: widget.onCancel,
            child: const Text('Cancelar e voltar para Login'),
          ),
        ],
      ),
    );
  }
}

// MODIFICAÇÃO: Classe para forçar o texto a ser maiúsculo
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

// --------------------------------------------------------------------------
// 3. TELA DE RESTAURAR SENHA
// --------------------------------------------------------------------------

class RecoverPasswordScreen extends StatefulWidget {
  final VoidCallback onPasswordRecovered;
  final VoidCallback onCancel;

  const RecoverPasswordScreen({
    super.key,
    required this.onPasswordRecovered,
    required this.onCancel,
  });

  @override
  State<RecoverPasswordScreen> createState() => _RecoverPasswordScreenState();
}

class _RecoverPasswordScreenState extends State<RecoverPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  String _newPassword = '';
  String _confirmPassword = '';

  // MODIFICAÇÃO: Variáveis para visibilidade das senhas
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      if (_newPassword != _confirmPassword) {
        _showModal(context, 'ATENÇÃO!', 'Senhas não conferem!');
        return;
      }
      // Simulação de salvamento
      widget.onPasswordRecovered();
    } else {
      _showModal(
        context,
        'ATENÇÃO!',
        'Informações obrigatórias! Preencha todos os campos.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text(
            'Restaurar Senha',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),

          // Campo Nova Senha - MODIFICAÇÃO: Com 'olho de deus'
          TextFormField(
            // Controla se a senha está oculta
            obscureText: !_isNewPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Senha Nova',
              prefixIcon: const Icon(Icons.vpn_key),
              // Adiciona o 'olho de deus'
              suffixIcon: IconButton(
                icon: Icon(
                  _isNewPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isNewPasswordVisible =
                        !_isNewPasswordVisible; // Alterna o estado
                  });
                },
              ),
            ),
            onChanged: (value) => _newPassword = value,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nova Senha é obrigatória';
              }
              return null;
            },
          ),
          const SizedBox(height: 15),

          // Campo Senha Confirmação - MODIFICAÇÃO: Com 'olho de deus'
          TextFormField(
            // Controla se a senha está oculta
            obscureText: !_isConfirmPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Senha Conf.',
              prefixIcon: const Icon(Icons.vpn_key_sharp),
              // Adiciona o 'olho de deus'
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmPasswordVisible =
                        !_isConfirmPasswordVisible; // Alterna o estado
                  });
                },
              ),
            ),
            onChanged: (value) => _confirmPassword = value,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Confirmação de Senha é obrigatória';
              }
              if (value != _newPassword) {
                return 'As senhas não coincidem';
              }
              return null;
            },
          ),
          const SizedBox(height: 30),

          // Botão SALVAR
          ElevatedButton(onPressed: _handleSave, child: const Text('SALVAR')),
          const SizedBox(height: 10),
          TextButton(
            onPressed: widget.onCancel,
            child: const Text('Cancelar e voltar para Login'),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------------------
// 4. TELA DE MENU PRINCIPAL
// --------------------------------------------------------------------------

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Principal'),
        automaticallyImplyLeading: false, // Oculta o botão de voltar padrão
        backgroundColor: Colors.blueGrey,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  'MENU PRINCIPAL',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                const Text(
                  'BEM-VINDO!',
                  style: TextStyle(fontSize: 24, color: Colors.green),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Login efetuado com sucesso!',
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50),

                // Botão VOLTAR (Logout)
                OutlinedButton(
                  onPressed: () {
                    // Ações de logout simuladas, e volta para a tela anterior (AuthFlow)
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    side: const BorderSide(color: Colors.blueGrey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('VOLTAR (Logout)'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
