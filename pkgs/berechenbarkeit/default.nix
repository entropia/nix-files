{ lib, rustPlatform, fetchFromGitHub, pkg-config, openssl, postgresql }:

rustPlatform.buildRustPackage {
  pname = "berechenbarkeit";
  version = "0-unstable-2024-05-22";

  src = fetchFromGitHub {
    owner = "entropia";
    repo = "berechenbarkeit";
    rev = "e642b3b06150ba61f516f75085beee97fc57ddb5";
    hash = "sha256-kRT5vOgh8GchaIAal7ECnOAg7kaT1maQ/iueABpbiQg=";
  };

  cargoHash = "sha256-jIL614Rafp65E0FyFKBl7eXXfO72mVj+8rp5BU8aezw=";

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
