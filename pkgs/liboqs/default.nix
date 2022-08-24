# When you use pkgs.callPackage, parameters here will be filled with packages from Nixpkgs (if there's a match)
{ lib, stdenv, fetchFromGitHub, openssl, autoreconfHook, ... } @ args:

stdenv.mkDerivation rec {
  # Specify package name and version
  pname = "liboqs";
  version = "0.7.1";

  # Download source code from GitHub
  src = fetchFromGitHub ({
    owner = "open-quantum-safe";
    repo = "liboqs";
    # Commit or tag, note that fetchFromGitHub cannot follow a branch!
    rev = "0.7.1";
    # Download git submodules, most packages don't need this
    fetchSubmodules = false;
    # Don't know how to calculate the SHA256 here? Comment it out and build the package
    # Nix will raise an error and show the correct hash
    sha256 = "15x5skn4zz8z3mxph1ki5rl7sk44a4x8d19x2dykc56n7wgd62kk";
  });

  # Parallel building, drastically speeds up packaging, enabled by default.
  # You only want to turn this off for one of the rare packages that fails with this.
  enableParallelBuilding = true;
  # If you encounter some weird error when packaging CMake-based software, try enabling this
  # This disables some automatic fixes applied to CMake-based software
  dontFixCmake = true;

  # --- Autotools ---
  nativeBuildInputs = [ autoreconfHook openssl ];
  
  autoreconfPhase = ''
  autoreconf -i
  '';

  buildPhase = ''
  mkdir -p /tmp/liboqs
  ./configure --prefix=/tmp/liboqs --disable-shared --disable-aes-ni --disable-kem-bike --disable-kem-frodokem --disable-kem-newhope --disable-kem-ntru --disable-kem-kyber --disable-sig-qtesla --disable-sig-dilithium --without-openssl
  make clean
  make -j
  '';

  installPhase = ''
  make install
  mkdir -p $out;
  cp -r /tmp/liboqs/include $out;
  cp -r /tmp/liboqs/lib $out;
  '';
  # --- ---

  # --- CMake ---
  # nativeBuildInputs = [ cmake ninja openssl ];
  # buildShareLib = false;
  # debug = false;
  # buildOnlyLib = false;
  # distBuild = false;
  # useOpenSSL = false;
  # generic = false;
  # installPrefix = ".";

  # cmakeFlags = [
  #   "-DCMAKE_INSTALL_PREFIX=${installPrefix}"
  #   "-DBUILD_SHARED_LIBS=${if buildShareLib then "ON" else "OFF"}"
  #   "-DCMAKE_BUILD_TYPE=${if debug then "Debug" else "Release"}"
  #   "-DOQS_BUILD_ONLY_LIB=${if buildOnlyLib then "ON" else "OFF"}"
  #   "-DOQS_DIST_BUILD=${if distBuild then "ON" else "OFF"}"
  #   "-DOQS_USE_OPENSSL=${if useOpenSSL then "ON" else "OFF"}"
  #   "-DOQS_OPT_TARGET=${if generic then "generic" else "auto"}"
  #   "-DOQS_ENABLE_KEM_BIKE=OFF"
  #   "-DOQS_ENABLE_KEM_FRODOKEM=OFF"
  #   "-DOQS_ENABLE_KEM_NEWHOPE=OFF"
  #   "-DOQS_ENABLE_KEM_KYBER=OFF"
  #   "-DOQS_ENABLE_SIG_QTESLA=OFF"
  #   "-DOQS_ENABLE_KEM_SIKE=ON"
  #   "-GNinja"
  # ];

  # installPhase = ''
  # ninja install
  # mkdir -p $out;
  # mkdir -p $out/lib;
  # cp -r include $out;
  # cp -r lib $out;
  # '';

  meta = {
    description = "liboqs is an open source C library for quantum-safe cryptographic algorithms.";
    homepage = https://github.com/open-quantum-safe/liboqs;
    license = lib.licenses.mit;
    # maintainers = [ maintainers.svaes ];
  };
}
