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
  version = "0.1.1-unstable-2025-05-20";

  src = fetchFromGitHub {
    owner = "cosmic-utils";
    repo = "tasks";
    rev = "e11990353abeddfec22bd6a7542a31a50494f994";
    hash = "sha256-lRNyxqrBQOGqzvh1JJCJ79QYpsJYlHKXPYTE7TgMyDY=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-ZS8dT1RiddE5kQQjNN2+zgpnqDguK2mtMlVdan1gf2g=";

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
