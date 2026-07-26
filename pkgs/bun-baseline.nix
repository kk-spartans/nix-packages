final: prev: prev.lib.optionalAttrs prev.stdenv.hostPlatform.isx86_64 {
  bun = prev.bun.overrideAttrs (finalAttrs: previousAttrs: {
    src = prev.fetchurl {
      url = "https://github.com/oven-sh/bun/releases/download/bun-v${finalAttrs.version}/bun-linux-x64-baseline.zip";
      hash = "sha256-nYokKSpwaAkCBdqsCloiP19pc29Sh+N7+I07QDHtx1A=";
    };

    sourceRoot = "bun-linux-x64-baseline";

    passthru = previousAttrs.passthru // {
      baseline = true;
    };
  });
}
