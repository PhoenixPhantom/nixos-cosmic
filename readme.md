# NixOS COSMIC
This is a nix package set and NixOS module for using System76's COSMIC desktop environment.
The repository aims to provide around weekly updates for the environment which differs from 
the update cadence of NixOS unstable (update only on a new release).

## Usage

### Flakes

If you have an existing `configuration.nix`, you can use the `nixos-cosmic` flake with the following in an adjacent `flake.nix` (e.g. in `/etc/nixos`):


> [!NOTE]
> If switching from traditional evaluation to flakes, `nix-channel` will no longer have any effect on the nixpkgs your system is built with, and therefore `nixos-rebuild --upgrade` will also no longer have any effect. You will need to use `nix flake update` from your flake directory to update nixpkgs and nixos-cosmic.


```nix
# flake.nix
{
  inputs = {
    nixpkgs.follows = "nixos-cosmic/nixpkgs"; # NOTE: change "nixpkgs" to "nixpkgs-stable" to use stable NixOS release
    nixos-cosmic.url = "github:PhoenixPhantom/nixos-cosmic";
  };

  outputs = { self, nixpkgs, nixos-cosmic }: {
    nixosConfigurations = {
      # NOTE: change "host" to your system's hostname
      host = nixpkgs.lib.nixosSystem {
        modules = [
          nixos-cosmic.nixosModules.default
          # other modules to import would go here
          {
            nixpkgs = {
              # You can configure nixpkgs here
              # config.allowUnfree = true;
              overlays = [
                nixos-cosmic.overlays.default
              ];
            };
          }
          ./configuration.nix
        ];
      };
    };
  };
}
```

Then add the following services configuration to your `configuration.nix`:
```nix
# configuration.nix
{config, pkgs, ...}:
{
  # ...
  # your configuration
  # ...


  services = {
    displayManager.cosmic-greeter.enable = true;
    desktopManager.cosmic.enable = true;
    # flatpak.enable = true; # see the section on flatpaks
  };

  # ...
  # your configuration
  # ...
}

```

### Using flatpaks
If you want to use flatpaks on your system (e.g. through the COSMIC store) you should set `services.flatpak.enable = true;` in your `configuration.nix` as indicated above. You can then setup the remote by running `flatpak remote-add --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo` in your terminal.

### Theming
All parts of the COSMIC environment support theming (interface colors can e.g. be changed through cosmic settings). Apps made using the iced toolkit should also automatically follow these settings.

Additionally, if `Apply this theme to GNOME apps` is toggled to on in `Desktop` -> `Appearence` -> `Icons and Toolkit theming` in the COSMIC settings app, GNOME applications using the adwaita toolkit will also follow the same colors as the rest of COSMIC.

Instead of using the cosmic settings app, the last part can currently also be acchieved by creating the text file `~/.config/cosmic/com.system76.CosmicTk/v1/apply_theme_global` with the content `true`.
> [!NOTE]
> Only enabling this setting will not neccessarily cause all GNOME apps to be themed as desired. And it does not reliably make GNOME applications use the icon theme selected in COSMIC.

If some GNOME applications still not respect theming, you can use one of the following variants to get it working for most apps. However, I didn't yet find a way to applications get gtk4 applications that do not use libadwaita to accept the theming. Luckily, there aren't too many such apps.

#### Using Home-Manager
```nix
# inside your home-manager config (i.e. home.nix)
  gtk = {
     enable = true;
     iconTheme.name = "Cosmic"; # ensure GNOME apps adhere to the to the COSMIC iconset (selectable under `Icons and Toolkit theming`)

     gtk3.theme = {
           name="adw-gtk3"; # enable cosmic's theming on GTK3 apps
           package = pkgs.adw-gtk3;
     };
  };
```

#### Without Home-Manager
Install `pkgs.adw-gtk3` i.e. by adding it to `environment-systemPackages` or better, adding it to `users.users."${your_username}".packages`.
Then, manually create or edit the file at `~/.config/gtk-3.0/settings.ini` to include:

```ini
[Settings]
gtk-icon-theme-name=Cosmic
gtk-theme-name=adw-gtk3
```
Additionally, edit the file at `~/.config/gtk-4.0/settings.ini` to include:
```ini
[Settings]
gtk-icon-theme-name=Cosmic
```




### Installing packaged extensions
This repository also packages multiple third-party extensions to the COSMIC desktop (e.g. [cosmic-ext-applet-clipboard-manager](https://github.com/cosmic-utils/clipboard-manager) or [cosmic-ext-tweaks](https://github.com/cosmic-utils/tweaks)). The `nixos-cosmic.overlays.default` overlay as used in the example `flake.nix` enables installing these extensions as you would install any other package (i.e. by adding it to `users.users."yourusername".packages`, `environment.system.packages` or `home.packages` (only if using home manager)).


## Build Requirements
Currently the repository provides no binary cache so all packages need to be built locally.

Generally you will need roughly 16 GiB of RAM and 40 GiB of disk space, but it can be built with less RAM by reducing build parallelism, either via `--cores 1` or `--max-jobs 1` or both, on `nix build`, `nix-build`, and `nixos-rebuild` commands.


## Troubleshooting

### Phantom non-existent display on Nvidia ([cosmic-randr#13](https://github.com/pop-os/cosmic-randr/issues/13))

If while using an Nvidia GPU, `cosmic-settings` and `cosmic-randr list` show an additional display that can not be disabled, try Nvidia's experimental framebuffer device.

Add to your configuration:

```nix
boot.kernelParams = [ "nvidia_drm.fbdev=1" ];
```

### COSMIC Utilities - Clipboard Manager not working

The zwlr\_data\_control\_manager\_v1 protocol needs to be available. Enable it in cosmic-comp via the following configuration:

```nix
environment.sessionVariables.COSMIC_DATA_CONTROL_ENABLED = 1;
```

### COSMIC Utilities - Observatory not working

The monitord service must be enabled to use Observatory.

```nix
systemd.packages = [ pkgs.observatory ];
systemd.services.monitord.wantedBy = [ "multi-user.target" ];
```
