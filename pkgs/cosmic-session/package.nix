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
  version = "1.0.11-unstable-2026-04-13";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-session";
    rev = "9a55864e81b9e0f3cf31862724b738349402c6de";
    hash = "sha256-t7BUBJ9MjTSd2rSkKtiYkltbfcpOcXl2smXxV84l3GY=";
  };

  cargoHash = "sha256-wFh9AYQRZB9qK0vCrhW9Zk61Yg+VY3VPAqJRD47NbK4=";

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
