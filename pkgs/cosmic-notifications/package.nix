{
  lib,
  fetchFromGitHub,
  rustPlatform,
  libcosmicAppHook,
  just,
  stdenv,
  which,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "cosmic-notifications";
  version = "1.8.0-unstable-2026-09-15";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-notifications";
    rev = "cece6820ec1f082477efaa6b256c350744fc3405";
    hash = "sha256-56l5rwh1H7Am6F4S5qh3/XCZzPEh7RmHmsuwjGij9/0=";
  };

  cargoHash = "sha256-kj84JxsqTD0WnNkUqWJj4SXS8xtI1xNXmn2VcTe6Qs8=";

  nativeBuildInputs = [
    libcosmicAppHook
    just
    which
  ];

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

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "epoch-(.*)"
    ];
  };

  meta = {
    homepage = "https://github.com/pop-os/cosmic-notifications";
    description = "Notifications for the COSMIC Desktop Environment";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [
      # lilyinstarlight
    ];
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-notifications";
  };
}
