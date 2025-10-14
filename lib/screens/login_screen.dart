import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
//3.1 importar librería de timer
import 'dart:async';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool obscurePassword = true;

  // Cerebro de la lógica de las animaciones
  StateMachineController? controller;
  // SMI: State Machine Input
  SMIBool? isChecking; // Activa el modo chismoso
  SMIBool? isHandsUp; // Se tapa los ojos
  SMITrigger? trigSuccess; // Se emociona
  SMITrigger? trigFail; // Se pone triste
  //2.1 variable para recorrido de la mirada
  SMINumber? numLook;

  // 1.1) FocusNode (FALTABA LOS PARÉNTESIS)
  final emailFocus = FocusNode();
  final passFocus = FocusNode();
  //3.2 la variable de timer deterner la mirada de teclear
  Timer? _typingDebounce;

  @override
  void initState() {
    super.initState();

    // 2) Listeners
    emailFocus.addListener(() {
      if (emailFocus.hasFocus) {
        isHandsUp?.change(false);
        //2.2 mirada neutral al email
        numLook?.value = 50.0;
        isHandsUp?.change(false);
      }
    });

    passFocus.addListener(() {
      isHandsUp?.change(passFocus.hasFocus);
    });
  }

  @override
  void dispose() {
    // Liberar memoria
    emailFocus.dispose();
    passFocus.dispose();
    _typingDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(
                width: size.width,
                height: 200,
                child: RiveAnimation.asset(
                  'assets/animated_login_character.riv',
                  stateMachines: ["Login Machine"],
                  onInit: (artboard) {
                    controller = StateMachineController.fromArtboard(
                      artboard,
                      "Login Machine",
                    );
                    if (controller == null) return;
                    artboard.addController(controller!);
                    isChecking = controller!.findSMI('isChecking');
                    isHandsUp = controller!.findSMI('isHandsUp');
                    trigSuccess = controller!.findSMI('trigSuccess');
                    trigFail = controller!.findSMI('trigFail');

                    //2.3 inicializar variable de la animación
                    numLook = controller!.findSMI('numLook');
                  }, //clamp
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                focusNode: emailFocus,
                onChanged: (value) {
                  if (isHandsUp != null) {
                    isChecking!.change(true);
                    //ajuste de limites de 0 a 100
                    final look = (value.length / 80.0 * 100.0).clamp(
                      0.0,
                      100.0,
                    );
                    numLook?.value = look;

                    //3.3 si vuelve a teclear, se reinicia el timer
                    _typingDebounce?.cancel(); //cancela el timer existente
                    _typingDebounce = Timer(const Duration(seconds: 3), () {
                      if (!mounted) {
                        return; // si la pantalla se cierra
                      }
                    });
                  }
                  if (isChecking == null) return;
                  isChecking!.change(true);
                },
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.mail),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                focusNode: passFocus,
                onChanged: (value) {
                  if (isChecking != null) {
                    isChecking!.change(false);
                  }
                  if (isHandsUp == null) return;
                  // isHandsUp!.change(true); // Comentado por ti
                },
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: size.width,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Forgot your password?',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              MaterialButton(
                minWidth: size.width,
                height: 50,
                color: Colors.purple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onPressed: () {},
                child: const Text(
                  'Login',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("New here?"),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Register",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
