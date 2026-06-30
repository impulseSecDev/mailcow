#Networking
{ config, lib, pkgs, ... }:

{
  
   networking.networkmanager.enable = true;
   networking = {
     interfaces.enp2s0 = {
       useDHCP = true;
     };
   };

  systemd.services.init-mailcow-network = {
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
