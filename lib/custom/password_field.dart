import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

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
    MinLengthValidator(8, errorText: 'sandi harus terdiri dari minimal 8 digit'),  
    PatternValidator(r'([0-9])', errorText: 'kata sandi harus memiliki setidaknya satu angka')  
  ]); 

  var obSecure = true;
  
	@override
  Widget build(BuildContext context) {
    return TextFormField(  
      validator: passwordValidator,                      
      controller: widget.controller,
      obscureText: obSecure,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 20),
        filled: true,
        fillColor: Colors.white,
          hintText: "Password",
          hintStyle: TextStyle(fontFamily: "mon"),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
            borderSide: BorderSide(color: Colors.green, width: 2),              
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
            borderSide: BorderSide(color: Colors.green, width: 2),              
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green[300]),
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: new BorderRadius.circular(16.0),
            borderSide:  BorderSide(color: Colors.green[300]),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: new BorderRadius.circular(16.0),
            borderSide: BorderSide(color: Colors.green[300])
          ),
          errorStyle: TextStyle(color: Colors.red),
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
    );
  }
	
}
