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
  String vpnStage = "disconnected"; 
  bool isConnected = false;

  // ⚠️ ဒီနေရာမှာ ကိုယ့်ရဲ့ တကယ့် ဂျပန် .ovpn ဖိုင်ထဲက စာသားတွေကို အစားထိုးထည့်ပေးပါ
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
          // Stage တန်ဖိုးကို စာလုံးအသေး ပြောင်းပစ်မယ်
          String currentStage = stage.toString().toLowerCase();
          vpnStage = currentStage;
          
          // လုံးဝတိကျတဲ့ Logic ဖြင့် မှန်ကန်စွာ စစ်ဆေးခြင်း
          if (currentStage.contains("vpn_stage_connected") || currentStage == "connected") {
            isConnected = true;
          } else {
            // disconnected ဖြစ်နေရင်သော်လည်းကောင်း၊ ချိတ်ဆဲ connecting ဖြစ်နေရင်သော်လည်းကောင်း dynamic ဖြစ်စေရမယ်
            isConnected = false;
          }
        });
      },
      onVpnStatusChanged: (status) {
        // Speed Tracker
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
        "F5 Japan Server", 
        username: "", 
        password: "", 
        certIsRequired: false,
      );
    }
  }

  String getStatusText() {
    if (vpnStage.contains("connecting")) {
      return "CONNECTING...";
    } else if (vpnStage.contains("vpn_stage_connected") || vpnStage == "connected") {
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
            
            // ဂျပန်နိုင်ငံဆာဗာအတွက် ပြင်ဆင်ပြီးသား UI
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