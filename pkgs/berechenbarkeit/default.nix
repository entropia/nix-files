{ lib, rustPlatform, fetchFromGitHub, pkg-config, openssl, postgresql }:

rustPlatform.buildRustPackage {
  pname = "berechenbarkeit";
  version = "0-unstable-2024-05-12";

  src = fetchFromGitHub {
    owner = "entropia";
    repo = "berechenbarkeit";
    rev = "703ecb85d66a1798c33feebd1d906a18bf1727e4";
    hash = "sha256-DtXlaNvWIhDrBMVWOmV1eTskJmqYf8wYLdEfxdbD3oc=";
  };

  cargoHash = "sha256-Zisj2fpebz4CRwpsg/H+8H/s1Q395lOiVKg9fcZVTtw=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    openssl.dev
    postgresql.lib
  ];

  preBuild = ''
    export BERECHENBARKEIT_STATIC_BASE_PATH=$assets
  '';

  postInstall = ''
    mkdir $assets
    cp -R $src/src/assets/* $assets
  '';

  outputs = [ "out" "assets" ];
}
