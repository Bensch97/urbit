{ crossenv, xorg-macros, xproto, libxcb, xtrans,
  xextproto, inputproto, kbproto }:

let
  version = "1.6.5";

  src = crossenv.nixpkgs.fetchurl {
    url = "https://xorg.freedesktop.org/releases/individual/libX11-${version}.tar.bz2";
    sha256 = "0pa3cfp6h9rl2vxmkph65250gfqyki0ccqyaan6bl9d25gdr0f2d";
  };

  lib = crossenv.make_derivation rec {
    name = "libx11-${version}";

    inherit src version;

    builder = ./builder.sh;

    configure_flags =
      "--host=${crossenv.host} " +
      "--disable-malloc0returnsnull " +
      "--enable-static " +
      "--disable-shared";

    cross_inputs = [
      xorg-macros
      xproto
      libxcb
      xtrans
      xextproto
      inputproto
      kbproto
    ];

    inherit kbproto xproto libxcb;
  };

  license = crossenv.native.make_derivation {
    name = "${lib.name}-license";
    inherit src;
    builder = ./license_builder.sh;
  };

  license_set =
    xorg-macros.license_set //
    xproto.license_set //
    libxcb.license_set //
    xtrans.license_set //
    xextproto.license_set //
    inputproto.license_set //
    kbproto.license_set //
    { libx11 = license; };

in lib // { inherit license_set; }

