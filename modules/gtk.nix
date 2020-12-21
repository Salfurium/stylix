{ pkgs, config, ... }:

let
  materia = with pkgs; stdenvNoCC.mkDerivation {
    name = "stylix-materia";

    src = fetchFromGitHub {
      owner = "nana-4";
      repo = "materia-theme";
      rev = "c63ca3285c4b5fcd652d1f054745251c60d4c32e";
      sha256 = "Sje1j/k+g0MXP1wQi+KSVXIt1LQPeJ5KYJwfyxgmxPw=";
    };
    nativeBuildInputs = [ bc inkscape optipng sassc ];

    theme = with config.lib.stylix.colors; lib.generators.toKeyValue {} {
      # Normal
      BG = base00-hex;
      FG = base05-hex;
      # Accent
      ACCENT_BG = base0F-hex;
      ACCENT_FG = base00-hex;
      # Buttons
      BTN_BG = base02-hex;
      BTN_FG = base06-hex;
      # Header bar
      HDR_BG = base00-hex;
      HDR_FG = base05-hex;
      # Header buttons
      HDR_BTN_BG = base01-hex;
      HDR_BTN_FG = base05-hex;
      # Materia
      MATERIA_SURFACE = base01-hex;
      MATERIA_VIEW = base01-hex;
      # Menu
      MENU_BG = base01-hex;
      MENU_FG = base05-hex;
      # Selection
      SEL_BG = base02-hex;
      SEL_FG = base05-hex;
      # Text
      TXT_BG = base00-hex;
      TXT_FG = base05-hex;
      # Window manager border
      WM_BORDER_FOCUS = base0A-hex;
      WM_BORDER_UNFOCUS = base03-hex;

      MATERIA_STYLE_COMPACT = "True";
      UNITY_DEFAULT_LAUNCHER_STYLE = "False";
    };
    passAsFile = [ "theme" ];

    FONTCONFIG_FILE = makeFontsConf {
      fontDirectories = [ config.stylix.fonts.sansSerif.package ];
    };

    postPatch = "patchShebangs .";
    dontConfigure = true;
    buildPhase = ''
      export HOME="$NIX_BUILD_ROOT"
      ./change_color.sh -t $out/share/themes -o stylix $themePath
    '';
  };

  theme = {
    package = materia;
    name = "stylix";
  };

in {
  # Required for Home Manager's GTK settings to work
  services.dbus.packages = [ pkgs.gnome3.dconf ];

  stylix.homeModule = {
    gtk = {
      enable = true;
      inherit theme;
      font = config.stylix.fonts.sansSerif;
    };
  };

  services.xserver.displayManager.lightdm.greeters.gtk.theme = theme;
}
