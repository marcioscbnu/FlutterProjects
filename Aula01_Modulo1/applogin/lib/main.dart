import 'package:flutter/material.dart';

// Enum para gerenciar o estado da tela de autenticação
enum AuthScreen { login, register, recoverPassword }

void main() {
  runApp(const AuthApp());
}

class AuthApp extends StatelessWidget {
  const AuthApp({super.key});

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
          contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
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
void _showModal(BuildContext context, String title, String message, {Color color = Colors.red}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(message),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
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
    if (email == 'user@teste.com' && password == '123456') {
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
      _showModal(
        context,
        'ATENÇÃO!',
        'Credenciais inválidas!',
      );
    }
  }

  // Função para renderizar a tela atual
  Widget _buildScreen() {
    switch (_currentScreen) {
      case AuthScreen.login:
        return LoginScreen(
          onLogin: _handleLogin,
          onRegisterRequest: () => _setScreen(AuthScreen.register),
          onRecoverRequest: () => _setScreen(AuthScreen.recoverPassword),
        );
      case AuthScreen.register:
        return RegisterScreen(
          onRegisterSuccess: () {
            // Após o cadastro, retorna para a tela de login e mostra o modal de sucesso
            _setScreen(AuthScreen.login);
            _showModal(
              context,
              'ATENÇÃO!',
              'Usuário salvo com sucesso!',
              color: Colors.green,
            );
          },
          onCancel: () => _setScreen(AuthScreen.login),
        );
      case AuthScreen.recoverPassword:
        return RecoverPasswordScreen(
          onPasswordRecovered: () {
            // Após a recuperação, retorna para a tela de login
            _setScreen(AuthScreen.login);
            _showModal(
              context,
              'ATENÇÃO!',
              'Senha restaurada. Faça login com a nova senha.',
              color: Colors.blue,
            );
          },
          onCancel: () => _setScreen(AuthScreen.login),
        );
    }
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
            onChanged: (value) => _email = value,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email é obrigatório';
              }
              return null;
            },
          ),
          const SizedBox(height: 15),

          // Campo Senha
          TextFormField(
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Senha',
              prefixIcon: Icon(Icons.lock),
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

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      if (_password != _confirmPassword) {
        _showModal(
          context,
          'ATENÇÃO!',
          'Senhas não conferem!',
        );
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

          // Campo CPF
          TextFormField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'CPF (999.999.999-99)',
              prefixIcon: Icon(Icons.person),
            ),
            onChanged: (value) => _cpf = value,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'CPF é obrigatório';
              }
              return null;
            },
          ),
          const SizedBox(height: 15),

          // Campo Nome
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Nome',
              prefixIcon: Icon(Icons.badge),
            ),
          ),
          const SizedBox(height: 15),

          // Campo Email
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
            ),
          ),
          const SizedBox(height: 15),

          // Campo Senha
          TextFormField(
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Senha',
              prefixIcon: Icon(Icons.lock),
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

          // Campo Senha Conf.
          TextFormField(
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Senha Conf.',
              prefixIcon: Icon(Icons.lock_reset),
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

          // Campo Data Nasc.
          TextFormField(
            keyboardType: TextInputType.datetime,
            decoration: InputDecoration(
              labelText: 'Data Nasc.',
              prefixIcon: Icon(Icons.calendar_today),
            ),
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

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      if (_newPassword != _confirmPassword) {
        _showModal(
          context,
          'ATENÇÃO!',
          'Senhas não conferem!',
        );
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

          // Campo Nova Senha
          TextFormField(
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Senha Nova',
              prefixIcon: Icon(Icons.vpn_key),
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

          // Campo Senha Confirmação
          TextFormField(
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Senha Conf.',
              prefixIcon: Icon(Icons.vpn_key_sharp),
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
          ElevatedButton(
            onPressed: _handleSave,
            child: const Text('SALVAR'),
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
