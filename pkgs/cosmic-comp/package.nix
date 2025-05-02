{
  lib,
  fetchFromGitHub,
  rustPlatform,
  libcosmicAppHook,
  libdisplay-info,
  libgbm ? null,
  libinput,
  mesa,
  pixman,
  pkg-config,
  seatd,
  stdenv,
  udev,
  xwayland,
  useXWayland ? true,
  systemd,
  useSystemd ? lib.meta.availableOn stdenv.hostPlatform systemd,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "cosmic-comp";
  version = "1.0.0-alpha.7-unstable-2025-04-30";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-comp";
    rev = "d8fd4b241b0d5ee360e31cb5a59e442efcce976a";
    hash = "sha256-2QlNB/FmT6Sti8NAxBTVnhLpjU7GOdJvN0Bu9U8oXiQ=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-mmNPjXs/Vm6WuPCUwk1BMHH13r/vTMt6ujRcgU3VK+8=";

  separateDebugInfo = true;

  nativeBuildInputs = [
    libcosmicAppHook
    pkg-config
  ];
  buildInputs = [
    libdisplay-info
    (if libgbm != null then libgbm else mesa)
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

  preFixup = lib.optionalString useXWayland ''
    libcosmicAppWrapperArgs+=(--prefix PATH : ${lib.makeBinPath [ xwayland ]})
  '';

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
