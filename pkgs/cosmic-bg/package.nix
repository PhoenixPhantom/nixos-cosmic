{
  lib,
  fetchFromGitHub,
  cosmic-wallpapers,
  rustPlatform,
  libcosmicAppHook,
  just,
  nasm,
  stdenv,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "cosmic-bg";
  version = "1.0.11-unstable-2026-04-30";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-bg";
    rev = "b1ca4c180ab29dd185472b777ab0abdb1f96ccaf";
    hash = "sha256-E4OWxoGyRNFcMl7ni7PB6PE0Yl7dE+Wd4JGDMHO94Yw=";
  };

  cargoHash = "sha256-xXq8Dckg3YOf2AT9uOZqVfq00FhZp/X5UU8hLmAln1U=";

  nativeBuildInputs = [
    libcosmicAppHook
    just
    nasm
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

  postPatch = ''
    substituteInPlace config/src/lib.rs data/v1/all \
      --replace-fail '/usr/share/backgrounds/cosmic/orion_nebula_nasa_heic0601a.jpg' \
      "${cosmic-wallpapers}/share/backgrounds/cosmic/orion_nebula_nasa_heic0601a.jpg"
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "epoch-(.*)"
    ];
  };

  meta = {
    homepage = "https://github.com/pop-os/cosmic-bg";
    description = "Applies Background for the COSMIC Desktop Environment";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [
      # lilyinstarlight
    ];
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-bg";
  };
}
