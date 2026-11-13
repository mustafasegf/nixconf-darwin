{ config, pkgs, ... }:

{
  sops = {
    defaultSopsFile = ../../secrets/mustafa-pc.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets.atticd_env = { };
  };

  services = {
    k3s = {
      enable = true;
      role = "server";
      extraFlags = toString [
        "--write-kubeconfig-mode=0644"
        "--tls-san=mustafa-pc"
        "--tls-san=100.77.125.63"
      ];
    };

    atticd = {
      enable = true;
      environmentFile = config.sops.secrets.atticd_env.path;
      settings = {
        listen = "127.0.0.1:8080";
        api-endpoint = "https://cache.mus.sh/";
        garbage-collection.default-retention-period = "4 weeks";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    attic-client
  ];
}
