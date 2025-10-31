{
  lib,
  fetchFromGitHub,
  rustPlatform,
  libcosmicAppHook,
  cmake,
  coreutils,
  just,
  libinput,
  linux-pam,
  stdenv,
  udev,
  orca,
  xkeyboard_config,
  nix-update-script,
}:

rustPlatform.buildRustPackage rec {
  pname = "cosmic-greeter";
  version = "1.0.0-beta.4-unstable-2025-10-31";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-greeter";
    rev = "31d0f66d3a5612b6ac383aa53038bf9e434370f3";
    hash = "sha256-GiC2O61jl7oJ/V/4n/e8ovgKRtZEoX+kMk4uM3+QsWA=";
  };

  cargoHash = "sha256-4yRBgFrH4RBpuvChTED+ynx+PyFumoT2Z+R1gXxF4Xc=";

  nativeBuildInputs = [
    libcosmicAppHook
    rustPlatform.bindgenHook
    cmake
    just
  ];
  buildInputs = [
    libinput
    linux-pam
    udev
    orca
  ];

  cargoBuildFlags = [ "--all" ];

  dontUseJustBuild = true;
  dontUseJustCheck = true;

  justFlags = [
    "--set"
    "prefix"
    (placeholder "out")
    "--set"
    "bin-src"
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/cosmic-greeter"
    "--set"
    "daemon-src"
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/cosmic-greeter-daemon"
  ];

  env.VERGEN_GIT_SHA = src.rev;

  postPatch = ''
    substituteInPlace src/greeter.rs --replace-fail '/usr/bin/env' '${lib.getExe' coreutils "env"}'
    substituteInPlace src/greeter.rs --replace-fail '/usr/bin/orca' '${lib.getExe orca}'
  '';

  preFixup = ''
    libcosmicAppWrapperArgs+=(
      --set-default X11_BASE_RULES_XML ${xkeyboard_config}/share/X11/xkb/rules/base.xml
      --set-default X11_BASE_EXTRA_RULES_XML ${xkeyboard_config}/share/X11/xkb/rules/extra.xml
    )
  '';
 
  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "epoch-(.*)"
    ];
  };

  meta = {
    homepage = "https://github.com/pop-os/cosmic-greeter";
    description = "Greeter for the COSMIC Desktop Environment";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [
      # lilyinstarlight
    ];
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-greeter";
  };
}
