{ stdenv
, lib
, bash
, cmake
, coreutils
, cfitsio
, libusb1
, systemd
, zlib
, boost
, pkg-config
, limesuite
, libnova
, curl
, libjpeg
, gsl
, fftw
, indilib
, libgphoto2
, libraw
, libftdi1
, libdc1394
, gpsd
, ffmpeg
, version
, src
, withFirmware ? false
, firmware ? null
}:

stdenv.mkDerivation rec {
  pname = "indi-3rdparty";

  inherit version src;

  libusb-fxload = libusb1.override { withExamples = true;};

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    indilib
    libnova
    bash
    curl
    cfitsio
    coreutils
    libusb-fxload
    systemd
    zlib
    boost
    pkg-config
    gsl
    gpsd
    libjpeg
    libgphoto2
    libraw
    libftdi1
    libdc1394
    limesuite
    ffmpeg
    fftw
  ] ++ lib.optionals withFirmware [
    firmware
  ];

  postPatch = ''
    for f in indi-qsi/CMakeLists.txt \
             indi-dsi/CMakeLists.txt \
             indi-armadillo-platypus/CMakeLists.txt \
             indi-orion-ssg3/CMakeLists.txt
    do
      substituteInPlace $f \
        --replace "/lib/udev/rules.d" "lib/udev/rules.d" \
        --replace "/etc/udev/rules.d" "lib/udev/rules.d" \
        --replace "/lib/firmware" "lib/firmware"
    done

    sed '1i#include <ctime>' -i indi-duino/libfirmata/src/firmata.cpp # gcc12
  '';

  cmakeFlags = [
    "-DINDI_DATA_DIR=share/indi"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DUDEVRULES_INSTALL_DIR=lib/udev/rules.d"
    "-DRULES_INSTALL_DIR=lib/udev/rules.d"
    # Pentax, Atik, and SX cmakelists are currently broken
    "-DWITH_PENTAX=off"
    "-DWITH_ATIK=off"
    "-DWITH_SX=off"
  ] ++ lib.optionals (!withFirmware) [
    "-DWITH_APOGEE=off"
    "-DWITH_DSI=off"
    "-DWITH_QHY=off"
    "-DWITH_ARMADILLO=off"
    "-DWITH_FISHCAMP=off"
    "-DWITH_SBIG=off"
  ];

  postFixup = ''
    for f in $out/lib/udev/rules.d/*.rules
    do
      substituteInPlace $f --replace "/sbin/fxload" "${libusb.out}/sbin/fxload"
      substituteInPlace $f --replace "/lib/firmware/" "$out/lib/firmware/"
      substituteInPlace $f --replace "/bin/sleep" "${coreutils.out}/bin/sleep"
      substituteInPlace $f --replace "/bin/cat" "${coreutils.out}/bin/cat"
      substituteInPlace $f --replace "/bin/echo" "${coreutils.out}/bin/echo"
      substituteInPlace $f --replace "/bin/sh" "${bash.out}/bin/sh"
    done
  '';


  meta = with lib; {
    homepage = "https://www.indilib.org/";
    description = "Third party drivers for the INDI astronomical software suite";
    changelog = "https://github.com/indilib/indi-3rdparty/releases/tag/v${version}";
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [ hjones2199 ];
    platforms = platforms.linux;
  };
}
