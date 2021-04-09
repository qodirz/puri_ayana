import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:puri_ayana_gempol/custom/application_helper.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final hintText;

  PasswordField({this.controller, this.hintText});
  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  final passwordValidator = MultiValidator([
    RequiredValidator(errorText: 'password harus di isi!'),
    MinLengthValidator(8,
        errorText: 'sandi harus terdiri dari minimal 8 digit'),
    PatternValidator(r'([0-9])',
        errorText: 'kata sandi harus memiliki setidaknya satu angka')
  ]);

  var obSecure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.hintText,
          style: TextStyle(fontFamily: 'bold', color: baseColor900),
        ),
        TextFormField(
          validator: passwordValidator,
          controller: widget.controller,
          obscureText: obSecure,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 10),
            filled: true,
            fillColor: Colors.white,
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              borderSide: BorderSide(color: Colors.cyan[700]),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              borderSide: BorderSide(color: Colors.cyan[700]),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.cyan[300]),
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: new BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.cyan[300]),
            ),
            errorBorder: OutlineInputBorder(
                borderRadius: new BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.cyan[300])),
            errorStyle: TextStyle(color: Colors.redAccent),
            suffixIcon: IconButton(
              icon: Icon(
                obSecure ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  obSecure = !obSecure;
                });
              },
            ),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }
}
