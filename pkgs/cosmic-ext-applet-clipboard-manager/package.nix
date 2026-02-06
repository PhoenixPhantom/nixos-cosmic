{
  lib,
  fetchFromGitHub,
  libcosmicAppHook,
  rustPlatform,
  just,
  stdenv,
  nix-update-script,
}:

rustPlatform.buildRustPackage rec {
  pname = "cosmic-ext-applet-clipboard-manager";
  version = "0.1.0-unstable-2026-01-29";

  src = fetchFromGitHub {
    owner = "cosmic-utils";
    repo = "clipboard-manager";
    rev = "7cc5868882718a2994418f94b1330f20eae5c8e5";
    hash = "sha256-aciPTGN4yN4xmOB/9/MF+nhiF3JGYF7h4fsFHzL7Fws=";
  };

  cargoHash = "sha256-DmxrlYhxC1gh5ZoPwYqJcAPu70gzivFaZQ7hVMwz3aY=";

  nativeBuildInputs = [
    libcosmicAppHook
    just
  ];

  dontUseJustBuild = true;
  dontUseJustCheck = true;

  justFlags = [
    "--set"
    "prefix"
    (placeholder "out")
    "--set"
    "env-dst"
    "${placeholder "out"}/etc/profile.d/cosmic-ext-applet-clipboard-manager.sh"
    "--set"
    "CLIPBOARD_MANAGER_COMMIT"
    "${src.rev}"
    "--set"
    "bin-src"
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/cosmic-ext-applet-clipboard-manager"
  ];

  preCheck = ''
    export XDG_RUNTIME_DIR="$TMP"
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    homepage = "https://github.com/cosmic-utils/clipboard-manager";
    description = "Clipboard manager for the COSMIC Desktop Environment";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [
      # lilyinstarlight
    ];
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-ext-applet-clipboard-manager";
  };
}
