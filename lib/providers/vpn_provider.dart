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
  List<String> _serverNames = [
    '🇸🇬 Singapore',
    '🇺🇸 USA',
    '🇯🇵 Japan',
    '🇩🇪 Germany',
  ];
  int _selectedServerIndex = 0;
  bool _isConnecting = false;

  my.VpnStatus get status => _status;
  bool get isConnected => _status.state == my.VpnState.connected;
  bool get isLoading => _isLoading;
  bool get isConnecting => _isConnecting;
  int get selectedServerIndex => _selectedServerIndex;
  List<String> get serverNames => _serverNames;

  VpnProvider() {
    _init();
  }

  Future<void> _init() async {
    try {
      await RemoteConfigService.init();
      _serverList = await RemoteConfigService.getServerList();
      _currentConfig = await RemoteConfigService.getVpnConfig();

      _createEngine();
    } catch (e) {
      debugPrint('VPN Init Error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  void _createEngine() {
    _engine = OpenVPN(
      onVpnStageChanged: (stage, raw) {
        _updateStatus(stage);
        if (stage == VPNStage.connected) {
          _isConnecting = false;
          notifyListeners();
        }
      },
      onError: (error) {
        _isConnecting = false;
        _status = _status.copyWith(
          state: my.VpnState.error,
          errorMessage: error.toString(),
        );
        notifyListeners();
      },
    );

    _engine?.initialize(
      groupIdentifier: "group.com.f5vpn.app",
      providerBundleIdentifier: "com.f5vpn.app.VPNExtension",
      localizedDescription: "F5 VPN",
    );
  }

  void _updateStatus(VPNStage? stage) {
    if (stage == null) return;
    
    my.VpnState newState;
    switch (stage) {
      case VPNStage.connected:
        newState = my.VpnState.connected;
        _isConnecting = false;
        break;
      case VPNStage.connecting:
        newState = my.VpnState.connecting;
        _isConnecting = true;
        break;
      case VPNStage.disconnecting:
        newState = my.VpnState.disconnecting;
        break;
      default:
        newState = my.VpnState.disconnected;
        _isConnecting = false;
    }
    _status = _status.copyWith(state: newState);
    notifyListeners();
  }

  Future<void> toggleVPN() async {
    if (_isConnecting) return;

    if (isConnected) {
      // Disconnect
      await _engine?.disconnect();
      _status = _status.copyWith(state: my.VpnState.disconnected);
      _isConnecting = false;
      notifyListeners();
      
      // Engine ကို ပြန်ဖန်တီးပါ (ပြန်ချိတ်နိုင်ဖို့)
      await Future.delayed(const Duration(milliseconds: 500));
      _createEngine();
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

  Future<void> _connectVPN() async {
    if (_currentConfig.isEmpty) {
      _status = _status.copyWith(
        state: my.VpnState.error,
        errorMessage: 'No VPN config available',
      );
      notifyListeners();
      return;
    }

    _isConnecting = true;
    notifyListeners();

    try {
      await _engine?.connect(
        _currentConfig,
        _serverNames[_selectedServerIndex],
        username: 'vpn',
        password: 'vpn',
        bypassPackages: [],
      );
    } catch (e) {
      _isConnecting = false;
      _status = _status.copyWith(
        state: my.VpnState.error,
        errorMessage: e.toString(),
      );
      notifyListeners();
    }
  }

  // Server ပြောင်းမယ်
  Future<void> selectServer(int index) async {
    if (index < 0 || index >= _serverNames.length) return;
    
    _selectedServerIndex = index;
    _status = _status.copyWith(
      serverName: _serverNames[index],
    );
    notifyListeners();

    // Config ကိုပြောင်းပါ
    try {
      final configKey = 'vpn_config_${index + 1}';
      _currentConfig = await RemoteConfigService.getNextConfig();
      
      // ချိတ်ထားရင် ဖြုတ်ပြီး ပြန်ချိတ်ပါ
      if (isConnected) {
        await _engine?.disconnect();
        await Future.delayed(const Duration(milliseconds: 500));
        _createEngine();
        await _connectVPN();
      }
    } catch (e) {
      debugPrint('Switch server error: $e');
    }
  }

  @override
  void dispose() {
    _engine?.disconnect();
    super.dispose();
  }
}