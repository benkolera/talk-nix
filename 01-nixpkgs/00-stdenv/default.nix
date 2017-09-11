let
  # <nixpkgs> is a special path that we'll get to soon
  nixpkgs = import (<nixpkgs>) {};
in

# We could import our function and call it like this:
#import ./dynamodb-local.nix {
#  inherit (nixpkgs) stdenv fetchurl makeWrapper jre;
#}

# Or we could use this handy thing from stdenv which does the same thing:
nixpkgs.pkgs.callPackage ./dynamodb-local.nix {}

