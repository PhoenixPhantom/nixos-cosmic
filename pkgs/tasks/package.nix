{
  lib,
  fetchFromGitHub,
  libcosmicAppHook,
  rustPlatform,
  just,
  libsecret,
  openssl,
  sqlite,
  stdenv,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "tasks";
  version = "0.1.1-unstable-2025-05-25";

  src = fetchFromGitHub {
    owner = "cosmic-utils";
    repo = "tasks";
    rev = "0e59faeeaeee9f19b227b0172a67dde8cf77d391";
    hash = "sha256-nVtiYuV5NXAJ192ZVj4dqCJhiEdCkiHh1H7SzEfvyzo=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-oE6+6oOwP+s+zjH6J+wAnZmCG/50jc6pmZfns780v5Q=";

  nativeBuildInputs = [
    libcosmicAppHook
    just
  ];

  buildInputs = [
    libsecret
    openssl
    sqlite
  ];

  dontUseJustBuild = true;
  dontUseJustCheck = true;

  justFlags = [
    "--set"
    "prefix"
    (placeholder "out")
    "--set"
    "bin-src"
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/tasks"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    homepage = "https://github.com/cosmic-utils/tasks";
    description = "Simple task management application for the COSMIC Desktop Environment";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [
      # lilyinstarlight
    ];
    platforms = lib.platforms.linux;
    mainProgram = "tasks";
  };
}
