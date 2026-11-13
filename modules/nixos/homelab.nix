{ config, pkgs, ... }:

{
  sops = {
    defaultSopsFile = ../../secrets/mustafa-pc.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets = {
      atticd_env = { };
      github_runner_token = { };
      cloudflared_creds = { };
    };
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
        garbage-collection.default-retention-period = "4 weeks";
      };
    };

    cloudflared = {
      enable = true;
      tunnels."6db95150-9bfe-47b9-9fa7-7bedf552dc42" = {
        credentialsFile = config.sops.secrets.cloudflared_creds.path;
        default = "http_status:404";
        ingress."cache.mus.sh" = "http://127.0.0.1:8080";
      };
    };

    github-runners.mustafa-pc = {
      enable = true;
      url = "https://github.com/mustafasegf/nixconf-darwin";
      tokenFile = config.sops.secrets.github_runner_token.path;
      extraLabels = [ "nix" ];
      replace = true;
      extraPackages = with pkgs; [
        attic-client
        git
      ];
      serviceOverrides = {
        CPUWeight = 20;
        Nice = 10;
      };
    };
  };

  environment.systemPackages = with pkgs; [
    attic-client
  ];
}
