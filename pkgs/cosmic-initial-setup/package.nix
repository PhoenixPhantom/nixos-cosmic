{
  lib,
  fetchFromGitHub,
  rustPlatform,
  libcosmicAppHook,
  just,
  stdenv,
  openssl,
  udev,
  killall,
  libinput,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "cosmic-initial-setup";
  version = "1.12.0-unstable-2026-11-24";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-initial-setup";
    rev = "edf9290b601d0ebcf432cb858479309246221a1f";
    hash = "sha256-OLannXvC8n7Dom5WBWY4b1UAgC3RcBXtG5ScPYz9B+c=";
  };

  cargoHash = "sha256-4Vl360Gzz34uE9nqIknjW/5y1YdCp6zndvxtVrqtLa0=";

  auditable = false;

  buildFeatures = [ "nixos" ];

  nativeBuildInputs = [
    libcosmicAppHook
    just
  ];
  buildInputs = [
    killall
    libinput
    openssl
    udev
  ];

  env.DISABLE_IF_EXISTS = "/iso/nix-store.squashfs";

  postPatch = ''
     # Installs in $out/etc/xdg/autostart instead of /etc/xdg/autostart
     substituteInPlace justfile --replace-fail \
     "autostart-dst := rootdir / 'etc' / 'xdg' / 'autostart' / desktop-entry" \
     "autostart-dst := prefix / 'etc' / 'xdg' / 'autostart' / desktop-entry"
   '';

   preFixup = ''
    libcosmicAppWrapperArgs+=(--prefix PATH : ${lib.makeBinPath [ killall ]})
  '';

  dontUseJustBuild = true;
  dontUseJustCheck = true;

  justFlags = [
    "--set"
    "prefix"
    (placeholder "out")
    "--set"
    "cargo-target-dir"
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}"
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "epoch-(.*)"
    ];
  };

  meta = {
    homepage = "https://github.com/pop-os/cosmic-initial-setup";
    description = "COSMIC Initial Setup";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [
      #phoenixphantom
    ];
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-initial-setup";
  };
}
