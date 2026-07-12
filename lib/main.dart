<application
android:label="f5_Hvpn"
android:name="${applicationName}"
android:icon="@mipmap/ic_launcher"
android:usesCleartextTraffic="true"> ```

---

### ၂။ ဒုတိယအချက် - Pastebin လင့်ခ်ရဲ့ ပုံစံ မှားနေခြင်း (Raw ဖြစ်ရပါမယ်)

အစ်ကို Pastebin သုံးပြီး လင့်ခ်ယူထားတယ်ဆိုရင် လင့်ခ်က ရိုးရိုး web link ဖြစ်နေရင် App က ဖတ်လို့မရပါဘူး။ စာသားသီးသန့်ပဲ ပေါ်တဲ့ **Raw Link** ဖြစ်ရပါမယ်။

**ဥပမာ လင့်ခ်ပုံစံ အမှား:** `https://pastebin.com/ABCDEFG` (ဒီလိုဆိုရင် App က ဆိုက်ကြီးတစ်ခုလုံးရဲ့ HTML တွေကို သွားဖတ်မိလို့ ချိတ်မရတာပါ)
**ဥပမာ လင့်ခ်ပုံစံ အမှန် (Raw):** `https://pastebin.com/raw/ABCDEFG` (လင့်ခ်ကြားထဲမှာ `/raw/` ပါရပါမယ်။ ဒါမှ ဆာဗာစာသားသက်သက်ပဲ ဖတ်မိမှာပါ)

---

### ၃။ တကယ်လို့ လင့်ခ်ကိစ္စ လုံးဝ စိတ်ရှုပ်တယ်ဆိုရင် - "ဖိုင်ကို ကုဒ်ထဲ ပြန်ထည့်နည်း" ဖြင့် အမြန်ဆုံး ဇာတ်သိမ်းနည်း

"အွန်လိုင်းလင့်ခ်တွေ၊ အင်တာနက်က ဖတ်တာတွေ ခေတ္တခဏ ထားလိုက်ပါတော့၊ လောလောဆယ် ဖုန်းထဲမှာ တကယ့် Permission လည်း ရပြီးပြီဆိုတော့ ဂျပန်ဆာဗာနဲ့ တကယ် ချိတ်/မချိတ် ချက်ချင်း မြင်ချင်တယ်" ဆိုရင် – 

အွန်လိုင်းက လှမ်းဖတ်တဲ့ စနစ်ကို လုံးဝဖြုတ်ပြီး **အစ်ကို့ Laptop ထဲက ဆာဗာစာသားတွေကို ကုဒ်ထဲမှာပဲ ကွက်တိ ပြန်ထည့်ပြီး ချိတ်ခိုင်းမယ့် `lib/main.dart` ကုဒ်အသစ်** ကို အောက်မှာ ပေးလိုက်ပါတယ်ဗျာ။ ဒါဆိုရင် အင်တာနက်က လင့်ခ်တွေဆီ သွားဖတ်စရာမလိုတော့ဘဲ ခလုတ်နှိပ်တာနဲ့ ချက်ချင်း တန်းချိတ်မှာ ဖြစ်ပါတယ်။

```dart
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

// ⚠️ [အရေးကြီးဆုံးအဆင့်] အောက်က """ နှစ်ခုကြားထဲမှာရှိတဲ့ စာသားတွေကို ဖျက်ပြီး
// အစ်ကို့ Laptop ထဲက အလုပ်လုပ်တဲ့ ဂျပန် .ovpn ဖိုင်စာသားအားလုံးကို အစအဆုံး (Ctrl+A / Ctrl+C) လုပ်ပြီး အစားထိုးထည့်ပေးပါဗျာ။
String vpnConfigString = """
client
dev tun
proto udp
remote 219.100.37.10 1195
resolv-retry infinite
nobind
persist-key
persist-tun
verb 3
auth-user-pass
<ca>
-----BEGIN CERTIFICATE-----
(Laptop ထဲက ဖိုင်ကို အောက်ဆုံးထိဆွဲချပြီး ca စာသားတွေအကုန် ကူးထည့်ရန်)
-----END CERTIFICATE-----
</ca>
<cert>
-----BEGIN CERTIFICATE-----
(Laptop ထဲက cert စာသားတွေအကုန် ကူးထည့်ရန်)
-----END CERTIFICATE-----
</cert>
<key>
-----BEGIN PRIVATE KEY-----
(Laptop ထဲက key စာသားတွေအကုန် ကူးထည့်ရန်)
-----END PRIVATE KEY-----
</key>
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

void toggleVpn() {
if (isConnected) {
engine.disconnect(); // await ဖြုတ်ထားပြီးသားဖြစ်လို့ အမှားမရှိပါ
return;
}

setState(() {
vpnStage = "CONNECTING...";
});

try {
// အွန်လိုင်းက မသွားတော့ဘဲ vpnConfigString ထဲက စာသားကို တိုက်ရိုက်ယူသုံးခြင်း
engine.connect(
vpnConfigString, 
"F5 Japan Server", 
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
Text("Japan Server", style: TextStyle(color: Colors.white70)),
],
),
)
],
),
),
);
}
}