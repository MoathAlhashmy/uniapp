import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uniapp/resources/auth_methods.dart';
import 'package:uniapp/screens/login_screen.dart';
import 'package:uniapp/uitls/colors.dart';
import 'package:uniapp/uitls/utils.dart';
import 'package:uniapp/widgets/text_field_input.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  Uint8List? _image;
  bool _isloading = false;
  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    _usernameController.dispose();
  }

  void selectImage() async {
    final Uint8List? im = await pickImage(ImageSource.gallery);
    if (im == null || !mounted) {
      return;
    }
    setState(() {
      _image = im;
    });
  }

  Future<void> signUpUser() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty ||
        _usernameController.text.trim().isEmpty ||
        _bioController.text.trim().isEmpty) {
      showSnackBar(context, 'Please enter all the fields');
      return;
    }

    setState(() {
      _isloading = true;
    });

    final res = await AuthMethods().signUpUser(
      email: _emailController.text,
      password: _passwordController.text,
      username: _usernameController.text,
      bio: _bioController.text,
      file: _image,
    );

    if (!mounted) return;
    setState(() => _isloading = false);
    if (res != 'success') {
      showSnackBar(context, res);
    }
  }

  void navigateToLogin() {
    Navigator.of(context)
        .pop(MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                flex: 2,
                child: Container(),
              ),
              Image.asset('assets/logo/logo_light.jpg'),
              const SizedBox(
                height: 24,
              ),
              Stack(
                children: [
                  _image != null
                      ? CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 50,
                          backgroundImage: MemoryImage(_image!))
                      : const CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 50,
                          backgroundImage:
                              AssetImage('assets/signup/account_circle.png'),
                        ),
                  Positioned(
                      bottom: -12,
                      right: -12,
                      child: IconButton(
                          onPressed: selectImage,
                          icon: const Icon(Icons.add_a_photo)))
                ],
              ),
              TextFieldInput(
                hintText: 'Enter Your Username',
                textEditingController: _usernameController,
                textInputType: TextInputType.name,
                icon: const Icon(Icons.account_circle),
              ),
              const SizedBox(
                height: 10,
              ),
              TextFieldInput(
                hintText: 'Enter Your Email',
                textEditingController: _emailController,
                textInputType: TextInputType.text,
                icon: const Icon(Icons.email),
              ),
              const SizedBox(
                height: 10,
              ),
              TextFieldInput(
                hintText: 'Enter Your password',
                textEditingController: _passwordController,
                textInputType: TextInputType.text,
                isPass: true,
                icon: const Icon(Icons.password),
              ),
              const SizedBox(
                height: 10,
              ),
              TextFieldInput(
                hintText: 'Enter Your bio',
                textEditingController: _bioController,
                textInputType: TextInputType.text,
                icon: const Icon(Icons.abc_sharp),
              ),
              const SizedBox(
                height: 15,
              ),
              ElevatedButton(
                onPressed: signUpUser,
                child: _isloading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: primaryColor,
                        ),
                      )
                    : Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: const ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(1),
                            ),
                          ),
                        ),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(color: primaryColor),
                        ),
                      ),
              ),
              const SizedBox(
                height: 12,
              ),
              Flexible(
                flex: 2,
                child: Container(),
              ),
              const Divider(
                height: 1,
                thickness: 2,
                color: Colors.black,
              ),
              Flexible(
                flex: 2,
                child: Container(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: const Text('Do you have an account?  '),
                  ),
                  GestureDetector(
                    onTap: navigateToLogin,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Flexible(
                flex: 2,
                child: Container(),
              ),
            ],
          ),
          //SvgPicture.asset('assets/login/background_login_dark.svg')
        ),
      ),
    );
  }
}
