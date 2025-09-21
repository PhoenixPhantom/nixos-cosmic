{
  lib,
  rustPlatform,
  fetchFromGitHub,
  libcosmicAppHook,
  pkg-config,
  stdenv,
  libgbm,
  libinput,
  udev,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "cosmic-workspaces-epoch";
  version = "1.0.0-alpha.7-unstable-2025-09-17";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-workspaces-epoch";
    rev = "85436fa9d6d5156a2f27076c96b6e62b46dcefa5";
    hash = "sha256-sJbaQWUyWSf/33bpFQwLj193sZenKYAgsZzXInAOLKs=";
  };

  cargoHash = "sha256-ICZSp1lE8he+aQN9zjdHF9gGy2KqcVX7xZwtCd8ar6U=";

  nativeBuildInputs = [
    libcosmicAppHook
    pkg-config
  ];
  buildInputs = [
    libgbm
    libinput
    udev
  ];

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
    homepage = "https://github.com/pop-os/cosmic-workspaces-epoch";
    description = "Workspaces Epoch for the COSMIC Desktop Environment";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [
      # lilyinstarlight
    ];
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-workspaces";
  };
}
