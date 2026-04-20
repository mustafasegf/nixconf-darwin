{ pkgs, config, ... }:

{
  # The GitHub runner secret is NOT managed by sops-nix because it's a full YAML file
  # that needs to be decrypted at runtime, not at build time.

  services.k3s = {
    enable = true;
    extraFlags = toString [
      "--write-kubeconfig-mode=0644"
    ];
    role = "server";
    manifests = {
      # craftycontrol.source = ./../../config/deployment/craftycontrol.yaml;
      leetbot.source = ./../../config/deployment/leetbot.yaml;
    };
    autoDeployCharts = {
      arc = {
        package = ./../../config/deployment/chart/gha-runner-scale-set-controller-0.11.0.tgz;
        targetNamespace = "arc-systems";
        createNamespace = true;
      };

      arc-runner = {
        package = ./../../config/deployment/chart/gha-runner-scale-set-0.11.0.tgz;
        targetNamespace = "arc-runners";
        createNamespace = true;
        values = {
          githubConfigUrl = "https://github.com/mustafasegf";
          githubConfigSecret = "pre-defined-secret";
          controllerServiceAccount.namespace = "arc-system";
          controllerServiceAccount.name = "actions-runner-controller-gha-rs-controller";
          fullnameOverride = "arc-runner";
          runnerScaleSetName = "arc-runner";
        };
      };
    };
  };

  virtualisation.docker.enable = true;

  programs.nix-ld.dev.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    glibc
    zlib
    openssl
    curl
    nss
    nspr
    expat
    icu
    fuse3
  ];

  environment.systemPackages = with pkgs; [
    graalvmPackages.graalvm-ce
    caddy
    bun
    nodejs
    (python312.withPackages (ps: [
      ps.pip
    ]))
  ];

  networking.firewall.allowedTCPPorts = [
    6443
    8443
    25565
    8123
  ];

  systemd.services.k3s-apply-github-secret = {
    description = "Decrypt and Apply GitHub Runner Secret to k3s";
    after = [ "k3s.service" ];
    wants = [ "k3s.service" ];
    wantedBy = [ "multi-user.target" ];
    path = [
      pkgs.sops
      pkgs.kubectl
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "apply-github-secret" ''
        set -euo pipefail
        export SOPS_AGE_KEY_FILE=/home/mustafa/.config/sops/age/keys.txt
        export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
        ${pkgs.sops}/bin/sops -d ${./../../secrets/github-runner.yaml} | ${pkgs.kubectl}/bin/kubectl apply -f -
      '';
      Restart = "on-failure";
      RestartSec = "30s";
    };
  };

  systemd.services.k3s-apply-leetbot-secret = {
    description = "Decrypt and Apply Leetbot Secrets to k3s";
    after = [ "k3s.service" ];
    wants = [ "k3s.service" ];
    wantedBy = [ "multi-user.target" ];
    path = [
      pkgs.sops
      pkgs.kubectl
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "apply-leetbot-secret" ''
        set -euo pipefail
        export SOPS_AGE_KEY_FILE=/home/mustafa/.config/sops/age/keys.txt
        export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
        ${pkgs.sops}/bin/sops -d ${./../../secrets/leetbot.yaml} | ${pkgs.kubectl}/bin/kubectl apply -f -
      '';
      Restart = "on-failure";
      RestartSec = "30s";
    };
  };

  services.cloudflared = {
    enable = true;
    tunnels = {
      "minipc" = {
        credentialsFile = "/home/mustafa/.cloudflared/5d097ed3-3a0b-4540-a6c5-0d893c3fd004.json";
        default = "http_status:404";
        ingress = {
          "mus.sh" = "http://localhost:80";
          "mc.mus.sh" = "http://localhost:8443";
        };
      };
    };
  };

  services.openssh.enable = true;
  services.netdata.enable = true;
}
