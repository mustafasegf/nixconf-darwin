{
  lib,
  stdenvNoCC,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:

let
  version = "0.7.1";

  sources = {
    "aarch64-darwin" = {
      asset = "slackcli-macos-arm64";
      hash = "sha256-+oLzc6ZKaGv1RPmKTjOnWLv21O4gxIWn0xWqqSmIooE=";
    };
    "x86_64-darwin" = {
      asset = "slackcli-macos";
      hash = "sha256-Ziz7M/A9XLFbzTGwMLYC5UigTBWnJAb8f7lCvJtdcU8=";
    };
    "aarch64-linux" = {
      asset = "slackcli-linux-arm64";
      hash = "sha256-7u1P+qoU548Y0ZMny2RiAjxy2xs/JNDP/snzRpAfoWw=";
    };
    "x86_64-linux" = {
      asset = "slackcli-linux";
      hash = "sha256-Xu1LQkKJNZTEMZ9/BubAUCBYO1+KoXAQmlO6RU1niGU=";
    };
  };

  source =
    sources.${stdenvNoCC.hostPlatform.system}
      or (throw "slackcli: unsupported system ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "slackcli";
  inherit version;

  src = fetchurl {
    url = "https://github.com/shaharia-lab/slackcli/releases/download/v${version}/${source.asset}";
    inherit (source) hash;
  };

  dontUnpack = true;

  nativeBuildInputs = lib.optionals stdenvNoCC.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = lib.optionals stdenvNoCC.hostPlatform.isLinux [ stdenv.cc.cc.lib ];

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/slackcli
    runHook postInstall
  '';

  meta = {
    description = "Command-line tool for interacting with Slack workspaces and channels";
    homepage = "https://github.com/shaharia-lab/slackcli";
    license = lib.licenses.mit;
    mainProgram = "slackcli";
    platforms = builtins.attrNames sources;
  };
}
