{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.wacli-sync;

  # Build-time shell completion, generated from the installed binary.
  completion = shell: pkgs.runCommand "wacli-${shell}-completion" { } ''
    ${lib.getExe cfg.package} completion ${shell} > $out
  '';
in
{
  options.services.wacli-sync = {
    enable = lib.mkEnableOption ''
      the wacli WhatsApp CLI plus the `wacli sync --follow` systemd user
      service (long-running). Enabling this installs `wacli` into
      `home.packages`
    '';

    package = lib.mkPackageOption pkgs "wacli" { };

    extraArgs = lib.mkOption {
      type = with lib.types; listOf str;
      default = [ ];
      description = "Extra args passed to wacli sync (e.g. --refresh-groups). --follow is always added.";
    };

    downloadMedia = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to pass --download-media to wacli sync.";
    };

    enableFishIntegration = lib.mkOption {
      type = lib.types.bool;
      default = config.programs.fish.enable;
      defaultText = lib.literalExpression "config.programs.fish.enable";
      description = "Install fish shell completions for `wacli`.";
    };

    enableBashIntegration = lib.mkOption {
      type = lib.types.bool;
      default = config.programs.bash.enable;
      defaultText = lib.literalExpression "config.programs.bash.enable";
      description = "Install bash shell completions for `wacli`.";
    };

    enableZshIntegration = lib.mkOption {
      type = lib.types.bool;
      default = config.programs.zsh.enable;
      defaultText = lib.literalExpression "config.programs.zsh.enable";
      description = "Install zsh shell completions for `wacli`.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      home.packages = [ cfg.package ];

      systemd.user.services.wacli-sync = {
        Unit.Description = "wacli sync --follow";
        Service = {
          ExecStart = "${lib.getExe cfg.package} sync --follow ${lib.optionalString cfg.downloadMedia "--download-media"} ${lib.escapeShellArgs cfg.extraArgs}";
          Restart = "always";
          RestartSec = "10s";
        };
        Install.WantedBy = [ "default.target" ];
      };
    })

    (lib.mkIf (cfg.enable && cfg.enableFishIntegration) {
      xdg.configFile."fish/completions/wacli.fish".source = completion "fish";
    })

    (lib.mkIf (cfg.enable && cfg.enableBashIntegration) {
      xdg.dataFile."bash-completion/completions/wacli".source = completion "bash";
    })

    # zsh only reads completions from $fpath, which does not include
    # $XDG_CONFIG_HOME by default, so put the dir on it.
    (lib.mkIf (cfg.enable && cfg.enableZshIntegration) {
      xdg.configFile."zsh/completions/_wacli".source = completion "zsh";
      programs.zsh.initContent = lib.mkAfter ''
        fpath+=(${config.xdg.configHome}/zsh/completions)
      '';
    })
  ];
}
