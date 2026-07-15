import 'package:flutter/material.dart';
import 'package:openvpn_flutter/openvpn_flutter.dart';

class VpnProvider extends ChangeNotifier {
  late OpenVPN _engine;
  bool _isConnected = false;
  bool _isConnecting = false;

  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;

  VpnProvider() {
    _init();
  }

  void _init() {
    _engine = OpenVPN(
      onVpnStatusChanged: (data) {
        if (data?.status == "CONNECTED") {
          _isConnected = true;
          _isConnecting = false;
        } else if (data?.status == "CONNECTING") {
          _isConnecting = true;
        } else {
          _isConnected = false;
          _isConnecting = false;
        }
        notifyListeners();
      },
      onVpnStageChanged: (stage, raw) {},
    );
    _engine.initialize(
      groupIdentifier: "group.f5vpn",
      providerBundleIdentifier: "com.f5vpn.openvpn",
      localizedDescription: "F5 VPN",
    );
  }

  Future<void> toggleVPN() async {
    if (_isConnecting) return;

    if (_isConnected) {
      _engine.disconnect();
    } else {
      _isConnecting = true;
      notifyListeners();
      
      const config = """client
dev tun
proto tcp
remote 128.199.65.12 443
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
cipher AES-256-GCM
auth SHA256
verb 3
<ca>
-----BEGIN CERTIFICATE-----
MIIB9TCCAV+gAwIBAgIJAK9aG8X3ZndNMA0GCSqGSIb3DQEBCwUAMIGFMQswCQYD
VQQGEwJTRzESMBAGA1UECAwJU2luZ2Fwb3JlMRIwEAYDVQQHDAlTaW5nYXBvcmUx
-----END CERTIFICATE-----
</ca>""";

      _engine.connect(
        config,
        "Singapore Anti-Block",
        username: "vpn",
        password: "vpn",
      );
    }
  }
}