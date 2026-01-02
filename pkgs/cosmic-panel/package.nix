{
  lib,
  fetchFromGitHub,
  rustPlatform,
  libcosmicAppHook,
  just,
  stdenv,
  util-linux,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "cosmic-panel";
  version = "1.0.1-unstable-2025-12-02";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-panel";
    rev = "8eb8a1b6305213ec7402cb2ec24bef6b501b978a";
    hash = "sha256-1Xwe1uONJbl4wq6QBbTI1suLiSlTzU4e/5WBccvghHE=";
  };

  cargoHash = "sha256-ZkjXZrcA4qKHSjEOxj7+j10PxJw/du8B2Mee2fxPJxs=";

  nativeBuildInputs = [
    libcosmicAppHook
    just
    util-linux
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
    homepage = "https://github.com/pop-os/cosmic-panel";
    description = "Panel for the COSMIC Desktop Environment";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [
      # lilyinstarlight
    ];
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-panel";
  };
}
