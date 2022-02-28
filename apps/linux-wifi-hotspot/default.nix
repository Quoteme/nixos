{ pkgs ? import <nixpkgs> {} }: with pkgs;
stdenv.mkDerivation rec {
  version = "0.1";
  pname = "linux-wifi-hotspot";
  src = builtins.fetchGit {
    url = "https://github.com/lakinduakash/linux-wifi-hotspot.git";
    #ref = "v4.4.0";
  };
  buildInputs = [
    # dependencies
    dnsmasq
    hostapd
    iproute2
    procps-ng
    which
    pkg-config
    x11
    gtk3
    qrencode
    iw
  ];
  makeFlags = [ "DESTDIR=$(out)" "PREFIX=''" ];
  installFlags = [ "sysconfdir=$(out)/etc" "localstatedir=$out/var" ];
  # buildPhase = "ghc --make xmonadctl.hs";
  # installPhase = ''
  #   mkdir -p $out/bin
  #   cp xmonadctl $out/bin/
  #   chmod +x $out/bin/xmonadctl
  # '';
  postInstall = ''
    rm $out/bin/wihotspot
    ln -sf $out/bin/wihotspot-gui $out/bin/wihotspot
    chmod +x $out/bin/wihotspot
  '';
  shellHook = "export PATH=$PATH:./result/bin";
  meta = with lib; {
    author = "lakinduakash";
    description = "";
    homepage = "https://github.com/lakinduakash/linux-wifi-hotspot";
    platforms = platforms.all;
    mainProgram = "linux-wifi-hotspot";
  };  
}
