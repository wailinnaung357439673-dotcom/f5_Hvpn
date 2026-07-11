import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vpn_provider.dart';
import 'widgets/connection_button.dart';
import 'widgets/status_indicator.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Consumer<VpnProvider>(
          builder: (context, provider, child) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StatusIndicator(
                    isConnected: provider.isConnected,
                  ),
                  const SizedBox(height: 50),
                  ConnectionButton(
                    isConnected: provider.isConnected,
                    isLoading: provider.isLoading,
                    onPressed: provider.toggleVPN,
                  ),
                  const SizedBox(height: 20),
                  if (provider.status.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        provider.status.errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}