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
  version = "1.12.0-unstable-2026-11-24";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-session";
    rev = "3eaaa04844de1f5d8b1327471fd6fa8dd6cc3444";
    hash = "sha256-uBgPOms5MC7/Z6gvxRfXwM4u2nvo102/IWeglvqKg0s=";
  };

  cargoHash = "sha256-vPvH/tl93ZvQcP5jfTXoLoj6sCcUmHw6wZn17m4eWMQ=";

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
