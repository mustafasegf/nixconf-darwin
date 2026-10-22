{
  lib,
  buildNpmPackage,
  fetchurl,
  jq,
  nodejs_24,
}:

buildNpmPackage rec {
  pname = "outline-cli";
  version = "2.1.11";

  src = fetchurl {
    url = "https://registry.npmjs.org/@doist/outline-cli/-/outline-cli-${version}.tgz";
    hash = "sha256-AzaDESoDRGWZHDF10u9ZKt0eNHl4tQK2eQB259loiis=";
  };

  nodejs = nodejs_24;

  # The npm tarball ships prebuilt dist/ but no lockfile; devDeps and the
  # postinstall skill-updater are irrelevant for a store install.
  postPatch = ''
    cp ${./package-lock.json} package-lock.json
    ${lib.getExe jq} 'del(.devDependencies) | del(.scripts)' package.json > package.json.new
    mv package.json.new package.json
  '';

  npmDepsHash = "sha256-Zcrdq4CngRiOFCDsrVopyS4Sl7GNaVBHeAjmRcpNI5c=";
  dontNpmBuild = true;

  postInstall = ''
    export HOME=$(mktemp -d)
    $out/bin/ol skill install universal
    install -Dm644 $HOME/.agents/skills/outline-cli/SKILL.md $out/share/outline-cli/skills/outline-cli/SKILL.md
  '';

  meta = {
    description = "CLI for the Outline wiki/knowledge base API";
    homepage = "https://github.com/Doist/outline-cli";
    license = lib.licenses.mit;
    mainProgram = "ol";
    platforms = lib.platforms.unix;
  };
}
