import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Estado para ocultar/mostrar la contraseña
  bool _obscurePassword = true;

  // Controladores (cerebro) de la animación
  StateMachineController? controller;
  SMIBool? isChecking;
  SMIBool? isHandsUp;
  SMITrigger? trigSuccess;
  SMITrigger? trigFail;

  // 1) FocusNode
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  // 2) Listeners (0yentes/Chismosos)
  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(_onFocusChange);
    _passwordFocus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (isHandsUp == null || isChecking == null) return;

    if (!_emailFocus.hasFocus && !_passwordFocus.hasFocus) {
      // Ningún campo seleccionado
      isChecking!.change(false);
      isHandsUp!.change(false);
    } else if (_emailFocus.hasFocus) {
      // Email seleccionado
      isChecking!.change(true);
      isHandsUp!.change(false);
    } else if (_passwordFocus.hasFocus) {
      // Password seleccionado
      if (_obscurePassword) {
        isChecking!.change(true);
        isHandsUp!.change(false);
      } else {
        isChecking!.change(false);
        isHandsUp!.change(true);
      }
    }
  }

  // 4) Liberación de recursos / limpieza de
  @override
  void dispose() {
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Column(children: [
            // Animación Rive
            SizedBox(
              width: size.width,
              height: 200,
              child: RiveAnimation.asset(
                'assets/animated_login_character.riv',
                stateMachines: ['Login Machine'],
                onInit: (artboard) {
                  controller = StateMachineController.fromArtboard(
                      artboard, 'Login Machine');
                  if (controller == null) return;
                  artboard.addController(controller!);

                  isChecking = controller!.findSMI('isChecking');
                  isHandsUp = controller!.findSMI('isHandsUp');
                },
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 10),

            // Email
            TextField(
                focusNode: _emailFocus,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Introduce tu email',
                  prefixIcon: const Icon(Icons.mail),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (value) {
                  if (isHandsUp != null) isHandsUp!.change(false);
                  if (isChecking != null) isChecking!.change(true);
                }),

            const SizedBox(height: 10),

            // Contraseña
            TextField(
                focusNode: _passwordFocus,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                        _onFocusChange(); // actualizar animación
                      }),
                ),
                onChanged: (value) {
                  _onFocusChange(); // actualizar animación según visibilidad
                }),

            const SizedBox(height: 10),

            // Olvidaste contraseña
            SizedBox(
              width: size.width,
              child: const Text(
                '¿Olvidaste tu contraseña?',
                textAlign: TextAlign.right,
                style: TextStyle(decoration: TextDecoration.underline),
              ),
            ),

            const SizedBox(height: 20),

            // Botón Login
            MaterialButton(
              onPressed: () {},
              color: const Color.fromARGB(255, 243, 33, 198),
              minWidth: size.width,
              height: 50,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: const Text(
                'Login',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),

            const SizedBox(height: 10),

            // Registro
            SizedBox(
              width: size.width,
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('¿No tienes cuenta? '),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    '¡Regístrate aquí!',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ]),
            )
          ]),
        ),
      ),
    );
  }
}
