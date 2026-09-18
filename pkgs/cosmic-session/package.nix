{
  lib,
  fetchFromGitHub,
  rustPlatform,
  bash,
  dbus,
  just,
  stdenv,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "cosmic-session";
  version = "1.8.0-unstable-2026-09-16";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-session";
    rev = "2770d1155ae1503dfaa7807548363e77cb849e9c";
    hash = "sha256-1aYc2YTy4Z+ihmONveNcbopod5jxrx7Ch9m4RnWs9bU=";
  };

  cargoHash = "sha256-IoSLvxpc/1X1a6cDl4ZpoUpxHM7bsH3v2BU6wiQROhM=";

  postPatch = ''
    substituteInPlace data/start-cosmic \
      --replace-fail /usr/bin/cosmic-session "${placeholder "out"}/bin/cosmic-session" \
      --replace-fail /usr/bin/dbus-run-session '${lib.getBin dbus}/bin/dbus-run-session}'
    substituteInPlace data/cosmic.desktop \
      --replace-fail /usr/bin/start-cosmic "${placeholder "out"}/bin/start-cosmic"
  '';

  nativeBuildInputs = [ just ];
  buildInputs = [ bash ];

  dontUseJustBuild = true;

  justFlags = [
    "--set"
    "prefix"
    (placeholder "out")
    "--set"
    "cargo-target-dir"
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}"
    "--set"
    "cosmic_dconf_profile"
    "${placeholder "out"}/etc/dconf/profile/cosmic"
  ];

  env = {
    ORCA = "orca"; # use `orca` from PATH (instead of absolute path) if available
  };

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [
        "--version-regex"
        "epoch-(.*)"
      ];
    };
    providedSessions = [ "cosmic" ];
  };

  meta = {
    homepage = "https://github.com/pop-os/cosmic-session";
    description = "Session manager for the COSMIC Desktop Environment";
    license = lib.licenses.gpl3Only;
    mainProgram = "cosmic-session";
    maintainers = with lib.maintainers; [
      # lilyinstarlight
    ];
    platforms = lib.platforms.linux;
  };
}
