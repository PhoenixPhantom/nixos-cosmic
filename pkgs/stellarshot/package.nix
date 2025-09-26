{
  lib,
  fetchFromGitHub,
  libcosmicAppHook,
  rustPlatform,
  just,
  stdenv,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "stellarshot";
  version = "0-unstable-2025-09-25";

  src = fetchFromGitHub {
    owner = "cosmic-utils";
    repo = "stellarshot";
    rev = "e3d1c25800174e654f9705af9157b6734a8bc3fe";
    hash = "sha256-ghu2dFfrQqjKmPAn3m51ClMAT3oBaSV0T9dTaXgSlLQ=";
  };

  cargoHash = "sha256-xHrHDYZTw8dyxHYLZ8fxO5qHnd2M5NEbc0euaSYbH1o=";

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
    "bin-src"
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/stellarshot"
  ];

  # TODO: upstream depends on inter-test side effects and therefore depends on test ordering and lack of concurrency, but tests also do not seem useful
  doCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = {
    homepage = "https://github.com/cosmic-utils/stellarshot";
    description = "Simple backup application using Rustic for the COSMIC Desktop Environment";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [
      # lilyinstarlight
    ];
    platforms = lib.platforms.linux;
    mainProgram = "stellarshot";
  };
}
