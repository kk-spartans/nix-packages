{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.cli-completions;

  # Only tools with a real completion generator upstream. Each `command`
  # prints a fish completion script to stdout.
  defaultTools = {
    spogo = {
      package = pkgs.spogo;
      command = "completion fish";
    };
    wacli = {
      package = pkgs.wacli;
      command = "completion fish";
    };
    gog = {
      package = pkgs.gogcli;
      command = "completion fish";
    };
    t3 = {
      package = pkgs.t3;
      command = "--completions fish";
    };
    hf = {
      package = pkgs.hf;
      command = "--show-completion fish";
    };
  };
in
{
  options.programs.cli-completions = {
    enable = lib.mkEnableOption "fish completions for the CLI packages in this flake";

    tools = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            package = lib.mkOption {
              type = lib.types.package;
              description = "Package that provides the binary.";
            };
            binary = lib.mkOption {
              type = lib.types.str;
              default = "";
              description = "Binary name inside the package (defaults to the attribute name).";
            };
            command = lib.mkOption {
              type = lib.types.str;
              description = "Arguments that print a fish completion script.";
            };
          };
        }
      );
      default = defaultTools;
      description = "Tools to generate fish completions for.";
    };
  };

  config = lib.mkIf cfg.enable {
    xdg.configFile = lib.mapAttrs' (
      name: tool:
      lib.nameValuePair "fish/completions/${name}.fish" {
        source = pkgs.runCommandLocal "${name}-fish-completion" { } ''
          ${tool.package}/bin/${if tool.binary != "" then tool.binary else name} ${tool.command} > $out
        '';
      }
    ) cfg.tools;
  };
}
