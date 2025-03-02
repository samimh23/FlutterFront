import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String hintText;
  final TextEditingController? controller;
  final bool isPassword;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.controller,
    this.isPassword = false,
    required  this.validator,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isObscure = true;
  String? _errorMessage;

  void _validateInput(String value) {

      String? validationResult = widget.validator!(value);
      setState(() {
        // Valid if no error message
        _errorMessage = validationResult;
      });

  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        controller: widget.controller,
        obscureText: widget.isPassword ? _isObscure : false,
        onChanged: _validateInput, // Validate on text change
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: const TextStyle(color: Colors.black),
          fillColor: Colors.blue.withOpacity(0.2),

          hintText: widget.hintText,
          hintStyle: const TextStyle(color: Colors.amber),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(10),
          ),

          errorText: _errorMessage, // Show error message
          suffixIcon: widget.isPassword
              ? IconButton(
            icon: Icon(
              _isObscure ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: () {
              setState(() {
                _isObscure = !_isObscure;
              });
            },
          )
              : (_errorMessage == null && widget.controller!.text.isNotEmpty)
              ? const Icon(Icons.check, color: Colors.green) // ✅ Valid
              : (_errorMessage != null)
              ? const Icon(Icons.close, color: Colors.red) // ❌ Invalid
              : null,
        ),
        validator: widget.validator,
      ),
    );
  }
}
