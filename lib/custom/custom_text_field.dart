import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

class CustomTextField extends StatelessWidget {
	final TextEditingController controller;
  final validator = MultiValidator([
    RequiredValidator(errorText: 'harus di isi!')
  ]);  
  final hintText;

  CustomTextField({this.controller, this.hintText});
  
	@override
  Widget build(BuildContext context) {
    return TextFormField(  
      validator: validator,                      
      controller: controller,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 20),
        filled: true,
        fillColor: Colors.white,
          hintText: hintText,
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
            borderRadius: BorderRadius.circular(16.0),
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
        ),
    );
  }
	
}
