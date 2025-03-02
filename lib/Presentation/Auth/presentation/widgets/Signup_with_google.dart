import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SignupWithGoogle extends StatefulWidget {
  const SignupWithGoogle({super.key});

  @override
  State<SignupWithGoogle> createState() => _SignupWithGoogleState();
}

class _SignupWithGoogleState extends State<SignupWithGoogle> {
  @override
  Widget build(BuildContext context) {
    return SizedBox (
      width: double.infinity,
      child: ElevatedButton(
          onPressed: (){

          },
    style: ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 14),
    backgroundColor: Colors.white, // White Background
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(15),
    side: const BorderSide(color: Colors.grey),)
    ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.face),
              Text('Siginn with google'),

            ],
          )),
    );
  }
}
