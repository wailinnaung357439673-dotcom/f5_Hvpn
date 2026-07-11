import 'package:flutter/material.dart';

class ConnectionButton extends StatelessWidget {
  final bool isConnected;
  final bool isLoading;
  final VoidCallback onPressed;

  const ConnectionButton({
    super.key,
    required this.isConnected,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: isConnected
                ? [Colors.green.shade400, Colors.green.shade700]
                : [Colors.blue.shade400, Colors.blue.shade700],
          ),
          boxShadow: [
            BoxShadow(
              color: (isConnected ? Colors.green : Colors.blue).withOpacity(0.3),
              blurRadius: 20,
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator(
                  color: Colors.white,
                )
              : Icon(
                  isConnected ? Icons.power_settings_new : Icons.power_off,
                  color: Colors.white,
                  size: 50,
                ),
        ),
      ),
    );
  }
}