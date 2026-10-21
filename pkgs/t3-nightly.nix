# Version pins for the nightly build. `flake.nix` feeds this attrset to
# `callPackage ./t3.nix`, so `.override { enableCodex = ...; }` still targets
# the shared wrapper's arguments.
{
  pname = "t3-nightly";
  t3Version = "0.1.2-nightly.20261021.3457";
  t3Hash = "sha256-YTvLhbX6eeaAjROu7/NbBVB9SgiAMjif2DKAnIGNTxw=";
}
