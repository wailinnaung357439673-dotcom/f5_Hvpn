import 'package:flutter/material.dart';
import 'package:openvpn_flutter/openvpn_flutter.dart';

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
  late OpenVPN engine;
  String vpnStage = "disconnected"; // VpnStage အစား String ပြောင်းသုံးထားပါတယ်
  bool isConnected = false;

  String vpnConfigString = """
client
dev tun
proto udp
remote 127.0.0.1 1194
resolv-retry infinite
nobind
persist-key
persist-tun
verb 3
<ca>
-----BEGIN CERTIFICATE-----
-----END CERTIFICATE-----
</ca>
""";

  @override
  void initState() {
    super.initState();
    
    engine = OpenVPN(
      onVpnStageChanged: (stage, duration) {
        setState(() {
          // stage ရဲ့ နာမည်ကို String အဖြစ် ပြောင်းမှတ်ပါမယ်
          vpnStage = stage.toString().toLowerCase();
          isConnected = vpnStage.contains("connected") && !vpnStage.contains("connecting");
        });
      },
      onVpnStatusChanged: (status) {
        // Speed tracker
      },
    );

    engine.initialize(
      groupIdentifier: "group.com.f5.vpn",
      providerBundleIdentifier: "com.f5.vpn.VPNExtension",
      localizedDescription: "F5 VPN Connection",
    );
  }

  void toggleVpn() async {
    if (isConnected) {
      engine.disconnect();
    } else {
      engine.connect(
        vpnConfigString, 
        "F5 Server", 
        username: "", 
        password: "", 
        certIsRequired: false,
      );
    }
  }

  // အခြေအနေပြ စာသားကို လိုက်ပြင်ပေးမယ့် Function
  String getStatusText() {
    if (vpnStage.contains("connecting")) {
      return "CONNECTING...";
    } else if (vpnStage.contains("connected")) {
      return "CONNECTED";
    } else if (vpnStage.contains("disconnecting")) {
      return "DISCONNECTING...";
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

            GestureDetector(
              onTap: toggleVpn,
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
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("🇸🇬", style: TextStyle(fontSize: 20)),
                  SizedBox(width: 12),
                  Text("Singapore Server (Free)", style: TextStyle(color: Colors.white70)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}