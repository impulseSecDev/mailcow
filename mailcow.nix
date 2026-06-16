{ config, pkgs, lib, ... }:

{
  sops.secrets = {
  };

  # sops.templates."immich.env" = {
  #   content = ''
  #     DB_DATA_LOCATION=/var/lib/immich/postgres
  #     DB_PASSWORD=${config.sops.placeholder."immich_db_password"}
  #     DB_USERNAME=${config.sops.placeholder."immich_db_username"}
  #     DB_DATABASE_NAME=${config.sops.placeholder."immich_db_name"}
  #     POSTGRES_USER=${config.sops.placeholder."immich_db_username"}
  #     POSTGRES_PASSWORD=${config.sops.placeholder."immich_db_password"}
  #     POSTGRES_DB=${config.sops.placeholder."immich_db_name"}
  #     IMMICH_VERSION=release
  #     DB_HOSTNAME=database
  #     REDIS_HOSTNAME=redis
  #     TZ=UTC
  #   '';
  #   path = "/run/secrets/immich.env";
  #   mode = "0440";
  #   owner = "root";
  #   group = "root";
  # };

  virtualisation.docker.enable = true;

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {

      mailcow_service = {
        image = "placeholder";
        environmentFiles = [ config.sops.templates."mailcow.env".path ];
        volumes = [
          "placeholder"
        ];
        ports = [ "443:443" ];
        dependsOn = [ "" ];
        extraOptions = [ 
          "--health-cmd=true"
          "--network=mailcow-internal" 
        ];
      };
    };
  };
}
