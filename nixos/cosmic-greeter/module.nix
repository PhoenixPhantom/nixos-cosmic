{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}:

let
  cfg = config.services.displayManager.cosmic-greeter;
  cfgAutoLogin = config.services.displayManager.autoLogin;
in
{
  disabledModules = [
    "${toString modulesPath}/services/display-managers/cosmic-greeter.nix"
  ];

  meta.maintainers = with lib.maintainers; [
    # lilyinstarlight
  ];

  options.services.displayManager.cosmic-greeter = {
    enable = lib.mkEnableOption "COSMIC greeter";
    package = lib.mkPackageOption pkgs "cosmic-greeter" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package
      pkgs.cosmic-comp
      pkgs.cosmic-randr
    ];
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          user = "cosmic-greeter";
          command = ''${lib.getExe' pkgs.coreutils "env"} XCURSOR_THEME="''${XCURSOR_THEME:-Pop}" ${lib.getExe' cfg.package "cosmic-greeter-start"}'';
        };
        initial_session = lib.mkIf (cfgAutoLogin.enable && (cfgAutoLogin.user != null)) {
          user = cfgAutoLogin.user;
          command = ''${lib.getExe' pkgs.coreutils "env"} XCURSOR_THEME="''${XCURSOR_THEME:-Pop}" systemd-cat -t cosmic-session ${lib.getExe' pkgs.cosmic-session "start-cosmic"}'';
        };
      };
    };

    # daemon for querying background state and such
    systemd = {
       services.cosmic-greeter-daemon = {
          wantedBy = [ "multi-user.target" ];
          before = [ "greetd.service" ];
          serviceConfig = {
             Type = "dbus";
             BusName = "com.system76.CosmicGreeter";
             ExecStart = lib.getExe' cfg.package "cosmic-greeter-daemon";
             Restart = "on-failure";
          };
       };
       tmpfiles.settings.cosmic-greeter."/run/cosmic-greeter".d = {
          group = "cosmic-greeter";
          mode = "0755";
          user = "cosmic-greeter";
       };
    };

    # greeter user (hardcoded in cosmic-greeter)
    users.users.cosmic-greeter = {
      description = "COSMIC login greeter user";
      isSystemUser = true;
      home = "/var/lib/cosmic-greeter";
      homeMode = "0750";
      createHome = true;
      group = "cosmic-greeter";
      extraGroups = [ "video" ];
    };
    users.groups.cosmic-greeter = { };

    hardware.graphics.enable = true;
    services.libinput.enable = true;
    services.accounts-daemon.enable = true;
    services.dbus.packages = [ cfg.package ];

    # required for authentication
    security.pam.services.cosmic-greeter = { };
  };
}
