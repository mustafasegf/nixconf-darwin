{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "kyamlfmt";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "kubernetes-sigs";
    repo = "yaml";
    rev = "v${version}";
    hash = "sha256-49hg7IVPzwxeovp+HTMiWa/10NMMTSTjAdCmIv6p9dw=";
  };

  vendorHash = "sha256-4aI8F7RjJTZ1sSbBY897UfsksqFB4yOhoriDxgwZTUc=";

  subPackages = [ "yamlfmt" ];

  postInstall = ''
    mv $out/bin/yamlfmt $out/bin/kyamlfmt
  '';

  meta = {
    description = "KYAML formatter from sigs.k8s.io/yaml";
    homepage = "https://github.com/kubernetes-sigs/yaml";
    license = lib.licenses.asl20;
    mainProgram = "kyamlfmt";
  };
}
