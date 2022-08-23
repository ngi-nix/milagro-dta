# When you use pkgs.callPackage, parameters here will be filled with packages from Nixpkgs (if there's a match)
{ lib, stdenv, fetchFromGitHub, cmake, doxygen, ... } @ args:

stdenv.mkDerivation rec {
  # Specify package name and version
  pname = "amcl";
  version = "0.0.1";

  # Download source code from GitHub
  src = fetchFromGitHub ({
    owner = "apache";
    repo = "incubator-milagro-crypto-c";
    # Commit or tag, note that fetchFromGitHub cannot follow a branch!
    rev = "7e8df018b9ce0035abdd7589dbca676821594bb3";
    # Download git submodules, most packages don't need this
    fetchSubmodules = false;
    # Don't know how to calculate the SHA256 here? Comment it out and build the package
    # Nix will raise an error and show the correct hash
    sha256 = "0z7r8h6r7fda5jh656wfq9nm493fnw93ynfvwwqnz2wpqbs44cgc";
  });

  usePython = false;
  buildBLS = true;
  buildWCC = false;
  buildMPIN = false;
  buildX509 = false;
  buildShareLib = true;
  curves = "BLS381,SECP256K1";
  chunk = "64";
  rsa = "";
  cFlags = "-fPIC";
  buildType = "Release";
  # installPrefix = "$out";
  installPrefix = ".";

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=${buildType}"
    "-DAMCL_CHUNK=${chunk}"
    "-DBUILD_SHARED_LIBS=${if buildShareLib then "ON" else "OFF"}"
    "-DBUILD_PYTHON=${if usePython then "ON" else "OFF"}"
    "-DBUILD_BLS=${if buildBLS then "ON" else "OFF"}"
    "-DBUILD_WCC=${if buildWCC then "ON" else "OFF"}"
    "-DBUILD_MPIN=${if buildMPIN then "ON" else "OFF"}"
    "-DBUILD_X509=${if buildX509 then "ON" else "OFF"}"
    "-DCMAKE_INSTALL_PREFIX=${installPrefix}"
    "-DAMCL_CURVE=${curves}"
    "-DAMCL_RSA=${rsa}"
    "-DCMAKE_C_FLAGS=${cFlags}"
  ];
  
  # Parallel building, drastically speeds up packaging, enabled by default.
  # You only want to turn this off for one of the rare packages that fails with this.
  enableParallelBuilding = true;
  # If you encounter some weird error when packaging CMake-based software, try enabling this
  # This disables some automatic fixes applied to CMake-based software
  dontFixCmake = true;

  # Add CMake to the building environment, to generate Makefile with it
  nativeBuildInputs = [ cmake doxygen ];

  # mkdir build
  # cd build
  # cmake -D CMAKE_INSTALL_PREFIX=/usr/local -D BUILD_SHARED_LIBS=ON ..
  # make
  # export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
  # make test
  # sudo make install

  installPhase = ''
    make install
    mkdir -p $out;
    # cp -R share $out;
    cp -R lib $out;
    cp -R include $out;
    cp -R bin $out;
    '';

  meta = {
    description = ".";
    homepage = https://github.com/apache/incubator-milagro-crypto-c;
    license = lib.licenses.asl20;
    # maintainers = [ maintainers.svaes ];
  };
}
