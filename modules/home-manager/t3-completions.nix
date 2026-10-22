# Build-time shell completion generation for the `t3` CLI.
#
# Upstream ships t3 as a Node SEA binary whose ELF interpreter is
# `/lib64/ld-linux-x86-64.so.2`. On NixOS that path is provided by nix-ld, but
# Nix build sandboxes only expose /nix/store, so running the stock binary there
# dies with exit 255 before printing anything.
#
# Patch a copy of the binary to point at the nix glibc loader instead. patchelf
# preserves the embedded SEA blob (the `.note.node.sea` section), so the binary
# still finds its app payload. `node_modules` is symlinked next to it because
# t3 resolves its bundled harness SDKs relative to the executable.
{ pkgs }:
t3Package: shell:
pkgs.runCommand "t3-${shell}-completions"
  {
    nativeBuildInputs = [
      pkgs.patchelf
      pkgs.glibc
    ];
  }
  ''
    app="$PWD/app"
    mkdir "$app"
    cp ${t3Package.unwrapped}/libexec/t3/t3 "$app/t3"
    chmod +w "$app/t3"
    ln -s ${t3Package.unwrapped}/libexec/t3/node_modules "$app/node_modules"
    patchelf --set-interpreter ${pkgs.glibc}/lib64/ld-linux-x86-64.so.2 "$app/t3"
    LD_LIBRARY_PATH=${
      pkgs.lib.makeLibraryPath [
        pkgs.stdenv.cc.cc.lib
        pkgs.glibc
      ]
    } "$app/t3" --completions ${shell} > "$out"
  ''
