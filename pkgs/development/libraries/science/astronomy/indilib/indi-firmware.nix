{ stdenv
, lib
, autoPatchelfHook
, bash
, cmake
, cfitsio
, coreutils
, libusb1
, pkg-config
, systemd
, zlib
, boost
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
}:

stdenv.mkDerivation rec {
  pname = "indi-firmware";

  inherit version src;

  nativeBuildInputs = [ cmake autoPatchelfHook ];

  libusb = libusb1.override { withExamples = true;};

  buildInputs = [
    indilib
    libnova
    bash
    curl
    cfitsio
    libusb
    pkg-config
    systemd
    zlib
    boost
    gsl
    gpsd
    libjpeg
    libgphoto2
    libraw
    libftdi1
    libdc1394
    ffmpeg
    fftw
  ];

  cmakeFlags = [
    "-DINDI_DATA_DIR=\${CMAKE_INSTALL_PREFIX}/share/indi"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DUDEVRULES_INSTALL_DIR=lib/udev/rules.d"
    "-DRULES_INSTALL_DIR=lib/udev/rules.d"
    "-DFIRMWARE_INSTALL_DIR=lib/firmware"
    "-DQHY_FIRMWARE_INSTALL_DIR=\${CMAKE_INSTALL_PREFIX}/lib/firmware/qhy"
    "-DCONF_DIR=etc"
    "-DBUILD_LIBS=1"
    "-DWITH_PENTAX=off"
  ];

  postPatch = ''
    for f in {libfishcamp,libsbig,libqhy}/CMakeLists.txt
    do
      substituteInPlace $f --replace "/lib/firmware" "lib/firmware"
    done
    find . -name "*.rules" | while read f
    do
      substituteInPlace "$f" --replace "/sbin/fxload" "${libusb.out}/sbin/fxload"
      substituteInPlace "$f" --replace "/bin/sleep" "${coreutils.out}/bin/sleep"
      substituteInPlace "$f" --replace "/bin/cat" "${coreutils.out}/bin/cat"
      substituteInPlace "$f" --replace "/bin/echo" "${coreutils.out}/bin/echo"
      substituteInPlace "$f" --replace "/bin/sh" "${bash.out}/bin/sh"
      substituteInPlace "$f" --replace "/lib/firmware/" "$out/lib/firmware/"
      sed -e 's|-D $env{DEVNAME}|-p $env{BUSNUM},$env{DEVNUM}|' -i "$f"
    done
  '';

  meta = with lib; {
    homepage = "https://www.indilib.org/";
    description = "Third party firmware for the INDI astronomical software suite";
    changelog = "https://github.com/indilib/indi-3rdparty/releases/tag/v${version}";
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [ hjones2199 ];
    platforms = platforms.linux;
  };
}
