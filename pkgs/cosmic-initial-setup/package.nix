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
  version = "1.10.0-unstable-2026-10-06";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-initial-setup";
    rev = "8b025bc9eec4844d8c01fb238e5298b3db920b3f";
    hash = "sha256-SAbbe3CipVUQxYLFaOLpR95fUQ+fxu+8NDdVXXLRQGo=";
  };

  cargoHash = "sha256-d0qficlr2/FwqJ3TjZ+B1Y8kxlWI6rj7oQwiX1vY0xQ=";

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
