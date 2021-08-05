import 'package:flutter/material.dart';
import 'package:pett_tagg/utilities/firebase_credentials.dart';
import 'package:pett_tagg/widgets/generic_shadow_button.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordDialog extends StatefulWidget {
  @override
  _ChangePasswordDialogState createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final TextEditingController oldPassword = TextEditingController();
  final TextEditingController newPassword = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  //final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  bool isLoading = false;

  bool currentPasswordStatus = true;

  Future<bool> checkCurrentPassword() async {
    var firebaseUser = FirebaseCredentials().auth.currentUser;
    var authCredentials = EmailAuthProvider.credential(
        email: firebaseUser.email, password: oldPassword.text);
    try {
      await firebaseUser.reauthenticateWithCredential(authCredentials);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      elevation: 5,
      child: Form(
        key: _formKey,
        child: Container(
          height: 400,
          width: 330,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.close_sharp,
                  color: Colors.black45,
                  size: 25,
                ),
              ),
              Center(
                child: Text(
                  "Change Password",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.normal),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Center(
                child: Container(
                  height: 40,
                  width: MediaQuery.of(context).size.width / 1.6,
                  child: Center(
                    child: TextFormField(
                      cursorHeight: 30,
                      validator: (value) {
                        if (value.isNotEmpty) {
                          if (currentPasswordStatus) {
                            return null;
                          } else
                            return 'Incorrect Passowrd.';
                        } else
                          return 'Enter Your Old Password';
                      },
                      controller: oldPassword,
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        hintText: "Enter Your Old Password",
                        hintStyle: TextStyle(
                          fontSize: 17,
                        ),
                        errorStyle: TextStyle(color: Colors.red),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Colors.red,
                            width: 1,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Colors.red,
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Colors.black38,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Colors.black38,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Center(
                child: Container(
                  height: 40,
                  width: MediaQuery.of(context).size.width / 1.6,
                  child: Center(
                    child: TextFormField(
                      cursorHeight: 30,
                      controller: newPassword,
                      obscureText: true,
                      validator: (value) {
                        if (value.isNotEmpty) {
                          return null;
                        } else
                          return 'Enter Your New Password';
                      },
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        hintText: "Enter Your New Password",
                        hintStyle: TextStyle(
                          fontSize: 17,
                        ),
                        errorStyle: TextStyle(color: Colors.red),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Colors.red,
                            width: 1,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Colors.red,
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Colors.black38,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Colors.black38,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Center(
                child: Container(
                  height: 40,
                  width: MediaQuery.of(context).size.width / 1.6,
                  child: Center(
                    child: TextFormField(
                      cursorHeight: 30,
                      controller: confirmPassword,
                      obscureText: true,
                      decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                        hintText: "Re-Enter Your New Password",
                        hintStyle: TextStyle(
                          fontSize: 17,
                        ),
                        errorStyle: TextStyle(color: Colors.red),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Colors.red,
                            width: 1,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Colors.red,
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Colors.black38,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Colors.black38,
                            width: 1,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value.isNotEmpty) {
                          if (value == newPassword.text) {
                            return null;
                          } else
                            return 'Passwords do not match.';
                        } else
                          return 'Please Enter Your New Password';
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Center(
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.pink,
                          strokeWidth: 2,
                        ),
                      )
                    : GenericBShadowButton(
                  buttonText: 'Submit',
                  width: 160,
                  height: 60,
                  onPressed: ()async{
                    if(_formKey.currentState.validate()){
                      currentPasswordStatus = await checkCurrentPassword();
                      setState(() {
                        isLoading = true;
                      });
                      if(currentPasswordStatus){
                        try{
                          await FirebaseCredentials().auth.currentUser.updatePassword(newPassword.text).then((value) {
                            setState(() {
                              isLoading = false;
                            });
                          });
                        }catch(e){
                          print(e);
                        }
                      }

                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*RoundedLoadingButton(
                  controller: _btnController,
                  onPressed: ()async{
                    if(_formKey.currentState.validate()){
                      currentPasswordStatus = await checkCurrentPassword();
                      setState(() {

                      });
                      if(currentPasswordStatus){
                        try{
                          await FirebaseCredentials().auth.currentUser.updatePassword(newPassword.text);
                          _btnController.success();
                        }catch(e){
                          print(e);
                          _btnController.error();
                        }
                      }
                      else{
                        _btnController.error();
                      }
                    }
                  },
                  width: 160,
                  height: 60,
                  loaderStrokeWidth: 2,
                  elevation: 5,
                  animateOnTap: true,
                  curve: Curves.ease,
                  duration: Duration(seconds: 2),
                  child: Container(
                    height: 60,
                    width: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.red,
                    ),
                    child: Center(
                      child: Text(
                        "Submit",
                        style: TextStyle(color: Colors.white, fontSize: 17),
                      ),
                    ),
                  ),
                )*/
