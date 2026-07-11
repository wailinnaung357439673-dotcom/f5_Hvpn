import 'package:flutter/material.dart';
import 'package:openvpn_flutter/openvpn_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/vpn_status.dart' as my;

class VpnProvider extends ChangeNotifier {
  OpenVPN? _engine;
  my.VpnStatus _status = const my.VpnStatus();
  bool _isLoading = true;

  my.VpnStatus get status => _status;
  bool get isConnected => _status.state == my.VpnState.connected;
  bool get isLoading => _isLoading;

  VpnProvider() {
    _init();
  }

  Future<void> _init() async {
    _engine = OpenVPN(
      onVpnStatusChanged: (status) {
        // Handle status change
      },
      onVpnStageChanged: (stage, raw) {
        _updateStatus(stage);
      },
    );

    await _engine?.initialize(
      groupIdentifier: "group.com.f5vpn.app",
      providerBundleIdentifier: "com.f5vpn.app.VPNExtension",
      localizedDescription: "F5 VPN",
    );
    _isLoading = false;
    notifyListeners();
  }

  void _updateStatus(VPNStage stage) {
    my.VpnState newState;
    switch (stage) {
      case VPNStage.connected:
        newState = my.VpnState.connected;
        break;
      case VPNStage.connecting:
        newState = my.VpnState.connecting;
        break;
      case VPNStage.disconnecting:
        newState = my.VpnState.disconnecting;
        break;
      default:
        newState = my.VpnState.disconnected;
    }
    _status = _status.copyWith(state: newState);
    notifyListeners();
  }

  Future<void> toggleVPN() async {
    if (isConnected) {
      _engine?.disconnect();  // await ဖြုတ်လိုက်တယ်
      return;
    }

    // Permission check
    var status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }

    const config = '''
client
dev tun
proto udp
remote sg-sin.vpngate.net 1194
resolv-retry infinite
nobind
remote-cert-tls server
cipher AES-256-GCM
verb 3
auth-user-pass
''';

    try {
      await _engine?.connect(
        config,
        'F5 VPN',
        username: 'vpn',
        password: 'vpn',
        bypassPackages: [],
      );
    } catch (e) {
      _status = _status.copyWith(
        state: my.VpnState.error,
        errorMessage: e.toString(),
      );
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _engine?.disconnect();
    super.dispose();
  }
}