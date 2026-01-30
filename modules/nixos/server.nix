{ pkgs, ... }:

{
  # Server profile for NixOS systems
  # Includes k3s, Docker, cloudflared, and other server-specific services

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
    graalvm-ce
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

  # k3s Kubernetes
  services.k3s = {
    enable = true;
    extraFlags = toString [ ];
    role = "server";
    manifests = {
      deployment.source = ./../../config/deployment/craftycontrol.yaml;
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
          githubConfigUrl = "http://github.com/mustafasegf";
          githubConfigSecret = "pre-defined-secret";
          controllerServiceAccount.namespace = "arc-system";
          controllerServiceAccount.name = "actions-runner-controller-gha-rs-controller";
          fullnameOverride = "arc-runner";
          runnerScaleSetName = "arc-runner";
        };
      };
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
