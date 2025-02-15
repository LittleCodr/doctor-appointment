import 'package:flutter/material.dart';

class FormHelper {
  static Widget textInput(
    BuildContext context,
    Object initialValue,
    Function onChanged, {
    bool isTextArea = false,
    bool isNumberInput = false,
    Function? onValidate,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      initialValue: initialValue != "null" ? initialValue.toString() : "",
      decoration: fieldDecoration(context, "", ""),
      maxLines: !isTextArea ? 1 : 3,
      keyboardType: isNumberInput ? TextInputType.number : TextInputType.text,
      onChanged: (String value) {
        return onChanged(value);
      },
      validator: (value) {
        return onValidate!(value);
      },
    );
  }

  static InputDecoration fieldDecoration(
    BuildContext context,
    String hintText,
    String helperText, {
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      contentPadding: EdgeInsets.all(6),
      hintText: hintText,
      helperText: helperText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Theme.of(context).primaryColor,
          width: 1,
        ),
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide(
          color: Theme.of(context).primaryColor,
          width: 1,
        ),
      ),
    );
  }

  static Widget fieldLabel(String labelName) {
    return new Padding(
      padding: EdgeInsets.fromLTRB(0, 5, 0, 10),
      child: Text(
        labelName,
        style: new TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15.0,
        ),
      ),
    );
  }

  static void showMessage(BuildContext context, String title, String message, String buttonText, Function onPressed, {bool isConfirmationDialog = false, String buttonText2 = "", Function? onPressed2}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(
            title,
            style: TextStyle(color: Color(0xFF1F8CED), fontWeight: FontWeight.bold),
          ),
          content: new Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF003165),
            ),
          ),
          actions: [
            new TextButton(
              onPressed: () {
                return onPressed();
              },
              child: new Text(
                buttonText,
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF1F8CED),
                ),
              ),
            ),
            Visibility(
              visible: isConfirmationDialog,
              child: new TextButton(
                onPressed: () {
                  return onPressed2!();
                },
                child: new Text(
                  buttonText2,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF1F8CED),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
