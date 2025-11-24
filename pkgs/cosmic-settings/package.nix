{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  libcosmicAppHook,
  cmake,
  cosmic-randr,
  expat,
  fontconfig,
  freetype,
  just,
  isocodes,
  libinput,
  pipewire,
  pkg-config,
  pulseaudio,
  udev,
  util-linux,
  xkeyboard_config,
  nix-update-script,
}:

let
  libcosmicAppHook' = (libcosmicAppHook.__spliced.buildHost or libcosmicAppHook).override {
    includeSettings = false;
  };
in

rustPlatform.buildRustPackage {
  pname = "cosmic-settings";
  version = "1.0.0-beta.7-unstable-2025-11-24";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-settings";
    rev = "6ebc2208ed29dc5f721e1c0c714f3879afec1dfa";
    hash = "sha256-Z+MJMHcyqUnSKSUeYH5PyFFkzUQ33bkFoAd3m/TckrQ=";
  };

  cargoHash = "sha256-Su+yAQLr3Us8YNU8z83XO1UDjjOY3SCGnkmwGaIGFho=";

  nativeBuildInputs = [
    libcosmicAppHook'
    rustPlatform.bindgenHook
    cmake
    just
    pkg-config
    util-linux
  ];
  buildInputs = [
    expat
    fontconfig
    isocodes
    freetype
    libinput
    pipewire
    pulseaudio
    udev
  ];

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

   preFixup = ''
   libcosmicAppWrapperArgs+=(
      --prefix PATH : ${lib.makeBinPath [ cosmic-randr ]}
      --set-default X11_BASE_RULES_XML ${xkeyboard_config}/share/X11/xkb/rules/base.xml
      --set-default X11_BASE_EXTRA_RULES_XML ${xkeyboard_config}/share/X11/xkb/rules/extra.xml
    )
  '';
  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "epoch-(.*)"
    ];
  };

  meta = {
    homepage = "https://github.com/pop-os/cosmic-settings";
    description = "Settings for the COSMIC Desktop Environment";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [
      # lilyinstarlight
    ];
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-settings";
  };
}
