{
  lib,
  fetchFromGitHub,
  rustPlatform,
  libcosmicAppHook,
  stdenv,
  glib,
  llvmPackages,
  clang,
  just,
  nix-update-script,
}:

rustPlatform.buildRustPackage rec {
  pname = "cosmic-files";
  version = "1.0.0-alpha.7-unstable-2025-04-30";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-files";
    rev = "6fa890e3f32975bee46689eff5b23b409f53e637";
    hash = "sha256-Rz+15+BWix4CWG4FF/yEaAO2XWoNwjBPl2HhNda8LJs=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-Xl4cf8CbsBarvQ1xAEb0pAhjR1qvxyKm57syAL2xSHQ=";

  # Needed so bindgen can find libclang.so
  LIBCLANG_PATH="${llvmPackages.libclang.lib}/lib";
  BINDGEN_EXTRA_CLANG_ARGS = with pkgs; "-isystem ${llvmPackages.libclang.lib}/lib/clang/${lib.versions.major (lib.getVersion clang)}/include";

  nativeBuildInputs = [
    libcosmicAppHook
    llvmPackages.libclang
    llvmPackages.libcxxClang
    clang
    just
  ];
  buildInputs = [ glib ];

  # TODO: uncomment and remove phases below if these packages can ever be built at the same time
  # NOTE: this causes issues with the desktop instance linking to a window tab when cosmic-files is opened, see <https://github.com/lilyinstarlight/nixos-cosmic/issues/591>
  #cargoBuildFlags = [
  #  "--package"
  #  "cosmic-files"
  #  "--package"
  #  "cosmic-files-applet"
  #];
  # cargoTestFlags = [
  #  "--package"
  #  "cosmic-files"
  #  "--package"
  #  "cosmic-files-applet"
  # ];

  dontUseJustBuild = true;
  dontUseJustCheck = true;

  justFlags = [
    "--set"
    "prefix"
    (placeholder "out")
    "--set"
    "bin-src"
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/cosmic-files"
    "--set"
    "applet-src"
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/cosmic-files-applet"
  ];

  env.VERGEN_GIT_SHA = src.rev;

  # TODO: remove next two phases if these packages can ever be built at the same time
  buildPhase = ''
    baseCargoBuildFlags="$cargoBuildFlags"
    cargoBuildFlags="$baseCargoBuildFlags --package cosmic-files"
    runHook cargoBuildHook
    cargoBuildFlags="$baseCargoBuildFlags --package cosmic-files-applet"
    runHook cargoBuildHook
  '';

  checkPhase = ''
    baseCargoTestFlags="$cargoTestFlags"
    # operation tests require io_uring and fail in nix-sandbox
    cargoTestFlags="$baseCargoTestFlags --package cosmic-files -- --skip operation::tests"
    runHook cargoCheckHook
    cargoTestFlags="$baseCargoTestFlags --package cosmic-files-applet"
    runHook cargoCheckHook
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "epoch-(.*)"
    ];
  };

  meta = {
    homepage = "https://github.com/pop-os/cosmic-files";
    description = "File Manager for the COSMIC Desktop Environment";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [
      # lilyinstarlight
    ];
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-files";
  };
}
