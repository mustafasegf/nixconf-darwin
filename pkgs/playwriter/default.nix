{
  lib,
  buildNpmPackage,
  fetchurl,
  jq,
}:

buildNpmPackage rec {
  pname = "playwriter";
  version = "0.1.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/playwriter/-/playwriter-${version}.tgz";
    hash = "sha256-LyUWtEMS7btMAIGvW0GRHYJcvlDBcmFE/XRpcgONNIc=";
  };

  # devDep `mcp-extension` is not published on npm; strip it.
  postPatch = ''
    cp ${./package-lock.json} package-lock.json
    ${lib.getExe jq} 'del(.devDependencies)' package.json > package.json.new
    mv package.json.new package.json
  '';

  npmDepsHash = "sha256-7V0tOOTNFri6dkYk8Z8ftwhkwlxz8ooVflJQXFzS7QQ=";
  dontNpmBuild = true;

  meta = {
    description = "Let your agents control your own Chrome, via CLI or MCP";
    homepage = "https://github.com/remorses/playwriter";
    license = lib.licenses.mit;
    mainProgram = "playwriter";
    platforms = lib.platforms.unix;
  };
}
