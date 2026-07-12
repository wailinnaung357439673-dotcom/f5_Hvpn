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

  String vpnConfigString = """
client
dev tun
proto udp
remote 219.100.37.193 1195
resolv-retry infinite
nobind
persist-key
persist-tun
cipher AES-128-CBC
auth SHA1
verb 3
auth-user-pass
<ca>
-----BEGIN CERTIFICATE-----
MIIF7TCCA9WgAwIBAgIQX0wM6+H+6z9fK2k8gT77VzANBgkqhkiG9w0BAQsFADBY
MQswCQYDVQQGEwJKUDEOMAwGA1UEChMFb3Blbmd3MRowGAYDVQQLExF2cG5nYXRl
X2FjYWRlbWljMSEwHwYDVQQDExh2cG5nYXRlX2NhXzIxOS4xMDAuMzcuMTkzMB4X
RTI2MDYwMzA5MDAwMFoXDTM2MDUzMTA5MDAwMFowWDELMAkGA1UEBhMCSlAxDjAM
BgNVBAoTBW9wZW5ndzEaMBgGA1UECxMRdnBuZ2F0ZV9hY2FkZW1pYzEhMB8GA1UE
AxMYdnBuZ2F0ZV9jYV8yMTkuMTAwLjM3LjE5MzCCAiIwDQYJKoZIhvcNAQEBBQAD
ggIPADCCAgoCggIBAL2U64W9y9u68gK6Hw07H96K8rZ/7Y6r3v9KxU7N1wGZ3N2q
6qU8u5d6O2xKj9lZ+8r2j9Xy5w3YV/bZ1U4gY6Z2A7u7/vXgO7j69W9O4+5z5p5u
v+7D+7f47/3L+Xv+v97D+7D+v+7D+7D+v+7D+7D+7D+7D+7D+7D+7D+7D+7D+7D+
/d6p/7f5w5/wF3f37b98+9z6o9y9U/5p5uvv7XgO7j69W9O4+5z5p5uv+7D+7f47
/3L+Xv+v97D+7D+v+7D+7D+v+7D+7D+7D+7D+7D+7D+7D+7D+7D+7D+7D+7D+7D+
/8A3v9f97D+v+v97D+7D+v+7D+7D+v+7D+7D+7D+7D+7D+7D+7D+7D+7D+7D+7D+
/v9KxU7N1wGZ3N2q6qU8u5d6O2xKj9lZ+8r2j9Xy5w3YV/bZ1U4gY6Z2A7u7/vXg
O7j69W9O4+5z5p5uv+7D+7f47/3L+Xv+v97D+7D+v+7D+7D+v+7D+7D+7D+7D+7D+
7D+7D+7D+7D+7D+7D+7D+7D+7D+v+7D+7D+v+7D+7D+v+7D+7D+7D+7D+7D+7D+7D+
7D+7D+7D+7D+7D+7D+7D+7D+7D+7D+7D+7D+v+7D+7D+v+7D+7D+v+7D+7D+7D+7D+
7D+7D+7D+7D+7D+7D+7D+7D+7D+v+7D+7D+v+7D+7D+v+7D+7D+7D+7D+AFAgMBAAGj
HTAbMAwGA1UdEwEB/wQCMAAwCwYDV0PBAQDAgEGMA0GCSqGSIb3DQEBCwUAA4IC
AQA8bVlDkO1wGv5uU2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8Gv5u
U2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8Gv5u
U2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8Gv5u
U2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8Gv5u
U2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8Gv5u
U2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8Gv5u
U2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8Gv5u
U2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8Gv5u
U2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8Gv5u
U2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8Gv5u
U2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8Gv5uU2k8==
-----END CERTIFICATE-----
</ca>
"""; 

  @override
  void initState() {
    super.initState();
    initOpenVpnEngine();
  }

  void initOpenVpnEngine() {
    engine = OpenVPN(
      onVpnStageChanged: (stage, duration) {
        if (!mounted) return;
        setState(() {
          String stageRaw = stage.toString().toLowerCase();
          
          if (stageRaw.contains("connected") && !stageRaw.contains("disconnected")) {
            vpnStage = "CONNECTED";
            isConnected = true;
          } else if (stageRaw.contains("connecting")) {
            vpnStage = "CONNECTING...";
            isConnected = false;
          } else if (stageRaw.contains("disconnecting")) {
            vpnStage = "DISCONNECTING...";
            isConnected = false;
          } else {
            vpnStage = "DISCONNECTED";
            isConnected = false;
          }
        });
      },
      onVpnStatusChanged: (status) {},
    );

    engine.initialize(
      groupIdentifier: "group.com.f5.vpn", 
      providerBundleIdentifier: "com.f5.vpn.VPNExtension",
      localizedDescription: "F5 VPN Connection",
    );
  }

  void toggleVpn() {
    if (isConnected) {
      engine.disconnect();
      return;
    }

    setState(() {
      vpnStage = "CONNECTING...";
    });

    try {
      engine.connect(
        vpnConfigString, 
        "Japan Live Server", 
        username: "vpn", 
        password: "vpn", 
        certIsRequired: false,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          vpnStage = "DISCONNECTED";
          isConnected = false;
        });
      }
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
              vpnStage,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isConnected ? Colors.green : (vpnStage.contains("CONNECTING") ? Colors.orange : Colors.redAccent),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 50),

            InkWell(
              onTap: toggleVpn, 
              borderRadius: BorderRadius.circular(100),
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
                  Text("🇯🇵", style: TextStyle(fontSize: 20)),
                  SizedBox(width: 12),
                  Text("Japan Premium Server", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}