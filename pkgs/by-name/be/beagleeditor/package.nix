{ lib, stdenv, fetchFromGitHub, python3, pyinstaller, pip, makeWrapper }:

stdenv.mkDerivation rec {
  pname = "beagleeditor";
  version = "2024.4.0.1";

  src = fetchFromGitHub {
    owner = "beaglesoftware";
    repo = "editor";
    rev = "refs/heads/main";
    sha256 = "sha256-placeholder"; # Replace this with the actual hash from nix-prefetch-url
  };

  nativeBuildInputs = [
    pyinstaller
    makeWrapper
  ];

  buildInputs = [
    python3
  ];

  buildPhase = ''
    # Extract the tarball to a temporary directory
    mkdir -p /tmp/beagleeditor-nix-setup
    cp -r . /tmp/beagleeditor-nix-setup

    # Download requirements.txt and install dependencies with pip
    curl -o requirements.txt https://raw.githubusercontent.com/beaglesoftware/editor/refs/heads/main/requirements.txt
    ${python3.executable} -m pip install --prefix=$out --upgrade pip
    ${python3.executable} -m pip install --prefix=$out -r requirements.txt

    # Run PyInstaller to build the binary
    cd /tmp/beagleeditor-nix-setup
    pyinstaller \
      --add-data "syntax.py:." \
      --add-data "autocomplete.py:." \
      --add-data "splash.py:." \
      --add-data "compile_c.sh:." \
      --add-data "compile_cpp.sh:." \
      --add-data "compile_c_cpp.bat:." \
      --add-data "compile_cs.bat:." \
      --add-data "splash.png:." \
      -i ~/Downloads/Frame\\ 1-3.png \
      --windowed \
      --onefile BeagleEditor.py
  '';

  installPhase = ''
    # Move the generated binary to the output directory
    mkdir -p $out/bin/beagleeditor
    mv dist/BeagleEditor $out/bin/beagleeditor

    # Create a wrapper for better usage
    makeWrapper $out/bin/beagleeditor $out/bin/beagleeditor-wrapper
  '';

  meta = with lib; {
    description = "BeagleEditor: A Python-based editor with custom tools";
    homepage = "https://github.com/beaglesoftware/editor";
    license = licenses.mit;
    maintainers = with maintainers; [ your-nixpkgs-handle ];
  };
}
