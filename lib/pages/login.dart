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
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   title: const Text('Welcome Back!'),
      //   // centerTitle: true,
      //   backgroundColor: Colors.orange.shade200,
      // ),

      

      body: 
      SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: 400,
              decoration: const BoxDecoration(
                color: Color(0xFF4A0072),
              ),
              child: Stack(
                children: [
                //logo app ntar
                  Positioned(
                    top: 150,
                    left: 150,
                    child: Container(
                      width: 120,
                      height: 120,
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock_outline,
                              color: Colors.white,
                              size: 48,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'MoTix',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 50,
                    left: 20,
                    child: Text(
                      'Welcome Back!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            //area untuk signin
            Padding(
              padding: EdgeInsets.only(top: 300),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40.0),
                    topRight: Radius.circular(40.0),
                  )
                ),
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight:FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.black87),
                        decoration: InputDecoration(
                          hintText: 'Email',
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          prefixIcon: Icon(Icons.email_outlined, color: Colors.grey.shade500),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 20.0),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.black87),
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          prefixIcon: Icon(Icons.lock_outline, color: Colors.grey.shade500),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 20.0),
                        ),
                      ),

                      const SizedBox(height: 12),

                      if (_errorCode.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Text(
                            _errorCode,
                            style: const TextStyle(color: Colors.red, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      // button sign in
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : signIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFE5F55), 
                            padding: const EdgeInsets.symmetric(vertical: 18.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 3,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'Sign In',
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                          ),
                          GestureDetector(
                            onTap: navigateRegister,
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Color(0xFF6200EE), 
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),



      // Padding(
      //   padding: const EdgeInsets.all(30.0),
      //   child: Center(
      //     child: ListView(
      //       children: [
      //         const SizedBox(height: 48),

      //         //logo app ntar
      //         // Icon(
      //         //   // child: Image.asset(
      //         //   //   'assets/images/logo.png',
      //         //   //   width: 100,
      //         //   //   height: 100,
      //         //   // ),
      //         // ),

      //         Icon(Icons.lock_outline, size: 100, color: Colors.blue[200]),

      //         const SizedBox(height: 48),
      //         TextField(
      //           //email
      //           controller: _emailController,
      //           keyboardType: TextInputType.emailAddress,
      //           style: TextStyle(color: Colors.black87),
      //           decoration: InputDecoration(
      //             hintText: 'Email',
      //             hintStyle: TextStyle(color: Colors.grey.shade500),
      //             prefixIcon: Icon(Icons.email_outlined, color: Colors.grey.shade500),
      //             filled: true,
      //             fillColor: Colors.white,
      //             border: OutlineInputBorder(
      //               borderRadius: BorderRadius.circular(50),
      //               borderSide: BorderSide.none,
      //             ),
      //             contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      //           ),

      //         ),

      //         const SizedBox(height: 16),

      //         TextField(
      //           //password
      //           controller: _passwordController,
      //           obscureText: true, 
      //           style: TextStyle(color: Colors.black87),
      //           decoration: InputDecoration(
      //             hintText: 'Enter your password',
      //             hintStyle: TextStyle(color: Colors.grey.shade500),
      //             prefixIcon: Icon(Icons.lock_outline, color: Colors.grey.shade500), 
      //             filled: true,
      //             fillColor: Colors.white,
      //             border: OutlineInputBorder(
      //               borderRadius: BorderRadius.circular(50),
      //               borderSide: BorderSide.none,
      //             ),
      //             contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      //           ),

      //         ),

      //         const SizedBox(height: 24),
      //         _errorCode != ""
      //             ? Column(
      //                 children: [Text(_errorCode), const SizedBox(height: 24)])
      //             : const SizedBox(height: 0),
      //         // OutlinedButton(
      //         //   onPressed: signIn,
      //         //   child: _isLoading
      //         //       ? const CircularProgressIndicator()
      //         //       : const Text('Login'),
      //         // ),
      //         SizedBox(
      //           width: double.infinity,
      //           child: ElevatedButton(
      //             onPressed: _isLoading ? null : signIn,
      //             style: ElevatedButton.styleFrom(
      //               backgroundColor: Colors.blueGrey.shade400,
      //               foregroundColor: Colors.white,
      //               shape: RoundedRectangleBorder(
      //                 borderRadius: BorderRadius.circular(50),
      //               ),
      //               padding: const EdgeInsets.symmetric(vertical: 16.0), 
      //             ),
      //             child: _isLoading
      //                 ? SizedBox(
      //                     height: 20,
      //                     width: 20,
      //                     child: CircularProgressIndicator(
      //                       valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      //                       strokeWidth: 2.5,
      //                     ),
      //                   )
      //                 : const Text(
      //                     'Sign In',
      //                     style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w600),
      //                   ),
      //           ),
      //         ),

      //         const SizedBox(height: 16),

      //         Row(
      //               mainAxisAlignment: MainAxisAlignment.center,
      //               children: [
      //                 Text(
      //                   'Don\'t have an account? ',
      //                   style: TextStyle(color: Colors.black  , fontSize: 14.5),
      //                 ),
      //                 GestureDetector(
      //                   onTap: navigateRegister,
      //                   child: Text(
      //                     'Sign up',
      //                     style: TextStyle(
      //                       color: Colors.black,
      //                       fontWeight: FontWeight.bold,
      //                       fontSize: 14.5,
      //                       decoration: TextDecoration.underline,
      //                       decorationColor: Colors.black,
      //                       decorationThickness: 1.5,
      //                     ),
      //                   ),
      //                 ),
      //               ],
      //             )
      //       ],
      //     ),
      //   ),
      // ),
    );
  }
}