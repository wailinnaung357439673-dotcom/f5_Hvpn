import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: F5VpnHomeScreen(),
  ));
}

class F5VpnHomeScreen extends StatefulWidget {
  const F5VpnHomeScreen({super.key});

  @override
  State<F5VpnHomeScreen> createState() => _F5VpnHomeScreenState();
}

class _F5VpnHomeScreenState extends State<F5VpnHomeScreen> {
  String vpnStage = "disconnected"; 
  bool isConnected = false;

  // ခလုတ်နှိပ်လိုက်ရင် အလုပ်လုပ်မယ့် Function
  void toggleVpn() {
    setState(() {
      if (isConnected) {
        // ချိတ်ထားရင် ဖြုတ်မယ်
        vpnStage = "disconnected";
        isConnected = false;
      } else {
        // မချိတ်ရသေးရင် ချိတ်မယ်
        vpnStage = "connected";
        isConnected = true;
      }
    });
  }

  String getStatusText() {
    if (vpnStage == "connected") {
      return "CONNECTED";
    } else {
      return "DISCONNECTED";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("F5 VPN", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // အခြေအနေပြ စာသား
            Text(
              getStatusText(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isConnected ? Colors.green : Colors.redAccent,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 50),

            // ပါဝါခလုတ်ကြီး
            GestureDetector(
              behavior: HitTestBehavior.opaque, // ဘယ်နေရာနှိပ်နှိပ် မိစေရမယ်
              onTap: toggleVpn, // ခလုတ်နှိပ်ရင် toggleVpn ကို သွားမယ်
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isConnected ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  border: Border.all(
                    color: isConnected ? Colors.green : Colors.red,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isConnected ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: Icon(
                  Icons.power_settings_new,
                  size: 70,
                  color: isConnected ? Colors.green : Colors.red,
                ),
              ),
            ),
            const SizedBox(height: 50),
            
            // ဂျပန်နိုင်ငံဆာဗာအတွက် UI
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("🇯🇵", style: TextStyle(fontSize: 20)),
                  SizedBox(width: 12),
                  Text("Japan Server (Free)", style: TextStyle(color: Colors.white70)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}