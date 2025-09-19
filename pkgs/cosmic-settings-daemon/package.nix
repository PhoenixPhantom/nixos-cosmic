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
  version = "1.0.0-alpha.7-unstable-2025-09-12";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-settings-daemon";
    rev = "ee782f454a09310a28abe73653e6c82d06a79855";
    hash = "sha256-j0cqvfiL7JuZZjtPX/+dD87z3/2/l7JPmFP/xJgZ+JM=";
  };

  cargoHash = "sha256-1YQ7eQ6L6OHvVihUUnZCDWXXtVOyaI1pFN7YD/OBcfo=";

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
