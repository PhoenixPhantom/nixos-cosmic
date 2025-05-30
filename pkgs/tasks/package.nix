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
  version = "0.2.0-unstable-2025-05-30";

  src = fetchFromGitHub {
    owner = "cosmic-utils";
    repo = "tasks";
    rev = "3d244b8d75d393ad893cf48d8b419f07756da8d3";
    hash = "sha256-Qh9ZXZE3VjGN8SYgSBLIqtJj3OclcNXGGXhYPS3Ps0Q=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-zfEx4X5OMuiPP52Ic/VVF8dkRuuC3wx2nXoRoM7c0oo=";

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
