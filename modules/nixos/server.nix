{ pkgs, config, ... }:

{
  # Server profile for NixOS systems
  # Includes k3s, Docker, cloudflared, and other server-specific services

  # Sops secrets configuration
  # Note: The GitHub runner secret is NOT managed by sops-nix because it's a full YAML file
  # that needs to be decrypted at runtime, not at build time.
  # It will be decrypted by the k3s-apply-github-secret service.

  # k3s Kubernetes
  services.k3s = {
    enable = true;
    extraFlags = toString [
      "--write-kubeconfig-mode=0644"
    ];
    role = "server";
    manifests = {
      # craftycontrol.source = ./../../config/deployment/craftycontrol.yaml; # Disabled
      leetbot.source = ./../../config/deployment/leetbot.yaml;
      # GitHub and leetbot secrets are applied by systemd services
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

  # Virtualization
  virtualisation.docker.enable = true;

  # nix-ld for running binaries
  programs.nix-ld.dev.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # toolchain + basics
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

  # Additional server packages
  environment.systemPackages = with pkgs; [
    graalvmPackages.graalvm-ce
    caddy
    bun
    nodePackages.nodejs
    (python312.withPackages (ps: [
      ps.pip
    ]))
    (pkgs.rustPlatform.buildRustPackage rec {
      pname = "trashy";
      version = "c95b22";

      src = fetchFromGitHub {
        owner = "oberblastmeister";
        repo = "trashy";
        rev = "c95b22c0522f616b8700821540a1e58edcf709eb";
        hash = "sha256-O4r/bfK33hJ6w7+p+8uqEdREGUhcaEg+Zjh/T7Bm6sY=";
      };

      cargoHash = "sha256-qrqhIT7FKcRmz9AWAvdbPi1uzVpkGXBJefr3y06n9F0=";

      nativeBuildInputs = [ installShellFiles ];

      preFixup = ''
        installShellCompletion --cmd trash \
          --bash <($out/bin/trash completions bash) \
          --fish <($out/bin/trash completions fish) \
          --zsh <($out/bin/trash completions zsh) \
      '';
    })
  ];

  # Firewall configuration for k3s and services
  networking.firewall.allowedTCPPorts = [
    6443 # k3s API
    8443 # Custom service
    25565 # Minecraft
    8123 # Web service
  ];

  # Systemd service to decrypt and apply the GitHub runner secret to k3s
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
        # Decrypt the secret file using sops with the user's age key
        export SOPS_AGE_KEY_FILE=/home/mustafa/.config/sops/age/keys.txt
        export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
        ${pkgs.sops}/bin/sops -d ${./../../secrets/github-runner.yaml} | ${pkgs.kubectl}/bin/kubectl apply -f -
      '';
      Restart = "on-failure";
      RestartSec = "30s";
    };
  };

  # Systemd service to decrypt and apply the leetbot secrets to k3s
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
        # Decrypt the secret file using sops with the user's age key
        export SOPS_AGE_KEY_FILE=/home/mustafa/.config/sops/age/keys.txt
        export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
        ${pkgs.sops}/bin/sops -d ${./../../secrets/leetbot.yaml} | ${pkgs.kubectl}/bin/kubectl apply -f -
      '';
      Restart = "on-failure";
      RestartSec = "30s";
    };
  };

  # Cloudflared tunnels
  # Note:CredentialsFile path should be set per-machine
  services.cloudflared = {
    enable = true;
    tunnels = {
      "minipc" = {
        # This will be overridden in machine-specific config
        credentialsFile = "/home/mustafa/.cloudflared/5d097ed3-3a0b-4540-a6c5-0d893c3fd004.json";
        default = "http_status:404";
        ingress = {
          "mus.sh" = "http://localhost:80";
          "mc.mus.sh" = "http://localhost:8443";
        };
      };
    };
  };

  # SSH for remote access
  services.openssh.enable = true;
  services.netdata.enable = true;
}
