let 
  makeHello = message : derivation {
    name    = "00.01-helloworld-0.1.0.0";
    builder = ./builder.sh;
    system  = "x86_64-linux";
    inherit message;          #inherit message so it is available in builder.sh
  };
in { # nix-build will build everything if we return a record
  helloBfpg  = makeHello "bfpg";
  helloBen   = makeHello "ben";
}

