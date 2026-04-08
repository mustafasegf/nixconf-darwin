{
  lib,
  fetchFromGitHub,
  ghidra,
}:

let
  buildGhidraExtension = ghidra.passthru.buildGhidraExtension;
in
buildGhidraExtension {
  pname = "ghidra-mcp";
  version = "5.0.0-unstable-2026-04-08";

  src = fetchFromGitHub {
    owner = "bethington";
    repo = "ghidra-mcp";
    rev = "2d934b1a7339e41fba914cb58054831e9cd48f76";
    hash = "sha256-Ad0rkk0QHxpSiPYvFVDb0SGlpEKJb1xznbiTjyLjj3E=";
  };

  postPatch = ''
    # Remove test dependencies and Maven Central repo to avoid network access in sandbox.
    sed -i '/repositories {/,/}/d' build.gradle
    sed -i "/testImplementation/d" build.gradle

    # Fix API compatibility with Ghidra 12.0.4 (LoadResults.save signature changed)
    sed -i 's/loadResults\.save(project, /loadResults.save(/g' \
      src/main/java/com/xebyte/core/ProgramScriptService.java
  '';

  meta = {
    description = "HTTP server plugin with 195+ MCP tools for Ghidra reverse engineering automation";
    homepage = "https://github.com/bethington/ghidra-mcp";
    license = lib.licenses.mit;
  };
}
