import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pett_tagg/screens/pet_slide_screen.dart';
import 'package:pett_tagg/screens/sign_in_screen.dart';
import 'package:provider/provider.dart';


class AuthenticationWraper extends StatelessWidget {

  AuthenticationWraper();
  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User>();
    if(firebaseUser != null){
      return PetSlideScreen();
    }
    return SignInScreen();
  }
}