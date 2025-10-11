{
  config,
  pkgs,
  lib,
  utils,
  modulesPath,
  ...
}:

let
  cfg = config.services.desktopManager.cosmic;
in
{
  disabledModules = [
    "${toString modulesPath}/services/desktop-managers/cosmic.nix"
  ];

  meta.maintainers = with lib.maintainers; [
    # lilyinstarlight
  ];

  options = {
    services.desktopManager.cosmic = {
      enable = lib.mkEnableOption "COSMIC desktop environment";

      xwayland.enable = lib.mkEnableOption "Xwayland support for cosmic-comp" // {
        default = true;
      };
      theme-non-native = lib.mkEnableOption "automatically support theming non-native apps through cosmic-settings" // {
         default = true;
      };
    };

    environment.cosmic.excludePackages = lib.mkOption {
      description = "List of COSMIC packages to exclude from the default environment";
      type = lib.types.listOf lib.types.package;
      default = [ ];
      example = lib.literalExpression "[ pkgs.cosmic-edit ]";
    };
  };

  config = lib.mkIf cfg.enable {
    # environment packages
    environment.pathsToLink = [
      "/share/backgrounds"
      "/share/cosmic"
      "/share/cosmic-layouts"
      "/share/cosmic-themes"
    ];
    environment.systemPackages = utils.removePackagesByName (
      with pkgs;
      [
         cosmic-applets
         cosmic-applibrary
         cosmic-bg
         cosmic-comp
         cosmic-files
         config.services.displayManager.cosmic-greeter.package
         cosmic-idle
         cosmic-initial-setup
         cosmic-launcher
         cosmic-notifications
         cosmic-osd
         cosmic-panel
         cosmic-session
         cosmic-settings
         cosmic-settings-daemon
         cosmic-workspaces-epoch
      ] ++ [
         adwaita-icon-theme
          alsa-utils
          cosmic-edit
          cosmic-icons
          cosmic-player
          cosmic-randr
          cosmic-reader
          cosmic-screenshot
          cosmic-term
          cosmic-wallpapers
          hicolor-icon-theme
          playerctl
          pop-icon-theme
          pop-launcher
          xdg-user-dirs
      ]
      ++ lib.optionals cfg.xwayland.enable [
        xwayland
      ]
      ++ lib.optionals config.services.flatpak.enable [
        cosmic-store
      ]
    ) config.environment.cosmic.excludePackages;

    # xdg portal packages and config
    xdg = {
       # requied by cosmic-osd
       sounds.enable = true;
       icons.fallbackCursorThemes = lib.mkDefault [ "Cosmic" ];
       portal = {
          enable = true;
          extraPortals = with pkgs; [
             xdg-desktop-portal-cosmic
             xdg-desktop-portal-gtk
          ];
          configPackages = lib.mkDefault [ pkgs.xdg-desktop-portal-cosmic ];
       };
    };
   
    systemd = {
       packages = [ pkgs.cosmic-session ];
       user.targets = {
          cosmic-session = {
             wants = [ "xdg-desktop-autostart.target" ];
             before = [ "xdg-desktop-autostart.target" ];
          };
       };
    };
    # fonts
    fonts.packages = utils.removePackagesByName (with pkgs; [
      fira
      noto-fonts
      open-sans
    ]) config.environment.cosmic.excludePackages;

    # xkb config
    environment.sessionVariables.X11_BASE_RULES_XML = "${config.services.xserver.xkb.dir}/rules/base.xml";
    environment.sessionVariables.X11_EXTRA_RULES_XML = "${config.services.xserver.xkb.dir}/rules/base.extras.xml";
    programs.dconf = {
       enable = lib.mkDefault true;
       packages = with pkgs; [ cosmic-session ];
    };
    security = { 
       polkit.enable = true;
       rtkit.enable = true;
       pam.services.cosmic-greeter = {};
    };
    services = {
       accounts-daemon.enable = true;
       displayManager.sessionPackages = [ pkgs.cosmic-session ];
       libinput.enable = true;
       upower.enable = true;

       geoclue2 = {
          enable = true;
          enableDemoAgent = false;
          whitelistedAgents = ["geoclue-demo-agent"];
       };
    };
   
    # sensible defaults
    hardware.bluetooth.enable = lib.mkDefault true;
    networking.networkmanager.enable = lib.mkDefault true;
    services = {
       acpid.enable = lib.mkDefault true;
       avahi.enable = lib.mkDefault true;
       gnome.gnome-keyring.enable = lib.mkDefault true;
       gvfs.enable = lib.mkDefault true;
       orca.enable = lib.mkDefault true; # this is the wrong default if orca is excluded by the user
       power-profiles-daemon.enable = lib.mkDefault (
         !config.hardware.system76.power-daemon.enable
       );
   };

    # module diagnostics
    warnings =
      lib.optional
        (
          lib.elem pkgs.cosmic-files config.environment.cosmic.excludePackages
          && !(lib.elem pkgs.cosmic-session config.environment.cosmic.excludePackages)
        )
        ''
          The COSMIC session may fail to initialise with the `cosmic-files` package excluded via
          `config.environment.cosmic.excludePackages`.

          Please do one of the following:
            1. Remove `cosmic-files` from `config.environment.cosmic.excludePackages`.
            2. Add `cosmic-session` (in addition to `cosmic-files`) to
               `config.environment.cosmic.excludePackages` and ensure whatever session starter/manager you are
               using is appropriately set up.
        '';
  };
}
