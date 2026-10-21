{
  lib,
  callPackage,
  symlinkJoin,
  makeBinaryWrapper,
  pname ? "t3",
  enableAzureDevOps ? false,
  azure-cli,
  azure-cli-extensions,
  enableBitbucket ? false,
  bitbucket-cli,
  enableClaude ? false,
  claude-code,
  enableCodex ? false,
  codex,
  enableCursor ? false,
  code-cursor,
  enableCursorCli ? false,
  cursor-cli,
  enableGitHub ? true,
  gh,
  enableGit ? true,
  git,
  enableGitLab ? false,
  glab,
  enableJujutsu ? false,
  jujutsu,
  enableOpencode ? false,
  opencode,
  enableResourceMonitor ? false,
  t3-unwrapped ? callPackage ./t3-unwrapped.nix { },
}:

let
  runtimePackages =
    lib.optionals enableAzureDevOps [
      (azure-cli.withExtensions [ azure-cli-extensions.azure-devops ])
    ]
    ++ lib.optionals enableBitbucket [ bitbucket-cli ]
    ++ lib.optionals enableClaude [ claude-code ]
    ++ lib.optionals enableCodex [ codex ]
    ++ lib.optionals enableCursor [ code-cursor ]
    ++ lib.optionals enableCursorCli [ cursor-cli ]
    ++ lib.optionals enableGitHub [ gh ]
    ++ lib.optionals enableGit [ git ]
    ++ lib.optionals enableGitLab [ glab ]
    ++ lib.optionals enableJujutsu [ jujutsu ]
    ++ lib.optionals enableOpencode [ opencode ];

  wrapperArgs = lib.optionals (runtimePackages != [ ]) [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath runtimePackages)
  ];

in
symlinkJoin {
  inherit pname;
  inherit (t3-unwrapped) version;
  __structuredAttrs = true;
  strictDeps = true;

  paths = [ t3-unwrapped ];

  nativeBuildInputs = [ makeBinaryWrapper ];

  postBuild = lib.optionalString (wrapperArgs != [ ]) ''
    for program in "$out/bin"/*; do
      wrapProgram "$program" ${lib.escapeShellArgs wrapperArgs}
    done
  '';

  passthru = {
    unwrapped = t3-unwrapped;
  };

  meta = {
    description = "T3 Code headless server (${pname}) with harness wrappers";
    homepage = "https://t3.codes";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "t3";
    platforms = t3-unwrapped.meta.platforms;
  };
}
