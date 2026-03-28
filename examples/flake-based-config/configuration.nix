{
  pkgs,
  lib,
  config,
  ...
}:
{

  home-manager.users.user = {
    home.stateVersion = "26.05";
    programs.neovim.enable = true;
    programs.neovim.plugins = [
      pkgs.vimPlugins.nvim-treesitter.withAllGrammars
    ];
  };

  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 1;
  };

  boot.initrd.systemd = {
    enable = true;

    # This is not secure, but it makes diagnosing errors easier.
    emergencyAccess = true;
  };

  hardware.enableRedistributableFirmware = true;

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/root";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-label/SYSTEM_DRV";
      fsType = "vfat";
    };
  };

  boot.tmp.useTmpfs = true;

  # Enable some SysRq keys (80 = sync + process kill)
  # See: https://docs.kernel.org/admin-guide/sysrq.html
  boot.kernel.sysctl."kernel.sysrq" = 80;

  users.defaultUserShell = pkgs.nushell;
  users.users.user = {
    isNormalUser = true;
    # Default password, should be changed using `passwd` after first login.
    password = "nixos";
    extraGroups = [
      "wheel"
      "networkmanager"
      "audio"
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  services = {
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;
    # displayManager.sddm.wayland.enable = true;
    gnome.core-developer-tools.enable = true;
    gnome.games.enable = true;
  };
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    epiphany
  ];
  programs.dconf.profiles.gdm.databases = [
    {
      settings."org/gnome/desktop/interface".scaling-factor = lib.gvariant.mkUint32 2;
    }
  ];

  environment.systemPackages = with pkgs; [
    neovim
    git
    fd
    ripgrep
    tlrc

    ungoogled-chromium

    ccache
    ccacheWrapper
  ];

  networking.networkmanager = {
    enable = true;
    plugins = lib.mkForce [ ];
  };

  hardware.bluetooth.enable = true;

  programs.sway.enable = true;
  programs.geary.enable = true;
  programs.thunderbird.enable = true;

  programs.ccache.enable = true;
  # programs.ccache.packageNames = [ "linux-6.19.0" ];
  nixpkgs.overlays = [
    (self: super: {
      ccacheWrapper = super.ccacheWrapper.override {
        extraConfig = ''
          export CCACHE_COMPRESS=1
          export CCACHE_DIR="${config.programs.ccache.cacheDir}"
          export CCACHE_UMASK=007
          export CCACHE_SLOPPINESS=random_seed
          if [ ! -d "$CCACHE_DIR" ]; then
            echo "====="
            echo "Directory '$CCACHE_DIR' does not exist"
            echo "Please create it with:"
            echo "  sudo mkdir -m0770 '$CCACHE_DIR'"
            echo "  sudo chown root:nixbld '$CCACHE_DIR'"
            echo "====="
            exit 1
          fi
          if [ ! -w "$CCACHE_DIR" ]; then
            echo "====="
            echo "Directory '$CCACHE_DIR' is not accessible for user $(whoami)"
            echo "Please verify its access permissions"
            echo "====="
            exit 1
          fi
        '';
      };
    })
  ];
  nix.settings.extra-sandbox-paths = [ config.programs.ccache.cacheDir ];
}
