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
  version = "1.11.0-unstable-2026-11-07";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-session";
    rev = "3fe5d42eda0c3121e67a62b1f67d06f67ecbb09d";
    hash = "sha256-7+AJXz5c/FnotlB7bNWk1qcRFQPMwh9saYLY0eL0IPQ=";
  };

  cargoHash = "sha256-rOaYyy+HXh5fIA8AyIyS1Ix5nD7JP+fScOKeKvCIsRA=";

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
