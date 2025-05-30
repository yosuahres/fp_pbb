import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String _errorCode = "";

  void navigateRegister() {
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, 'register');
  }

  void navigateHome() {
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, 'home');
  }

  //nanti
  // void navigateForgotPassword() {
  //   if (!context.mounted) return;
  //   Navigator.pushReplacementNamed(context, 'forgot_password');
  // }

  void signIn() async {
    setState(() {
      _isLoading = true;
      _errorCode = "";
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      //get userid
      final user = FirebaseAuth.instance.currentUser;
      final uid = user?.uid;

      navigateHome();
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorCode = e.code;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void clearText() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade200,
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
        backgroundColor: Colors.orange.shade200,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ListView(
            children: [
              const SizedBox(height: 48),

              //logo app ntar
              // Icon(
              //   // child: Image.asset(
              //   //   'assets/images/logo.png',
              //   //   width: 100,
              //   //   height: 100,
              //   // ),
              // ),

              Icon(Icons.lock_outline, size: 100, color: Colors.blue[200]),

              const SizedBox(height: 48),
              TextField(
                //email
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Email',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  prefixIcon: Icon(Icons.email_outlined, color: Colors.grey.shade500),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                ),

              ),

              const SizedBox(height: 16),

              TextField(
                //password
                controller: _passwordController,
                obscureText: true, 
                style: TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  prefixIcon: Icon(Icons.lock_outline, color: Colors.grey.shade500), 
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                ),

              ),

              const SizedBox(height: 24),
              _errorCode != ""
                  ? Column(
                      children: [Text(_errorCode), const SizedBox(height: 24)])
                  : const SizedBox(height: 0),
              // OutlinedButton(
              //   onPressed: signIn,
              //   child: _isLoading
              //       ? const CircularProgressIndicator()
              //       : const Text('Login'),
              // ),
              ElevatedButton(
                onPressed: _isLoading ? null : signIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey.shade400,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Login',
                        style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w600),
                      ),
              ),

              const SizedBox(height: 16),

              Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account? ',
                        style: TextStyle(color: Colors.black  , fontSize: 14.5),
                      ),
                      GestureDetector(
                        onTap: navigateRegister,
                        child: Text(
                          'Sign up here',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.5,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.black,
                            decorationThickness: 1.5,
                          ),
                        ),
                      ),
                    ],
                  )
            ],
          ),
        ),
      ),
    );
  }
}