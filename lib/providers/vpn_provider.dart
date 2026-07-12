import 'package:flutter/material.dart';
import 'package:openvpn_flutter/openvpn_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/vpn_status.dart' as my;
import '../services/remote_config_service.dart';

class VpnProvider extends ChangeNotifier {
  OpenVPN? _engine;
  my.VpnStatus _status = const my.VpnStatus();
  bool _isLoading = true;
  String _currentConfig = '';
  List<String> _serverList = [];

  my.VpnStatus get status => _status;
  bool get isConnected => _status.state == my.VpnState.connected;
  bool get isLoading => _isLoading;

  VpnProvider() {
    _init();
  }

  Future<void> _init() async {
    try {
      // Remote Config ကို Load လုပ်ပါ
      await RemoteConfigService.init();
      _serverList = await RemoteConfigService.getServerList();
      _currentConfig = await RemoteConfigService.getVpnConfig();

      _engine = OpenVPN(
        onVpnStageChanged: (stage, raw) {
          _updateStatus(stage);
        },
        onError: (error) {
          _status = _status.copyWith(
            state: my.VpnState.error,
            errorMessage: error.toString(),
          );
          notifyListeners();
          // Error ဖြစ်ရင် နောက် Server ကိုပြောင်းပါ
          _switchToNextServer();
        },
      );

      await _engine?.initialize(
        groupIdentifier: "group.com.f5vpn.app",
        providerBundleIdentifier: "com.f5vpn.app.VPNExtension",
        localizedDescription: "F5 VPN",
      );
    } catch (e) {
      debugPrint('VPN Init Error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  void _updateStatus(VPNStage? stage) {
    if (stage == null) return;
    
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

  Future<void> _switchToNextServer() async {
    try {
      _currentConfig = await RemoteConfigService.getNextConfig();
      _status = _status.copyWith(
        serverName: 'Server ${RemoteConfigService.getCurrentIndex() + 1}',
      );
      notifyListeners();
      
      // အလိုအလျောက် ပြန်ချိတ်ပါ
      if (_status.state == my.VpnState.connected) {
        await _engine?.disconnect();
        await Future.delayed(const Duration(seconds: 2));
        await _connectVPN();
      }
    } catch (e) {
      debugPrint('Switch server error: $e');
    }
  }

  Future<void> _connectVPN() async {
    if (_currentConfig.isEmpty) {
      _status = _status.copyWith(
        state: my.VpnState.error,
        errorMessage: 'No VPN config available',
      );
      notifyListeners();
      return;
    }

    try {
      await _engine?.connect(
        _currentConfig,
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
      _switchToNextServer();
    }
  }

  Future<void> toggleVPN() async {
    if (isConnected) {
      _engine?.disconnect();
      return;
    }

    // Permission check
    final status = await Permission.vpn.request();
    if (!status.isGranted) {
      _status = _status.copyWith(
        state: my.VpnState.error,
        errorMessage: 'VPN Permission required',
      );
      notifyListeners();
      return;
    }

    await _connectVPN();
  }

  // Server ကို လက်နဲ့ပြောင်းချင်ရင်
  Future<void> switchToServer(int index) async {
    if (index < 0 || index >= _serverList.length) return;
    
    try {
      final configKey = 'vpn_config_${index + 1}';
      _currentConfig = await RemoteConfigService.getNextConfig();
      _status = _status.copyWith(
        serverName: 'Server ${index + 1}',
      );
      notifyListeners();

      if (isConnected) {
        await _engine?.disconnect();
        await Future.delayed(const Duration(seconds: 2));
        await _connectVPN();
      }
    } catch (e) {
      debugPrint('Switch server error: $e');
    }
  }

  List<String> getServerList() => _serverList;

  @override
  void dispose() {
    _engine?.disconnect();
    super.dispose();
  }
}