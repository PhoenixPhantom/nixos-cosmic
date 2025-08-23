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
