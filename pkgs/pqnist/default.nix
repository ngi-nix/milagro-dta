# When you use pkgs.callPackage, parameters here will be filled with packages from Nixpkgs (if there's a match)
{ lib, stdenv, fetchFromGitHub, cmake, liboqs, amcl, ... } @ args:

stdenv.mkDerivation rec {
  # Specify package name and version
  pname = "pqnist";
  version = "0.0.1";

  # Download source code from GitHub
  repo = fetchFromGitHub ({
    owner = "apache";
    repo = "incubator-milagro-dta";
    # Commit or tag, note that fetchFromGitHub cannot follow a branch!
    rev = "2c2efe10124205fee885fffa8f7dbad83fcc1050";
    # Download git submodules, most packages don't need this
    fetchSubmodules = false;
    # Don't know how to calculate the SHA256 here? Comment it out and build the package
    # Nix will raise an error and show the correct hash
    sha256 = "07qdy0zr7qz4fv1k54hwbl8n4527wx2dm7f0illwygyxzliz3r8r";
  });

  src = "${repo}/libs/crypto/libpqnist";

  buildShareLib = true;
  installPrefix = ".";

  cmakeFlags = [
    "-DCMAKE_INSTALL_PREFIX=${installPrefix}"
    "-DBUILD_SHARED_LIBS=${if buildShareLib then "ON" else "OFF"}"
  ];
  
  # Parallel building, drastically speeds up packaging, enabled by default.
  # You only want to turn this off for one of the rare packages that fails with this.
  enableParallelBuilding = true;
  # If you encounter some weird error when packaging CMake-based software, try enabling this
  # This disables some automatic fixes applied to CMake-based software
  dontFixCmake = true;

    # Add CMake to the building environment, to generate Makefile with it
  nativeBuildInputs = [ cmake ];
  buildInputs = [ liboqs amcl ];
  
  installPhase = ''
    make install
    mkdir -p $out;
    cp -R lib $out;
    cp -R include $out;
    '';

  meta = {
    description = ".";
    homepage = https://github.com/apache/incubator-milagro-dta/tree/develop/libs/crypto/libpqnist;
    license = lib.licenses.asl20;
    # maintainers = [ maintainers.svaes ];
  };
}
