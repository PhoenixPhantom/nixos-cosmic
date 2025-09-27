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
  version = "1.0.0-beta.1.1-unstable-2025-09-22";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-comp";
    rev = "f339e21479c05153864af79c8fb5d005dcff8abc";
    hash = "sha256-RHeQk1yBNnDN/efuDDWNLn9O7FQTYLBsbs+h+gxi+Xo=";
  };

  cargoHash = "sha256-Jaw2v+02lA5wWRAhRNW/lcLnTI7beJIZ43dqcJ60EP0=";

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
