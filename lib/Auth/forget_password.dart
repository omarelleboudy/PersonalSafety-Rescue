import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'login.dart';
import 'package:safety_rescue/componants/constant.dart';
import 'package:safety_rescue/componants/color.dart';
import 'package:safety_rescue/componants/mediaQuery.dart';
import 'package:safety_rescue/models/forget_password.dart';
import 'package:safety_rescue/services/service_forgetpassword.dart';

class ForgetPassword extends StatefulWidget {
  @override
  _ForgetPasswordState createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  ForgetPasswordService get userService =>
      GetIt.instance<ForgetPasswordService>();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    _isLoading = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: Center(child: Builder(builder: (_) {
          if (_isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Stack(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 100, left: 30),
                  child: Container(
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(fontSize: 30, color: primaryColor),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 145, left: 30),
                  child: Container(
                    child: Text(
                      "Enter the email you registered with",
                      style: TextStyle(fontSize: 17, color: grey),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 165, left: 30),
                  child: Container(
                    child: Text(
                      "then tap Send.",
                      style: TextStyle(fontSize: 17, color: Accent1),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 195),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: Container(
                            height: displaySize(context).height * .07,
                            decoration: kBoxDecorationStyle2,
                            child: TextField(
                              keyboardType: TextInputType.emailAddress,
                              controller: _emailController,
                              style: new TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                errorBorder: InputBorder.none,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                contentPadding: const EdgeInsets.all(20),
                                hintText: "Email",
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 280, left: 70.0, bottom: 10, right: 70),
                  child: Container(
                    height: 50.0,
                    width: 300,
                    child: RaisedButton(
                      color: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30),
                      ),
                      onPressed: () async {
                        setState(() async {
                          setState(() {
                            _isLoading = true;
                          });

                          final forget_Password = ForgetPasswordCredentials(
                            email: _emailController.text,
                          );
                          final result =
                              await userService.forgetPassword(forget_Password);
                          debugPrint(
                              "from forget: " + result.status.toString());
                          debugPrint(
                              "from forget: " + result.result.toString());
                          debugPrint(
                              "from forget: " + result.hasErrors.toString());
                          final title =
                              result.status == 0 ? 'Email Sent!' : 'Error';
                          final text = result.status == 0
                              ? 'Click the link in the mail sent to you to be able to reset your password!'
                              : "Wrong Email";
                          showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                    title: Text(title),
                                    content: Text(text),
                                    actions: <Widget>[
                                      FlatButton(
                                          child: Text('OK'),
                                          onPressed: () {
                                            setState(() {
                                              _isLoading = false;
                                            });
                                            Navigator.of(context).pop();
                                          })
                                    ],
                                  )).then((data) {
                            if (result.status == 0) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Login()));
                            }
                          });
                        });
                      },
                      child: Center(
                        child: Text(
                          'Send',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 350, left: 70.0, bottom: 10, right: 70),
                  child: Container(
                    child: SvgPicture.asset(
                      'assets/images/shield.svg',
                      color: grey,
                    ),
                  ),
                )
              ],
            ),
          );
        })));
  }
}
