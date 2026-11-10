{
  lib,
  rustPlatform,
  fetchFromGitea,
  pkg-config,
  dbus,
  systemd,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "bootvine";
  version = "0.1.3";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "wvhulle";
    repo = "bootvine";
    rev = "v${finalAttrs.version}";
    hash = "sha256-WzqLbOcOokwn2XT62YdD3llWZbNhMl/STbJb2Yn2/pQ=";
  };

  cargoLock.lockFile = "${finalAttrs.src}/Cargo.lock";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    dbus
    systemd
  ];

  cargoBuildFlags = [
    "-p"
    "bootvine"
  ];
  cargoTestFlags = [
    "-p"
    "bootvine"
  ];

  meta = {
    description = "Boot and shutdown progress for systemd on the console, as a live tree of jobs";
    homepage = "https://codeberg.org/wvhulle/bootvine";
    license = lib.licenses.gpl3Plus;
    mainProgram = "bootvine";
    platforms = lib.platforms.linux;
  };
})
