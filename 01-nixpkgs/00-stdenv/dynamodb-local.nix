# Lets write our derivation as a function with the things that it needs from nixpkgs
{ stdenv, fetchurl, makeWrapper, jre }:

# nixpkgs.stdenv.mkDerivation is better than the builtins.derivation.
# pretty much always use it! :)
stdenv.mkDerivation rec {
  name = "dynamodb-local-1.0.0";

  # Download the dynamodb-local jar from amazon.
  # This puts the tarball in the nix store!
  dynamoTarball = fetchurl {
    url = https://s3-ap-southeast-1.amazonaws.com/dynamodb-local-singapore/dynamodb_local_latest.tar.gz;
    sha256 = "d79732d7cd6e4b66fbf4bb7a7fc06cb75abbbe1bbbfb3d677a24815a1465a0b2";
  };

  # makeWrapper makes a little shell script with everything pointing to the right
  # places in the store.
  nativeBuildInputs = [ makeWrapper ];

  # instead of a single builder, we describe phases like with traditional
  # package formats.
  unpackPhase = ''
    source $stdenv/setup
    mkdir -p $out $out/dynamo
    tar xf $dynamoTarball -C $out/dynamo
  '';

  installPhase = ''
    mkdir $out/bin
    makeWrapper ${jre}/bin/java $out/bin/dynamodb-local --add-flags "-jar $out/dynamo/DynamoDBLocal.jar"
  '';

}
# See ./default.nix for getting nixpkgs into this function.
