enum VpnState { disconnected, connecting, connected, disconnecting, error }

class VpnStatus {
  final VpnState state;
  final String? serverName;
  final String? errorMessage;

  const VpnStatus({
    this.state = VpnState.disconnected,
    this.serverName,
    this.errorMessage,
  });

  VpnStatus copyWith({
    VpnState? state,
    String? serverName,
    String? errorMessage,
  }) {
    return VpnStatus(
      state: state ?? this.state,
      serverName: serverName ?? this.serverName,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}