{ lib, rustPlatform, fetchFromGitHub, pkg-config, openssl, postgresql }:

rustPlatform.buildRustPackage {
  pname = "berechenbarkeit";
  version = "0-unstable-2024-05-16";

  src = fetchFromGitHub {
    owner = "entropia";
    repo = "berechenbarkeit";
    rev = "b482c7398fb68f946e4056bb5c4c183d0dcabce7";
    hash = "sha256-atFIHF0NQqQG+VLdf8ox1vpg8/8RI6ii8UH7M9Rfwg0=";
  };

  cargoHash = "sha256-Z+APSmwFfqQAbo4cUDtdRQhLs0IuwvyX5jUaIOgcScA=";

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
