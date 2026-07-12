import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  static final RemoteConfig _remoteConfig = RemoteConfig.instance;
  static bool _initialized = false;
  static List<String> _serverList = [];
  static int _currentIndex = 0;

  static Future<void> init() async {
    if (_initialized) return;
    
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(minutes: 1),
      ),
    );

    await _remoteConfig.setDefaults({
      'server_list': '["sg-sin.vpngate.net:1194", "us-ny.vpngate.net:1194"]',
      'vpn_config_1': '''
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
''',
      'vpn_config_2': '''
client
dev tun
proto udp
remote us-ny.vpngate.net 1194
resolv-retry infinite
nobind
remote-cert-tls server
cipher AES-256-GCM
verb 3
auth-user-pass
''',
    });

    _initialized = true;
    await _loadServerList();
  }

  static Future<void> _loadServerList() async {
    try {
      final jsonString = _remoteConfig.getString('server_list');
      _serverList = List<String>.from(jsonDecode(jsonString));
    } catch (e) {
      _serverList = ['sg-sin.vpngate.net:1194', 'us-ny.vpngate.net:1194'];
    }
  }

  static Future<String> getVpnConfig() async {
    await init();
    try {
      await _remoteConfig.fetchAndActivate();
      await _loadServerList();
      return _remoteConfig.getString('vpn_config_1');
    } catch (e) {
      return _remoteConfig.getString('vpn_config_1');
    }
  }

  static Future<String> getNextConfig() async {
    await init();
    _currentIndex = (_currentIndex + 1) % _serverList.length;
    final configKey = 'vpn_config_${_currentIndex + 1}';
    
    try {
      return _remoteConfig.getString(configKey);
    } catch (e) {
      return _remoteConfig.getString('vpn_config_1');
    }
  }

  static Future<List<String>> getServerList() async {
    await init();
    return _serverList;
  }

  static int getCurrentIndex() => _currentIndex;
}