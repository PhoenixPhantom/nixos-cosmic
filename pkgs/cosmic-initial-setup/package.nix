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
  version = "1.11.0-unstable-2026-11-10";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-initial-setup";
    rev = "58d0e4c837ddca0d525db0ca8c298776e3648e49";
    hash = "sha256-ffImW87tblGVsVBFAHMBrs1pZgvG4MENhMzSiYAX4P4=";
  };

  cargoHash = "sha256-1pmYtJYaekY58hjUh61JVQeNYQYUWUywStD9TtJ1eoI=";

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
