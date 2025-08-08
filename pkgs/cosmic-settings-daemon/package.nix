{
  lib,
  fetchFromGitHub,
  rustPlatform,
  geoclue2-with-demo-agent,
  openssl,
  libinput,
  libxkbcommon,
  pkg-config,
  pulseaudio,
  udev,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "cosmic-settings-daemon";
  version = "1.0.0-alpha.7-unstable-2025-08-04";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-settings-daemon";
    rev = "151780eee4262a08ff3abf63d8d7d1c69b575dc0";
    hash = "sha256-N7M2A+Xo/E9wTkOAl6DkYqtGVn0knAzjKQUt/BhGkOA=";
  };

  cargoHash = "sha256-LJb+HXhXwX5u2X5W7/Fj3erkkLcLx8EnGsqGLNIxIX0=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    libinput
    pulseaudio
    udev
    libxkbcommon
    openssl.dev
  ];

  env = {
     GEOCLUE_AGENT = "${lib.getLib geoclue2-with-demo-agent}/libexec/geoclue-2.0/demos/agent";
  };

  postInstall = ''
    mkdir -p $out/share/{polkit-1/rules.d,cosmic/com.system76.CosmicSettings.Shortcuts/v1}
    cp data/polkit-1/rules.d/*.rules $out/share/polkit-1/rules.d/
    cp data/system_actions.ron $out/share/cosmic/com.system76.CosmicSettings.Shortcuts/v1/system_actions
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "epoch-(.*)"
    ];
  };

  meta = {
    homepage = "https://github.com/pop-os/cosmic-settings-daemon";
    description = "Settings daemon for the COSMIC Desktop Environment";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [
      # lilyinstarlight
    ];
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-settings-daemon";
  };
}
