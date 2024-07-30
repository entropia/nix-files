{ rustPlatform, fetchFromGitHub, pkg-config, openssl, postgresql }:

rustPlatform.buildRustPackage {
  pname = "berechenbarkeit";
  version = "0-unstable-2024-07-06";

  src = fetchFromGitHub {
    owner = "entropia";
    repo = "berechenbarkeit";
    rev = "694e70457d68959dbd7329aa8031e327805eff44";
    hash = "sha256-nIiFf30Dpo9aZ01j93bzZ0ONeh202ZqWTYrTfZyJ0LA=";
  };

  cargoHash = "sha256-6xFb09rVVZNVgHhbTM5mfFKm6aiOdLCLr2bBKSx1t58=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    openssl.dev
    postgresql.lib
  ];

  BERECHENBARKEIT_STATIC_BASE_PATH = placeholder "assets";

  postInstall = ''
    mkdir $assets
    cp -R $src/src/assets/* $assets
  '';

  outputs = [ "out" "assets" ];
}
