{
  lib,
  fetchFromGitHub,
  rustPlatform,
  libcosmicAppHook,
  dbus,
  glib,
  just,
  libinput,
  pkg-config,
  pipewire,
  pulseaudio,
  stdenv,
  udev,
  util-linuxMinimal,
  xkeyboard_config,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "cosmic-applets";
  version = "1.0.0-beta.3-unstable-2025-10-22";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-applets";
    rev = "3835133af1413e3cd13474314f895a31a9140def";
    hash = "sha256-1OJ0yP1Z9K+lXgWUCYGNEZn+XGR613sT2/zhBnbtvaU=";
  };

  cargoHash = "sha256-ZdTA0FbNaiOQX6CnEjlG3ZGZbpP9Wvhcht9WLyEFoxY=";

  nativeBuildInputs = [
    libcosmicAppHook
    just
    pkg-config
    util-linuxMinimal
    rustPlatform.bindgenHook
  ];
  buildInputs = [
    dbus
    glib
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
    "target"
    "${stdenv.hostPlatform.rust.cargoShortTarget}/release"
  ];

  preFixup = ''
    libcosmicAppWrapperArgs+=(
      --set-default X11_BASE_RULES_XML ${xkeyboard_config}/share/X11/xkb/rules/base.xml
      --set-default X11_EXTRA_RULES_XML ${xkeyboard_config}/share/X11/xkb/rules/base.extras.xml
    )
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "epoch-(.*)"
    ];
  };

  meta = {
    homepage = "https://github.com/pop-os/cosmic-applets";
    description = "Applets for the COSMIC Desktop Environment";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [
      # lilyinstarlight
    ];
    platforms = lib.platforms.linux;
  };
}
