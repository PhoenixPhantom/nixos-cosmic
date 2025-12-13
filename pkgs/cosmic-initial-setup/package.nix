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
  version = "1.0.0-unstable-2025-12-09";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-initial-setup";
    rev = "32a9cd9a223f814cb6960aa652845fa930d2d586";
    hash = "sha256-0PS/VeXRfaxsOC6fyjlyojxWmAnxWgaZsR5NMCAWUQM=";
  };

  cargoHash = "sha256-fLLpxs3smfBz90MRNlUGzKzmTX/i01jh85b8wqyr9Tg=";

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
