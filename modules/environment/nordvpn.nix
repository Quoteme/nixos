{ config
, options
, lib
, pkgs
, ...
}@inputs: {
  services.nordvpn.enable = true;

  nixpkgs.config.packageOverrides = pkgs: {
    nordvpn = config.nur.repos.LuisChDev.nordvpn;
  };
  networking.enableIPv6 = false;
  networking.nameservers = [ "103.86.96.100" "103.86.99.100" ];
  networking.firewall =
    let
      tcpPorts = [ 22 24800 25565 ];
      wifiInterface = "wlp0s20f3";
      networks = [
        "172.18.0.1/24"
        "192.168.0.1/24"
        "10.0.0.1/24"
      ];
    in
    {
      enable = false;
      interfaces.${wifiInterface} = {
        allowedTCPPorts = tcpPorts;
        allowedUDPPorts = [
          10001
          10002
          10011
          10012
        ];
      };

      extraCommands =
        let
          mkLocalRule = network: ''
            iptables -A nixos-vpn-killswitch -d ${network} -j ACCEPT
          '';

          localRules = builtins.concatStringsSep "\n" (builtins.map
            (
              n: (mkLocalRule n)
            )
            networks);

          killSwitchRule = ''
            # Flush old firewall rules
            iptables -D OUTPUT -j nixos-vpn-killswitch 2> /dev/null || true
            iptables -F "nixos-vpn-killswitch" 2> /dev/null || true
            iptables -X "nixos-vpn-killswitch" 2> /dev/null || true

            # Create chain
            iptables -N nixos-vpn-killswitch

            # Allow traffic on localhost
            iptables -A nixos-vpn-killswitch -o lo -j ACCEPT

            # Allow lan traffic
            ${localRules}

            # Allow connecition to vpn server
            iptables -A nixos-vpn-killswitch -p udp -m udp --dport 1194 -j ACCEPT
            iptables -A nixos-vpn-killswitch -p udp -m udp --dport 51820 -j ACCEPT

            # Allow connections tunneled over VPN
            iptables -A nixos-vpn-killswitch -o tun0 -j ACCEPT
            iptables -A nixos-vpn-killswitch -o wg0 -j ACCEPT

            # Disallow outgoing traffic by default
            iptables -A nixos-vpn-killswitch -j DROP

            # Enable killswitch
            iptables -A OUTPUT -j nixos-vpn-killswitch
          '';
        in
        ''
          # Enable killswitch by default
          ${killSwitchRule}
        '';

      extraStopCommands = ''
        iptables -D OUTPUT -j nixos-vpn-killswitch
      '';
    };
  # networking.interfaces.wlp6s0.
  # environment.systemPackages = [
  #   pkgs.wireguard-tools
  # ];
}
