{ pkgs, ... }:

let
  libfprint-cs9711 = pkgs.libfprint.overrideAttrs (old: {
    pname = "libfprint-cs9711";
    src = pkgs.fetchFromGitHub {
      owner = "archeYR";
      repo = "libfprint-CS9711";
      rev = "02b285c9703c38d308fbe47a3c566ef1e7f883ca";
      hash = "sha256-QGrBNqbRNqLZIURI66xkenlQamNW+DQU4WS+CLN4zM8=";
    };

    buildInputs = old.buildInputs ++ [
      pkgs.opencv
      pkgs.doctest
    ];

    mesonFlags = (builtins.filter (f: f != "-Ddrivers=all") old.mesonFlags) ++ [
      "-Ddrivers=cs9711"
    ];

    postPatch = (old.postPatch or "") + ''
      substituteInPlace libfprint/drivers/cs9711/cs9711.c \
        --replace-fail "CS9711_DEFAULT_RESET_SLEEP  250" "CS9711_DEFAULT_RESET_SLEEP  1500"
    '';

    doInstallCheck = false;
  });
in
{
  services.fprintd = {
    enable = true;
    package = pkgs.fprintd.override { libfprint = libfprint-cs9711; };
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="2541", ATTRS{idProduct}=="0236", MODE="0660", TAG+="uaccess"
  '';

  security.pam.services = {
    login.fprintAuth = true;
    sudo.fprintAuth = true;
  };
}
