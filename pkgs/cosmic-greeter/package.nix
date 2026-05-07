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
  cosmic-randr,
  xkeyboard_config,
  nix-update-script,
}:

rustPlatform.buildRustPackage rec {
  pname = "cosmic-greeter";
  version = "1.0.12-unstable-2026-04-28";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-greeter";
    rev = "2cbfba0c0b5f822b26664cd7c1e5a161d00daaba";
    hash = "sha256-mfgIVi/o5O715IX7Wt8QHfxzBX6ye+wztWU/GHaj9C0=";
  };

  cargoHash = "sha256-jhugV3eF7g6WU5ez3LzqKc/wP952Zpi8Hplg9SZflns=";

  nativeBuildInputs = [
    libcosmicAppHook
    rustPlatform.bindgenHook
    cmake
    just
  ];
  buildInputs = [
    cosmic-randr
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
    "cargo-target-dir"
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}"
  ];

  env = {
     VERGEN_GIT_COMMIT_DATE = "2025-11-24";
     VERGEN_GIT_SHA = src.rev;
  };

  postPatch = ''
    substituteInPlace src/greeter.rs --replace-fail '/usr/bin/env' '${lib.getExe' coreutils "env"}'
    substituteInPlace src/greeter.rs --replace-fail '/usr/bin/orca' '${lib.getExe orca}'
  '';

  preFixup = ''
    libcosmicAppWrapperArgs+=(
      --prefix PATH : ${lib.makeBinPath [ cosmic-randr ]}
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
