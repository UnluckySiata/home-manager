{ config, pkgs, ... }:

let
  rosepine-fish = pkgs.fetchFromGitHub {
      owner = "rose-pine";
      repo = "fish";
      rev = "38aab5b";
      sha256 = "0bwsq9pz1nlhbr3kyz677prgyk973sgis72xamm1737zqa98c8bd";
  };
in 
{
  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  home.username = "ms";
  home.homeDirectory = "/home/ms";

  home.stateVersion = "23.11";

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    # neovim
    neofetch
    ripgrep
    fd
    fzf
    htop
    eza
    tmux
    tmux-sessionizer

    nodejs_21
    lua-language-server
    llvmPackages_17.clang-unwrapped

    (nerdfonts.override { fonts = [ "FiraCode" "Hermit" ]; })
  ];

  # home.file = {
  # };

  # home.sessionPath = [
  #   "$HOME/.local/bin"
  #   "$HOME/.cargo/bin"
  # ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VCPKG_ROOT = "$HOME/source/vcpkg";
  };

  programs.home-manager.enable = true;
  targets.genericLinux.enable = true;

  home.shellAliases = {
    v = "nvim";
    nf = "neofetch";
    l = "eza -aBlg";
  };

  programs.bash = {
    enable = true;
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -x PATH $HOME/.local/bin $HOME/.cargo/bin $PATH
      fish_vi_key_bindings
      fish_config theme choose "rosepine"

      bind -M insert \cn nextd-or-forward-word
      bind -M insert \cN nextd-or-forward-word
      bind -M insert \cy accept-autosuggestion
    '';
  };

  # bind fish theme to correct dir
  xdg.configFile."fish/themes/rosepine.theme".source = "${rosepine-fish}/themes/Rosé Pine.theme";

  programs.tmux = {
    enable = true;
    mouse = true;
    customPaneNavigationAndResize = true;

    baseIndex = 1;

    prefix = "C-a";
    keyMode = "vi";
    shell = "${pkgs.fish}/bin/fish";

    plugins = with pkgs; [
      tmuxPlugins.catppuccin
    ];

    extraConfig = ''
      set-window-option -g automatic-rename on
      set-option -g set-titles on

      bind-key v split-window -h
      bind-key b split-window -v

      bind-key C-f run-shell "tmux neww tms"
    '';
  };

  programs.alacritty = {
    enable = false;
    settings = {
      window = {
        dimensions = {
          columns = 90;
          lines = 30;
        };
        padding = {
          x = 5;
          y = 5;
        };
        opacity = 0.5;
      };

      shell = {
        program = "${pkgs.tmux}/bin/tmux";
        args = [
          "new-session"
          "-A"
          "-D"
          "-s"
          "main"
        ];
      };
    };
  };
}
