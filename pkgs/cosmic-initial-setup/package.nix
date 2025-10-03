{
  lib,
  fetchFromGitHub,
  rustPlatform,
  libcosmicAppHook,
  just,
  stdenv,
  openssl,
  udev,
  libinput,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "cosmic-initial-setup";
  version = "1.0.0-beta.1-unstable-2025-09-10";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-initial-setup";
    rev = "ae85d253149402522d578697775a9c3d475d11e3";
    hash = "sha256-bmdy4eKarJht9IUV2nCzFxtSS2yaC/6NKD6eKBXlIsI=";
  };

  cargoHash = "sha256-Q0shfFWRXc7zeHMP+Ruy5u3hW6daP3e7eGOz2OcUhxU=";

  auditable = false;

  nativeBuildInputs = [
    libcosmicAppHook
    just
  ];
  buildInputs = [
    libinput
    openssl
    udev
  ];

  patches = [
    ./disable-language-page.patch
    ./disable-timezone-page.patch
  ];

  env.DISABLE_IF_EXISTS = "/iso/nix-store.squashfs";

  postPatch = ''
     # Installs in $out/etc/xdg/autostart instead of /etc/xdg/autostart
     substituteInPlace justfile --replace-fail \
     "autostart-dst := rootdir / 'etc' / 'xdg' / 'autostart' / desktop-entry" \
     "autostart-dst := prefix / 'etc' / 'xdg' / 'autostart' / desktop-entry"
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
