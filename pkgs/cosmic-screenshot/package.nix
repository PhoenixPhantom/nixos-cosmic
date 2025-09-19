{
  lib,
  fetchFromGitHub,
  rustPlatform,
  just,
  stdenv,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "cosmic-screenshot";
  version = "1.0.0-alpha.7-unstable-2025-09-16";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-screenshot";
    rev = "dc054dc6ac56a097629c1e1f0f82d2ca9667abec";
    hash = "sha256-T+zbp1twX49wOkSb6bhb3N3/h83i2cXcxHm91o8ltTI=";
  };

  cargoHash = "sha256-O8fFeg1TkKCg+QbTnNjsH52xln4+ophh/BW/b4zQs9o=";

  nativeBuildInputs = [ just ];

  dontUseJustBuild = true;
  dontUseJustCheck = true;

  justFlags = [
    "--set"
    "prefix"
    (placeholder "out")
    "--set"
    "bin-src"
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/cosmic-screenshot"
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "epoch-(.*)"
    ];
  };

  meta = {
    homepage = "https://github.com/pop-os/cosmic-screenshot";
    description = "Screenshot tool for the COSMIC Desktop Environment";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [
      # lilyinstarlight
    ];
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-screenshot";
  };
}
