{ rustPlatform, fetchFromGitHub, pkg-config, openssl, postgresql }:

rustPlatform.buildRustPackage {
  pname = "berechenbarkeit";
  version = "0-unstable-2024-06-14";

  src = fetchFromGitHub {
    owner = "entropia";
    repo = "berechenbarkeit";
    rev = "73768f7690f0c91daed1560e3f8734d66218fba8";
    hash = "sha256-mDx1sEEFoL90TUyIlpbIL+3WBaIggOrIQl+++YZQ7yI=";
  };

  cargoHash = "sha256-ErfSeACBCw7t42joTljGxk201UrGxF6YO6Hpvj2vS0o=";

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
