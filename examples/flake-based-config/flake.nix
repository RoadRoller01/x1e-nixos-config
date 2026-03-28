{
  inputs = {
    # Unstable nixpkgs, required for now.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # This repository.
    x1e-nixos-config.url = "github:roadroller01/x1e-nixos-config";
    x1e-nixos-config.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs =
    {
      self,
      nixpkgs,
      x1e-nixos-config,
      home-manager,
    }:
    {
      # Change "system" to your chosen hostname here:
      nixosConfigurations.system = nixpkgs.lib.nixosSystem {
        modules = [
          x1e-nixos-config.nixosModules.x1e
          {
            networking.hostName = "system";
            hardware.asus-vivobook-s15.enable = true;

            nixpkgs.hostPlatform.system = "aarch64-linux";

            # Uncomment this to allow unfree packages.
            nixpkgs.config.allowUnfree = true;

            nix = {
              channel.enable = false;
              settings.experimental-features = [
                "nix-command"
                "flakes"
              ];
            };
          }
          home-manager.nixosModules.home-manager
          ./configuration.nix
        ];
      };
    };
}
