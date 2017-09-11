# Derivation is a built in function to the nix language
derivation {
  name    = "00.00-helloworld-0.1.0.0"; # Every derivation has a name
  flat    = true;                       # We're just outputting a single text file
  builder = ./builder.sh;               # The shell script to make this derivation
  system  = "x86_64-linux";             # The system we are building for
}
# Further doco on derivation and mkDerivation here:
# https://nixos.org/nix/manual/#ssec-derivation
