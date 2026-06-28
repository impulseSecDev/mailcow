{
  description = "NixOS - Mailcow Server";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.1.0";

      # Optional but recommended to limit the size of your system closure.
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-hardware, disko, sops-nix, lanzaboote }: {
    nixosConfigurations.mailbox = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        #./hardware-configuration.nix
        sops-nix.nixosModules.sops
        disko.nixosModules.disko
        lanzaboote.nixosModules.lanzaboote
        ./disko-config.nix
        ./networking.nix
        #./nginx.nix
        #./fail2ban.nix
        #./wireguard.nix
        #./suricata.nix
        #./fluent-bit.nix
        #./wazuh-agent.nix

        ({ config, pkgs, lib, ... }: {
          boot.kernelPackages = pkgs.linuxPackages; 
          boot.supportedFilesystems = lib.mkForce [ "vfat" "fat32" "exfat" "ext4" "btrfs" ];
          boot.loader.systemd-boot.enable = lib.mkForce false;

          boot.lanzaboote = {
            enable = true;
            pkiBundle = "/var/lib/sbctl";
            autoGenerateKeys.enable = true;
            autoEnrollKeys = {
              enable = true;
              # Automatically reboot to enroll the keys in the firmware
              autoReboot = true;
            };
          };

          boot.initrd.luks.devices."cryptroot" = {
            device = "/dev/disk/by-uuid/d318ac2d-1c14-4ed3-97fe-5b9c2b6bba9c";
          };

          swapDevices = [{
            device = "/var/lib/swapfile";
            size = 8*1024;
          }];

          networking.hostName = "mailbox";

          time.timeZone = "UTC";

          programs.neovim.enable = true;
          
          services.tailscale = {
            enable = true;
          };

          users.users.tim = {
            initialPassword = "password";
            isNormalUser = true;
            extraGroups = [ "wheel" ];
            packages = with pkgs; [
              age
              btop
              tmux
              sbctl
            ];
          };

          services.openssh = {
            enable = false;
            ports = [ 22 ];
            settings = {
              PasswordAuthentication = false;
              PermitRootLogin = "no";
            };
          };

          nix.settings.trusted-users = [ "root" "tim" ];

          nix.settings.experimental-features = [ "nix-command" "flakes" ];

          sops = {
            defaultSopsFile = ./secrets/secrets.yaml;
            age.keyFile = "/var/lib/sops-nix/keys.txt";
          }; 

          system.stateVersion = "26.05";
        })
      ];
    };
  };
}
