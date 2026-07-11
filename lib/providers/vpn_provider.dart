import 'package:flutter/material.dart';
import 'package:openvpn_flutter/openvpn_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/vpn_status.dart';

class VpnProvider extends ChangeNotifier {
  OpenVPN? _engine;
  VpnStatus _status = const VpnStatus();
  bool _isLoading = true;

  VpnStatus get status => _status;
  bool get isConnected => _status.state == VpnState.connected;
  bool get isLoading => _isLoading;

  VpnProvider() {
    _init();
  }

  Future<void> _init() async {
    _engine = OpenVPN(
      onVpnStageChanged: (stage, raw) {
        _updateStatus(stage);
      },
      onError: (error) {
        _status = _status.copyWith(state: VpnState.error, errorMessage: error.toString());
        notifyListeners();
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
    VpnState newState;
    switch (stage) {
      case VPNStage.connected:
        newState = VpnState.connected;
        break;
      case VPNStage.connecting:
        newState = VpnState.connecting;
        break;
      case VPNStage.disconnecting:
        newState = VpnState.disconnecting;
        break;
      default:
        newState = VpnState.disconnected;
    }
    _status = _status.copyWith(state: newState);
    notifyListeners();
  }

  Future<void> toggleVPN() async {
    if (isConnected) {
      await _engine?.disconnect();
      return;
    }

    if (!await Permission.vpn.request().then((value) => value.isGranted)) {
      _status = _status.copyWith(state: VpnState.error, errorMessage: 'VPN Permission required');
      notifyListeners();
      return;
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

    await _engine?.connect(config, 'F5 VPN', username: 'vpn', password: 'vpn');
  }

  @override
  void dispose() {
    _engine?.disconnect();
    super.dispose();
  }
}