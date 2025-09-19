{
  lib,
  fetchFromGitHub,
  rustPlatform,
  libcosmicAppHook,
  pkg-config,
  libclang,
  glib,
  clang,
  glibc,
  clang-tools,
  pulseaudio,
  pipewire,
  udev,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "cosmic-osd";
  version = "1.0.0-alpha.7-unstable-2025-09-12";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-osd";
    rev = "8c35926f25cb67612f58eb8481d06574922675cc";
    hash = "sha256-t6mtACR8xRm/676H7ki/t8EPRLZotLTgoLKKPilIJlw=";
  };

  cargoHash = "sha256-9XUDMf+rDHrpPK07EoF1dpcCqqbkYzhaTu/p9ckmTNk=";

  nativeBuildInputs = [
    libcosmicAppHook
    pkg-config
    libclang.lib
    glib
    clang
  ];
  buildInputs = [
    glibc
    clang-tools
    pipewire
    pulseaudio
    udev
  ];

  LIBCLANG_PATH="${libclang.lib}/lib";
  BINDGEN_EXTRA_CLANG_ARGS = "-isystem ${libclang.lib}/lib/clang/${lib.getVersion clang}/include";


  env.POLKIT_AGENT_HELPER_1 = "/run/wrappers/bin/polkit-agent-helper-1";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "epoch-(.*)"
    ];
  };

  meta = {
    homepage = "https://github.com/pop-os/cosmic-osd";
    description = "OSD for the COSMIC Desktop Environment";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [
      # lilyinstarlight
    ];
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-osd";
  };
}
