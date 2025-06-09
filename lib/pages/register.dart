import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String _errorCode = "";

  void navigateLogin() {
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, 'login');
  }

  void navigateHome() {
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, 'home');
  }

  void register() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorCode = "bad";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorCode = "";
    });

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      navigateLogin();
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   title: const Text('Create Account'),
      //   // centerTitle: true,
      // ),


      body: 
      SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: 400,
              decoration: const BoxDecoration(
                color: Color(0xFF212121),
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
                      'Create Account',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ),
                ],
              ),
            ),

            ///area signup
            Padding(
              padding: EdgeInsets.only(top:300),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      //email
                      TextField(
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
                      //password
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.black87),
                        decoration: InputDecoration(
                          hintText: 'Enter your password',
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
                      const SizedBox(height: 16),
                      //confirm password
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.black87),
                        decoration: InputDecoration(
                          hintText: 'Confirm your password',
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
                      const SizedBox(height: 24),

                                    _errorCode != ""
                  ? Column(
                      children: [Text(_errorCode), const SizedBox(height: 24)],
                    )
                  : const SizedBox(height: 0),
              // OutlinedButton(
              //   onPressed: register,
              //   child: _isLoading
              //       ? const CircularProgressIndicator()
              //       : const Text('Register'),
              // ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF424242),
                    padding: const EdgeInsets.symmetric(vertical: 18.0), 
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 3
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
                          'Sign Up',
                          style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(color: Colors.grey.shade700  , fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: navigateLogin,
                        child: Text(
                          'Sign In',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            // decoration: TextDecoration.underline,
                            // decorationColor: Colors.black,
                            // decorationThickness: 1.5,
                          ),
                        ),
                      ),
                    ],
                  )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // body: Padding(
      //   padding: const EdgeInsets.all(30.0),
      //   child: Center(
      //     child: ListView(
      //       children: [
      //         const SizedBox(height: 48),
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

      //         const SizedBox(height: 16),

      //         TextField(
      //             controller: _confirmPasswordController,
      //             obscureText: true,
      //             style: TextStyle(color: Colors.black87),
      //             decoration: InputDecoration(
      //               hintText: 'Confirm your password',
      //               hintStyle: TextStyle(color: Colors.grey.shade500),
      //               prefixIcon: Icon(Icons.lock_outline, color: Colors.grey.shade500),
      //               filled: true,
      //               fillColor: Colors.white,
      //               border: OutlineInputBorder(
      //                 borderRadius: BorderRadius.circular(50),
      //                 borderSide: BorderSide.none,
      //               ),
      //               contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      //             ),
      //           ),

      //         const SizedBox(height: 24),
      //         _errorCode != ""
      //             ? Column(
      //                 children: [Text(_errorCode), const SizedBox(height: 24)],
      //               )
      //             : const SizedBox(height: 0),
      //         // OutlinedButton(
      //         //   onPressed: register,
      //         //   child: _isLoading
      //         //       ? const CircularProgressIndicator()
      //         //       : const Text('Register'),
      //         // ),

      //         SizedBox(
      //           width: double.infinity,
      //           child: ElevatedButton(
      //             onPressed: _isLoading ? null : register,
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
      //                     'Sign Up',
      //                     style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w600),
      //                   ),
      //           ),
      //         ),

      //         const SizedBox(height: 16),

      //         Row(
      //               mainAxisAlignment: MainAxisAlignment.center,
      //               children: [
      //                 Text(
      //                   'Already have an account? ',
      //                   style: TextStyle(color: Colors.black  , fontSize: 14.5),
      //                 ),
      //                 GestureDetector(
      //                   onTap: navigateLogin,
      //                   child: Text(
      //                     'Sign In',
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

      //         //Already have an account>
      //       ],
      //     ),
      //   ),
      // ),
    
    
    
    );
  }
}
