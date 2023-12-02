{ lib
, buildGoModule
, buildNpmPackage
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "wg-access-server";
  version = "0.10.1";

  src = fetchFromGitHub {
    owner = "freifunkMUC";
    repo = "wg-access-server";
    rev = "v${version}";
    hash = "sha256-m7Zf8LAkVgFHBNgCr8TZTtp28LH2tFRLhdpulp//pbM=";
  };

  vendorHash = "sha256-DWnLXQaGUt1hsbNHBR+ZpYTgvBMBTEZy3yQB3fWgnp4=";

  CGO_ENABLED = 1;

  ldflags = [ "-s" "-w" ];
  
  doCheck = false;
    
  ui = buildNpmPackage {
    inherit version src;
    pname = "wg-access-server-ui";

    npmDepsHash = "sha256-NDjADRnJHOA2gbj7Ah5BQkFZPbqx2vZjarQeO4LBITI=";

    prePatch = ''
      cd website/
    '';

    installPhase = ''
      mkdir -p $out
      mv build/ $out/site
    '';
  };

  preBuild = ''
    mkdir -p $out/
    cp -r ${ui}/site/ $out/
  '';


  meta = with lib; {
    description = "An all-in-one WireGuard VPN solution with a web ui for connecting devices";
    homepage = "https://github.com/freifunkMUC/wg-access-server";
    license = licenses.mit;
    maintainers = with maintainers; [ xanderio ];
    mainProgram = "wg-access-server";
  };
}
