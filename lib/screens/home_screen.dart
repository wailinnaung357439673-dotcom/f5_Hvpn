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
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Server Selector
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<int>(
                      value: provider.selectedServerIndex,
                      dropdownColor: const Color(0xFF1E293B),
                      underline: const SizedBox(),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      items: provider.serverNames.asMap().entries.map((entry) {
                        return DropdownMenuItem<int>(
                          value: entry.key,
                          child: Text(entry.value),
                        );
                      }).toList(),
                      onChanged: (index) {
                        if (index != null) {
                          provider.selectServer(index);
                        }
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  StatusIndicator(
                    isConnected: provider.isConnected,
                    serverName: provider.status.serverName ?? 'No Server',
                  ),
                  
                  const SizedBox(height: 50),
                  
                  ConnectionButton(
                    isConnected: provider.isConnected,
                    isLoading: provider.isLoading || provider.isConnecting,
                    onPressed: provider.toggleVPN,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  if (provider.isConnecting)
                    const Text(
                      'Connecting...',
                      style: TextStyle(color: Colors.amber, fontSize: 14),
                    ),
                  
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