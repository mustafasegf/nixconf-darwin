{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
}:

let
  version = "18.0.8";

  sources = {
    "aarch64-darwin" = {
      asset = "omp-darwin-arm64";
      hash = "sha256-pWrcR/L08GJEHTMWYiw3ken//HyZaFTk9Z5DNTvZHH8=";
    };
    "x86_64-linux" = {
      asset = "omp-linux-x64";
      hash = "sha256-sVxxYqPMdImMKs52UkFYpKJOQ/nQhlAefacanzoYX4A=";
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
