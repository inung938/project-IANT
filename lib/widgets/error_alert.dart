import 'package:flutter/material.dart';

class ErrorAlert extends StatelessWidget {
  final String message;
  final VoidCallback onClose;

  const ErrorAlert({
    super.key,
    required this.message,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.red),
            ),
          ),
          GestureDetector(
            onTap: onClose,
            child: const Icon(Icons.close, color: Colors.red),
          )
        ],
      ),
    );
  }
}