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
  VpnStage? vpnStage;
  bool isConnected = false;

  // စမ်းသပ်ဖို့အတွက် OpenVPN Config (ဒီနေရာမှာ ကိုယ့် .ovpn ဖိုင်ထဲက စာသားတွေကို ထည့်ရမှာပါ)
  // လောလောဆယ် ဒါက ပုံစံပြရုံသက်သက်မို့လို့ တကယ့် Server အစစ်ထည့်မှ ချိတ်မှာပါဗျာ
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
(ကိုယ့်ဆာဗာရဲ့ CA Certificate စာသားများ)
-----END CERTIFICATE-----
</ca>
""";

  @override
  void initState() {
    super.initState();
    // 1. OpenVPN Engine ကို အလုပ်စလုပ်ခိုင်းမယ်
    engine = OpenVPN(
      onVpnStageChanged: (stage, duration) {
        setState(() {
          vpnStage = stage;
          isConnected = stage == VpnStage.connected;
        });
      },
      onVpnStatusChanged: (status) {
        // ဒီမှာ Speed (Byte In/Out) တွေကို လှမ်းဖတ်လို့ရပါတယ်
      },
    );

    // 2. Engine ကို Initialize လုပ်မယ်
    engine.initialize(
      groupIdentifier: "group.com.f5.vpn", // iOS အတွက် (မလိုရင် ဒီတိုင်းထားပါ)
      providerBundleIdentifier: "com.f5.vpn.VPNExtension", // iOS အတွက်
      localizedDescription: "F5 VPN Connection",
    );
  }

  // VPN ကို ချိတ်ဆက်/ဖြတ်တောက်မယ့် Function
  void toggleVpn() async {
    if (isConnected) {
      engine.disconnect();
    } else {
      // VPN ချိတ်ဖို့ အမိန့်ပေးတာ
      engine.connect(
        vpnConfigString, 
        "F5 Server", // ဆာဗာနာမည်
        username: "", // ဆာဗာမှာ Username လိုရင် ထည့်ရန်
        password: "", // ဆာဗာမှာ Password လိုရင် ထည့်ရန်
        certIsRequired: false,
      );
    }
  }

  // VPN ရဲ့ လက်ရှိအခြေအနေအလိုက် ပြသမယ့် စာသား
  String getStatusText() {
    if (vpnStage == null) return "DISCONNECTED";
    switch (vpnStage!) {
      case VpnStage.connected:
        return "CONNECTED";
      case VpnStage.connecting:
        return "CONNECTING...";
      case VpnStage.disconnecting:
        return "DISCONNECTING...";
      default:
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
            // VPN ရဲ့ Status စာသား
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
            
            // ဆာဗာရွေးဖို့ နေရာ (Dummy အနေနဲ့ ပြထားတာပါ)
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