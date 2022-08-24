import 'dart:math';
import 'package:danpark/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

enum MobileVerificationState {
  SHOW_MOBILE_FORM_STATE,
  SHOW_OTP_FROM_STATE,
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  MobileVerificationState currentState =
      MobileVerificationState.SHOW_MOBILE_FORM_STATE;
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  late String verificationId;
  bool showloading = false;
  String completePhoneNumber = " ";
  var _dialCode = '';
  void _callBackFunction(String name, String dialCode, String flag) {
    _dialCode = dialCode;
  }

  void showErrorDialog(BuildContext context, String message) {
    // set up the AlertDialog
    final CupertinoAlertDialog alert = CupertinoAlertDialog(
      title: const Text('Error'),
      content: Text('\n$message'),
      actions: <Widget>[
        CupertinoDialogAction(
          isDefaultAction: true,
          child: const Text('Ok'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void signInWithPhoneAuthCredential(
      PhoneAuthCredential phoneAuthCredential) async {
    setState(() {
      showloading = true;
    });
    try {
      final authCredential =
          await _auth.signInWithCredential(phoneAuthCredential);
      setState(() {
        showloading = false;
      });
      if (authCredential.user != null) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      }
    } on FirebaseAuthException catch (e) {
      // TODO
      setState(() {
        showloading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  FirebaseAuth _auth = FirebaseAuth.instance;

  getMobileFormWidget(context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'images/otp_icon.png',
              height: screenHeight * 0.3,
              fit: BoxFit.contain,
            ),
            FadeInDown(
              child: Text(
                'REGISTER',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.grey.shade900),
              ),
            ),
            FadeInDown(
              delay: Duration(milliseconds: 200),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20),
                child: Text(
                  'Enter your phone number to continue, we will send you OTP to verify.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            IntlPhoneField(
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(
                  borderSide: BorderSide(),
                ),
              ),
              initialCountryCode: 'ET',
              controller: phoneController,
              onChanged: (phone) {
                print(phone.countryCode);
                setState(() {
                  completePhoneNumber = phone.completeNumber;
                });
              },
            ),
            SizedBox(
              height: 35,
            ),
            MaterialButton(
              minWidth: double.infinity,
              onPressed: () async {
                if (phoneController.text.isEmpty) {
                  showErrorDialog(context, 'Phone number can\'t be empty.');
                } else {
                  await _auth.verifyPhoneNumber(
                      phoneNumber: completePhoneNumber,
                      verificationCompleted: (PhoneAuthCredential) async {
                        setState(() {
                          showloading = false;
                        });
                        //signInWithPhoneAuthCredential(phoneAuthCredential);
                      },
                      verificationFailed: (verificationFailed) async {
                        setState(() {
                          showloading = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())));
                      },
                      codeSent: (verificationId, resendingToken) async {
                        setState(
                          () {
                            showloading = false;
                            currentState =
                                MobileVerificationState.SHOW_OTP_FROM_STATE;
                            this.verificationId = verificationId;
                          },
                        );
                      },
                      codeAutoRetrievalTimeout: (verificationId) async {});
                }
              },
              child: Text("VERIFY"),
              color: Colors.orange[800],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  getOtpFormWidget(context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 16.0, 10.0, 20.0),
          child: Column(
            children: <Widget>[
              Image.asset(
                'images/password.gif',
                height: screenHeight * 0.3,
                fit: BoxFit.contain,
              ),
              FadeInDown(
                child: Text(
                  'Otp',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.grey.shade900),
                ),
              ),
              FadeInDown(
                delay: Duration(milliseconds: 200),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 20),
                  child: Text(
                    'Enter the code that you received, to verify.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ),
              ),

              TextField(
                controller: otpController,
                onChanged: (value) {
                  if (value.length == 6) {
                    FocusScope.of(context).nextFocus();
                  }
                },
                showCursor: true,
                readOnly: false,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 13.5),
                  counter: Offstage(),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(width: 2, color: Colors.black12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        BorderSide(width: 2, color: Colors.deepOrangeAccent),
                  ),
                ), // Input Decoration
              ), // TextField

              MaterialButton(
                onPressed: () async {
                  PhoneAuthCredential phoneAuthCredential =
                      PhoneAuthProvider.credential(
                          verificationId: verificationId,
                          smsCode: otpController.text);
                  signInWithPhoneAuthCredential(phoneAuthCredential);
                },
                child: Text("Send"),
                color: Colors.deepOrangeAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                textColor: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      child: showloading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : currentState == MobileVerificationState.SHOW_MOBILE_FORM_STATE
              ? getMobileFormWidget(context)
              : getOtpFormWidget(context),
      padding: const EdgeInsets.all(16),
    ));
  }
}
