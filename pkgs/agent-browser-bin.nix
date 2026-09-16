{ pkgs }:
pkgs.rustPlatform.buildRustPackage rec {
  pname = "agent-browser";
  version = "0.36.0";

  src = pkgs.fetchurl {
    url = "https://github.com/vercel-labs/agent-browser/archive/v${version}.tar.gz";
    hash = "sha256-1BQBWFLeAWXEalrb8EFZLd8y7nkNdJBh+u9stDwdPFk=";
  };

  buildAndTestSubdir = "cli";
  cargoRoot = "cli";

  doCheck = false;

  cargoHash = "sha256-6xphNOYi+tJvFlprY8DCVw1XzVFapqFQfeIy0w2pyCs=";

  nativeBuildInputs = with pkgs; [ makeWrapper ];

  # Upstream serves `skills get/list` from `skills/` + `skill-data/` next to
  # the binary (npm layout). The bare cargo build installs no such dirs, so
  # `skills get core` fails with "Skills directory not found". Bundle both
  # into one dir (env override only searches a single dir) and shim
  # AGENT_BROWSER_SKILLS_DIR onto the process. --set-default keeps an
  # explicit env override working.
  postInstall = ''
    mkdir -p $out/share/agent-browser/skills
    tar --strip-components=2 -xzf "$src" -C $out/share/agent-browser/skills \
      "agent-browser-${version}/skill-data"
    tar --strip-components=2 -xzf "$src" -C $out/share/agent-browser/skills \
      "agent-browser-${version}/skills"
    wrapProgram $out/bin/agent-browser \
      --set-default AGENT_BROWSER_SKILLS_DIR "$out/share/agent-browser/skills"
  '';
}
