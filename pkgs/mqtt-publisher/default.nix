{ python3Packages }:
python3Packages.buildPythonApplication {
  pname = "mqtt-publisher";
  version = "1.0.0";
  pyproject = true;

  src = ./src;

  nativeBuildInputs = with python3Packages; [
    setuptools
    wheel
  ];

  propagatedBuildInputs = with python3Packages; [
    paho-mqtt
  ];
}
