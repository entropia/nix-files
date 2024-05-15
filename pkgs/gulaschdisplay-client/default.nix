{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "gulaschdisplay-client";
  version = "unstable-2024-05-07";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "entropia";
    repo = "gulaschdisplay-client";
    rev = "39d560324922e19885e9f985ecea38b7673a6cec";
    hash = "sha256-NtYrSoohLZaKD64Womjr1VAdz37EgkETcBF6st5SLSU=";
  };

  nativeBuildInputs = [
    python3.pkgs.poetry-core
  ];

  propagatedBuildInputs = with python3.pkgs; [
    aiohttp
    getmac
    i3ipc
    requests
  ];

  pythonImportsCheck = [ "gulaschdisplay_client" ];
}
