#Networking
{ config, lib, pkgs, ... }:

{
  
   networking.networkmanager.enable = true;
   networking = {
     #useDHCP = false;
     interfaces.enp2s0 = {
       useDHCP = true;
       # ipv4.addresses = {
       #   address = "10.0.0.168";
       #   prefixLength = 24;
       # };  
     };
   };

  systemd.services.init-immich-network = {
    description = "Create Docker network for mailcow isolation";
    after = [ "network.target" "docker.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      ${pkgs.docker}/bin/docker network inspect mailcow-internal >/dev/null 2>&1 || \
      ${pkgs.docker}/bin/docker network create mailcow-internal
    '';
  };
}
