{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  at-spi2-atk,
  at-spi2-core,
  alsa-lib,
  cairo,
  cups,
  dbus,
  expat,
  gdk-pixbuf,
  glib,
  gtk3,
  libdrm,
  libgbm,
  libnotify,
  libusb1,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxkbcommon,
  libxrandr,
  nspr,
  nss,
  pango,
  qt5,
  qt6,
  systemd,
  xdg-utils,
}:

let
  source = import ./source.nix;
in
stdenv.mkDerivation {
  pname = "chatgpt";
  inherit (source) version;

  src = fetchurl source.src;

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    at-spi2-atk
    at-spi2-core
    alsa-lib
    cairo
    cups
    dbus
    expat
    gdk-pixbuf
    glib
    gtk3
    libdrm
    libgbm
    libnotify
    libusb1
    libx11
    libxcb
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxkbcommon
    libxrandr
    nspr
    nss
    pango
    systemd
    stdenv.cc.cc
  ];

  # The bundle includes Node modules for both glibc and musl. Only the glibc
  # variants are selected on NixOS.
  autoPatchelfIgnoreMissingDeps = [ "libc.musl-x86_64.so.1" ];

  preFixup = ''
    addAutoPatchelfSearchPath ${qt5.qtbase}/lib
    addAutoPatchelfSearchPath ${qt6.qtbase}/lib
  '';

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb --fsys-tarfile "$src" | tar -x
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    cp -a usr/. "$out"

    makeWrapper "$out/lib/chatgpt/ChatGPT" "$out/bin/chatgpt" \
      --prefix PATH : ${lib.makeBinPath [ xdg-utils ]}

    runHook postInstall
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Desktop application for ChatGPT";
    homepage = "https://developers.openai.com/codex/app";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ wattmto ];
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "chatgpt";
  };
}
