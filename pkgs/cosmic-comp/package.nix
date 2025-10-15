{
  lib,
  fetchFromGitHub,
  rustPlatform,
  libcosmicAppHook,
  libdisplay-info,
  libgbm,
  libinput,
  mesa,
  pixman,
  pkg-config,
  seatd,
  stdenv,
  udev,
  xwayland,
  systemd,
  useSystemd ? lib.meta.availableOn stdenv.hostPlatform systemd,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "cosmic-comp";
  version = "1.0.0-beta.1.1-unstable-2025-10-15";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-comp";
    rev = "de32b0cb81af69c3dc5aa4ded735dc357e45e935";
    hash = "sha256-VMM26rSO1ldM5WgoSJ5z89UgEK2GFNyDbqwdN53p8J8=";
  };

  cargoHash = "sha256-hqw5nGKP0nw00qQoHyrcryVg2Kkdnx6yyJIERbh3DFE=";

  separateDebugInfo = true;

  nativeBuildInputs = [
    libcosmicAppHook
    pkg-config
  ];
  buildInputs = [
    libdisplay-info
    libgbm
    libinput
    pixman
    seatd
    udev
  ] ++ lib.optional useSystemd systemd;

  # only default feature is systemd
  buildNoDefaultFeatures = !useSystemd;

  dontCargoInstall = true;

  makeFlags = [
    "prefix=${placeholder "out"}"
    "CARGO_TARGET_DIR=target/${stdenv.hostPlatform.rust.cargoShortTarget}"
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "epoch-(.*)"
    ];
  };

  meta = {
    homepage = "https://github.com/pop-os/cosmic-comp";
    description = "Compositor for the COSMIC Desktop Environment";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [
      # lilyinstarlight
    ];
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-comp";
  };
}
