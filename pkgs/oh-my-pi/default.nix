{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
}:

let
  version = "17.0.1";

  sources = {
    "aarch64-darwin" = {
      asset = "omp-darwin-arm64";
      hash = "sha256-73v/zOUjOlogosd77hfgpY7uTYaoysxed9BaPO6VTPg=";
    };
    "x86_64-linux" = {
      asset = "omp-linux-x64";
      hash = "sha256-QnqHQ7C073AcxKDGa/HwuRzsBigOjfYilKEU4H+zghU=";
    };
  };

  source =
    sources.${stdenvNoCC.hostPlatform.system}
      or (throw "oh-my-pi: unsupported system ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "oh-my-pi";
  inherit version;

  src = fetchurl {
    url = "https://github.com/can1357/oh-my-pi/releases/download/v${version}/${source.asset}";
    inherit (source) hash;
  };

  dontUnpack = true;

  nativeBuildInputs = lib.optionals stdenvNoCC.hostPlatform.isLinux [ autoPatchelfHook ];

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/omp
    runHook postInstall
  '';

  meta = {
    description = "A coding agent with the IDE wired in";
    homepage = "https://github.com/can1357/oh-my-pi";
    license = lib.licenses.mit;
    mainProgram = "omp";
    platforms = builtins.attrNames sources;
  };
}
