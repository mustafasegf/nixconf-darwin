{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  stdenv,
}:

let
  version = "2.0.0";

  sources = {
    "aarch64-darwin" = {
      target = "aarch64-apple-darwin";
      hash = "sha256-Eh/h7ubZCyLnbk6Yy7YkR07s2XCkpMYi/U1QiJtX2sw=";
    };
    "x86_64-darwin" = {
      target = "x86_64-apple-darwin";
      hash = "sha256-cp5nFmxQlMiVFQtnLNOkRh+omYl+HyTbzQfBO7O0jBM=";
    };
    "aarch64-linux" = {
      target = "aarch64-unknown-linux-gnu";
      hash = "sha256-bDr90Rx8D7kAU9S1OyclK1w1u3XGeTgyNL7yCiVVjqw=";
    };
    "x86_64-linux" = {
      target = "x86_64-unknown-linux-gnu";
      hash = "sha256-r/tZRnLC8iDO9o+nz+uBOUXEAQeJpLjMLA5GRo/reHA=";
    };
  };

  source =
    sources.${stdenvNoCC.hostPlatform.system}
      or (throw "linear-cli: unsupported system ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "linear-cli";
  inherit version;

  src = fetchurl {
    url = "https://github.com/schpet/linear-cli/releases/download/v${version}/linear-${source.target}.tar.xz";
    inherit (source) hash;
  };

  sourceRoot = "linear-${source.target}";

  nativeBuildInputs = lib.optionals stdenvNoCC.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = lib.optionals stdenvNoCC.hostPlatform.isLinux [ stdenv.cc.cc.lib ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 linear $out/bin/linear
    runHook postInstall
  '';

  meta = {
    description = "Command-line interface for the Linear issue tracker";
    homepage = "https://github.com/schpet/linear-cli";
    license = lib.licenses.isc;
    mainProgram = "linear";
    platforms = builtins.attrNames sources;
  };
}
