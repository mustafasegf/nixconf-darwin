{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
}:

let
  version = "16.3.12";

  sources = {
    "aarch64-darwin" = {
      asset = "omp-darwin-arm64";
      hash = "sha256-l7x4f75QMjWQKc7fw7lspCh9FoXJXguElLZLeXmkZvc=";
    };
    "x86_64-darwin" = {
      asset = "omp-darwin-x64";
      hash = "sha256-WDmI3I/rnBloIz9cD9+9oIfhjkg8pJZrKw1k2cS448I=";
    };
    "aarch64-linux" = {
      asset = "omp-linux-arm64";
      hash = "sha256-96AcQhttqbKFqhO2xtjl84c0e7QbBH6LnCzxrM4gsJg=";
    };
    "x86_64-linux" = {
      asset = "omp-linux-x64";
      hash = "sha256-x8sBV2xpbZa5bCHWkegpRRGb87u3MW4+ifxbF+IH27c=";
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
