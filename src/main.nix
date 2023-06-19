{ pkgs
, lib
, hypr-contrib
, nix-gaming
, crystal-flake
, nixpkgs-hyprland-autoname-workspaces
, nixpkgs-srb2
, ...
}:

let VARIABLES = import ./variables.nix; in {
  imports = [
    "${VARIABLES.hostHardwareConfiguration}"
    ../overlays
    ../modules
    ../home
    ../containers/rar.nix
    ../containers/wine.nix
    ../containers/dev.nix
    ../containers/gui.nix
    ../containers/srb2.nix
    ../containers/osu.nix
  ];

  # locale
  i18n.defaultLocale = VARIABLES.defaultLocale;
  i18n.supportedLocales = VARIABLES.supportedLocales;

  hardware.opengl.driSupport32Bit = true;

  programs.neovim.enable = true;
  environment.systemPackages = with pkgs; [
    hypr-contrib.packages."${VARIABLES.system}".grimblast
    nix-gaming.packages."${VARIABLES.system}".osu-stable
    crystal-flake.packages.${VARIABLES.system}.crystal
    crystal-flake.packages.${VARIABLES.system}.crystalline
    ameba
    waycorner
    nwg-dock-hyprland
    slade
    typespeed
    osu-lazer-bin
    mullvad-vpn
    pass
    treefmt
    jamesdsp

    logseq
    mullvad-browser
    spek

    gdu
    fdupes
    mediainfo
    ponysay
    lolcat
    cmatrix
    sox
    httpie
    p7zip
    rsync
    unar
    genact
    ffmpeg
    killall
    trashy
    whois
    dwt1-shell-color-scripts
    dig
    yt-dlp
    neofetch
    pywal
    brightnessctl
    zellij
    librespeed-cli
    wiki-tui
    hexyl
    nb
    jpegoptim
    playerctl
    recode
    rmlint
    sd
    shards
    smartmontools
    visidata
    scc
    hwinfo
    stress
    choose
    gum
    hdparm
    imagemagick
    onefetch
    restic
    watchexec
    memento
    mpvpaper
    timg
    ventoy
    wf-recorder
    mdcat
    mdbook
    zola
    file
    tessen
    wtype
    mtr
    cointop

    grim
    slurp
    wl-clipboard
    lnch
    wev
    swww
    kickoff
    greetd.tuigreet
    nixpkgs-hyprland-autoname-workspaces.legacyPackages.${VARIABLES.system}.hyprland-autoname-workspaces
    nixpkgs-srb2.legacyPackages.${VARIABLES.system}.srb2
  ];

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "osu-lazer-bin"
      "vmware-workstation"
    ];

  environment.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    GIT_DISCOVERY_ACROSS_FILESYSTEM = "1";
    FZF_DEFAULT_OPTS = "--height 40% --reverse --border --color=16";
    NODE_OPTIONS = "--max_old_space_size=16384";
  };

  environment.defaultPackages = [ ];
  system.stateVersion = VARIABLES.stateVersion;

  systemd.extraConfig = "DefaultTimeoutStopSec=10s"; # Prevent hanging on shutdown
  services.logind.lidSwitch = "ignore"; # Don't suspend on lid close

  # Don't shutdown when power button is short-pressed
  services.logind.extraConfig = "HandlePowerKey=ignore";

  time.timeZone = "${VARIABLES.timezone}"; # Timezone

  services.resolved.llmnr = "false";

  systemd.services.NetworkManager-wait-online.enable = false;

  # mullvad-vpn
  services.mullvad-vpn = {
    enable = true;
    enableExcludeWrapper = false;
  };

  networking.firewall.allowedTCPPorts = [ 11918 ];

  zramSwap.enable = true; # Swap
}
