{ stdenv
, lib
, fetchFromGitHub
, bash
, cmake
, cfitsio
, libusb1
, systemd
, pkg-config
, zlib
, boost
, libev
, libnova
, curl
, libjpeg
, gsl
, fftw
, librtlsdr
, libtheora
, gtest
}:

stdenv.mkDerivation rec {
  pname = "indilib";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "indilib";
    repo = "indi";
    rev = "v${version}";
    sha256 = "sha256-mU3CrBePBMNdu/HRkCGQcpKUR3/5UayPLJoB8HqVB/Y=";
  };

  nativeBuildInputs = [
    cmake
  ];
  libusb = libusb1.override { withExamples = true;};

  buildInputs = [
    bash
    curl
    cfitsio
    libev
    libusb
    systemd
    pkg-config
    zlib
    boost
    libnova
    libjpeg
    librtlsdr
    libtheora
    gtest
    gsl
    fftw
  ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DUDEVRULES_INSTALL_DIR=lib/udev/rules.d"
  ];

  postFixup = ''
    for f in $out/lib/udev/rules.d/*.rules
    do
      substituteInPlace $f --replace "/bin/sh" "${bash.out}/bin/sh"
    done
  '';


  meta = with lib; {
    homepage = "https://www.indilib.org/";
    description = "Implementation of the INDI protocol for POSIX operating systems";
    changelog = "https://github.com/indilib/indi/releases/tag/v${version}";
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [ hjones2199 ];
    platforms = platforms.linux;
  };
}
