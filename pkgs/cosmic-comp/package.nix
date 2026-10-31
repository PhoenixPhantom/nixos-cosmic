{
  lib,
  fetchFromGitHub,
  rustPlatform,
  libcosmicAppHook,
  libdisplay-info_0_2,
  libgbm,
  libinput,
  pixman,
  pkg-config,
  seatd,
  stdenv,
  udev,
  systemd,
  useSystemd ? lib.meta.availableOn stdenv.hostPlatform systemd,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "cosmic-comp";
  version = "1.11.0-unstable-2026-10-30";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-comp";
    rev = "eeca8b09cbe44d767354bc7291b518562b531b0b";
    hash = "sha256-Yq6I5/bjiIqKUw8myQMB2eOEDs53/hTuY2wgg594z/U=";
  };

  cargoHash = "sha256-naEuGY14CuYl1aD9dTzgMVVPaapLYLuOH/XpJ36vLu0=";

  separateDebugInfo = true;

  nativeBuildInputs = [
    libcosmicAppHook
    pkg-config
  ];
  buildInputs = [
    libdisplay-info_0_2
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
