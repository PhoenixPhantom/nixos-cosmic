{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  libcosmicAppHook,
  just,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "cosmic-ext-applet-caffeine";
  version = "0-unstable-2025-06-07";

  src = fetchFromGitHub {
    owner = "tropicbliss";
    repo = "cosmic-ext-applet-caffeine";
    rev = "c87588e88bdf99d3cd9785c3fa1591d1c7d19815";
    hash = "sha256-SloCdJgF+iD/IMMfaNqdk7tiGdPVBUVYdn5nUfap1Kc=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-BFy3R9Fn1rYBQb4bzBTaL2hpQvswVpU8tqE9MCMsTuQ=";

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
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/cosmic-ext-applet-caffeine"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    homepage = "https://github.com/tropicbliss/cosmic-ext-applet-caffeine";
    description = "Caffeine Applet for the COSMIC desktop";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      # lilyinstarlight
      HeitorAugustoLN
    ];
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-ext-applet-caffeine";
  };
}
