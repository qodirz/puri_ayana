import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:puri_ayana_gempol/custom/application_helper.dart';

class CustomNumberField extends StatelessWidget {
  final TextEditingController controller;
  final validator =
      MultiValidator([RequiredValidator(errorText: 'harus di isi!')]);
  final hintText;

  CustomNumberField({this.controller, this.hintText});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hintText,
          style: TextStyle(fontFamily: 'bold', color: baseColor900),
        ),
        SizedBox(height: 4),
        TextFormField(
          validator: validator,
          controller: controller,
          keyboardType: TextInputType.number,
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
              borderRadius: BorderRadius.circular(10.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: new BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.cyan[300]),
            ),
            errorBorder: OutlineInputBorder(
                borderRadius: new BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.cyan[300])),
            errorStyle: TextStyle(color: Colors.redAccent),
          ),
        ),
        SizedBox(height: 16)
      ],
    );
  }
}
