{
  lib,
  fetchFromGitHub,
  rustPlatform,
  libcosmicAppHook,
  stdenv,
  glib,
  libclang,
  clang,
  just,
  nix-update-script,
}:

rustPlatform.buildRustPackage rec {
  pname = "cosmic-files";
  version = "1.0.0-alpha.7-unstable-2025-08-15";

  src = fetchFromGitHub {
     owner = "pop-os";
     repo = "cosmic-files";
     rev = "0bf1a21351a5394864a62411ae5b753f3b310af4";
     hash = "sha256-JF4XUxV2BDw9z7PVIGN2CHcnfuiZ+MXOPRpTJitUt+g=";
  };

  cargoHash = "sha256-TDXo0PsDLIBewAasBK82VsG1O0lPqY6g3dBRFsGzF6A="; 

  nativeBuildInputs = [
    libcosmicAppHook
    libclang.lib
    clang
    just
  ];
  buildInputs = [ 
    glib
  ];

  # Needed so bindgen can find libclang.so
  LIBCLANG_PATH="${libclang.lib}/lib";
  BINDGEN_EXTRA_CLANG_ARGS = "-isystem ${libclang.lib}/lib/clang/${lib.getVersion clang}/include";


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

  # TODO: use tests again, once they do not cause compiler errors every second update
  checkPhase = ''
    #baseCargoTestFlags="$cargoTestFlags"
    # operation tests require io_uring and fail in nix-sandbox
    #cargoTestFlags="$baseCargoTestFlags --package cosmic-files -- --skip operation::tests"
    #runHook cargoCheckHook
    #cargoTestFlags="$baseCargoTestFlags --package cosmic-files-applet"
    #runHook cargoCheckHook
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
