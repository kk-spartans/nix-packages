{ pkgs }:
pkgs.rustPlatform.buildRustPackage rec {
  pname = "agent-browser";
  version = "0.40.0";

  src = pkgs.fetchurl {
    url = "https://github.com/vercel-labs/agent-browser/archive/v${version}.tar.gz";
    hash = "sha256-8opPC01dbv9JJaK0QtXZMMlu1pMvKD8BTdEg3BvBdO8=";
  };

  buildAndTestSubdir = "cli";
  cargoRoot = "cli";

  # Trust the system CA store for wss:// CDP endpoints. Upstream dials the
  # DevTools WebSocket with the compiled-in Mozilla roots only, so a private
  # CA (e.g. the spartans gateway) is rejected with UnknownIssuer. This is
  # what lets agent-browser drive a remote Chrome through https://... with
  # plain TLS and no port forwarding.
  patches = [ ./agent-browser-system-ca.patch ];

  doCheck = false;

  cargoHash = "sha256-4ZuXy4hEg5oXhNt/pox28h/+Yxms63ntSPf2+Fy4kZM=";

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
