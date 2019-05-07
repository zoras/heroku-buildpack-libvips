#!/bin/bash

set -e

# Set vips version
export VIPS_VERSION=8.8.0-rc1
export WEBP_VERSION=1.0.2
export ORC_VERSION=0.4.29
export TIFF_VERSION=4.0.10
export GETTEXT_VERSION=latest
export SVG_VERSION=2.45.5
export GIF_VERSION=5.1.9
export BUILD_PATH=/tmp
export OUT_PATH=$OUT_DIR/app/vendor/vips
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$OUT_PATH/lib/pkgconfig
export PATH=$PATH:$OUT_PATH/bin

# Based on https://gist.github.com/chrismdp/6c6b6c825b07f680e710
function putS3 {
  file=$1
  aws_path=$2
  aws_id=$3
  aws_token=$4
  aws_bucket=$5
  date=$(date +"%a, %d %b %Y %T %z")
  acl="x-amz-acl:public-read"
  content_type='application/x-compressed-tar'
  string="PUT\n\n$content_type\n$date\n$acl\n/$aws_bucket$aws_path$file"
  signature=$(echo -en "${string}" | openssl sha1 -hmac "${aws_token}" -binary | base64)
  curl -X PUT -T "$file" \
    -H "Host: $aws_bucket.s3.amazonaws.com" \
    -H "Date: $date" \
    -H "Content-Type: $content_type" \
    -H "$acl" \
    -H "Authorization: AWS ${aws_id}:$signature" \
    "https://$aws_bucket.s3.amazonaws.com$aws_path$file"
  echo "Uploaded to https://$aws_bucket.s3.amazonaws.com$aws_path$file"
}

# These should be set from the outside. A git version and heroku/travis respectively
if [ -z "$VERSION" ]
then
    VERSION="unknown"
fi
if [ -z "$TARGET" ]
then
    TARGET="unknown"
fi

# Remove out path if already exists
rm -Rf $OUT_PATH

# Build path
cd $BUILD_PATH

###############
#     Orc     #
###############
function build_orc {
    # Download orc dependency
    curl http://cgit.freedesktop.org/gstreamer/orc/snapshot/orc-$ORC_VERSION.tar.gz -o orc.tar.gz
    # Unzip
    tar -xvf orc.tar.gz
    # Get into orc folder
    cd orc-$ORC_VERSION
    # Configure
    ./autogen.sh
    # Configure build
    ./configure --prefix $OUT_PATH
    # Make orc
    make
    # Install orc
    make install
}

###############
#     WebP    #
###############
function build_webp {
    # Download webp dependency
    curl https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-$WEBP_VERSION.tar.gz -o libwebp.tar.gz
    # Unzip
    tar -xvf libwebp.tar.gz
    # Get into webp folder
    cd libwebp-$WEBP_VERSION
    # Configure build
    ./configure --prefix $OUT_PATH
    # Make libwebp
    make
    # Install webp
    make install
}

# Build path
cd $BUILD_PATH



# Build path
cd $BUILD_PATH

###############
#   LIBTIFF   #
###############
function build_libtiff {
    # Download tiff dependency
    curl http://download.osgeo.org/libtiff/tiff-$TIFF_VERSION.tar.gz -o libtiff.tar.gz
    # Unzip
    tar -xvf libtiff.tar.gz
    # Get into libtiff folder
    cd tiff-$TIFF_VERSION
    # Configure build
    ./configure --prefix $OUT_PATH
    # Make libtiff
    make
    # Install libtiff
    make install
}

###############
#    CPANM    #
###############
function build_cpanm {
    # Download cpanm
    curl https://raw.githubusercontent.com/miyagawa/cpanminus/master/cpanm -o cpanm
    # Make it executable
    chmod +x cpanm
    # Use local lib
    ./cpanm --local-lib=~/perl5 local::lib && eval $(perl -I ~/perl5/lib/perl5/ -Mlocal::lib)
    # Install xml module (in /app/perl5)
    ./cpanm -v XML::Parser
}

###############
#  INTLTOOL   #
###############
function build_intltool {
    # Download intltool dependency
    curl http://ftp.gnome.org/pub/GNOME/sources/intltool/0.40/intltool-0.40.6.tar.gz -o intltool.tar.gz
    # Unzip
    tar -xvf intltool.tar.gz
    # Get into intltool folder
    cd intltool-0.40.6
    # Configure build
    ./configure --prefix $OUT_PATH
    # Make intltool
    make
    # Install intltool
    make install
}

###############
#   GETTEXT   #
###############
function build_gettext {
    # Download gettext dependency
    curl http://ftp.gnu.org/pub/gnu/gettext/gettext-$GETTEXT_VERSION.tar.gz -o gettext.tar.gz
    # Unzip
    tar -xvf gettext.tar.gz
    # Get into gettext folder
    cd gettext-$GETTEXT_VERSION
    # Configure build
    ./configure --prefix $OUT_PATH
    # Make gettext
    make
    # Install gettext
    make install
}

###############
#    LIBFFI   #
###############
function build_libffi {
    # Download libffi dependency
    curl ftp://sourceware.org/pub/libffi/libffi-3.2.1.tar.gz -o libffi.tar.gz
    # Unzip
    tar -xvf libffi.tar.gz
    # Get into libffi folder
    cd libffi-3.2.1
    # Configure build
    ./configure --prefix $OUT_PATH
    # Make libffi
    make
    # Install libffi
    make install
}

###############
#     GLIB    #
###############
function build_glib {
    # Download glib dependency
    curl -L https://github.com/GNOME/glib/archive/2.60.2.tar.gz -o glib.tar.gz
    # Unzip
    tar -xvf glib.tar.gz
    # Get into glib folder
    cd glib-2.60.2
    # Configure build
    ./configure --prefix $OUT_PATH
    # Make glib
    make
    # Install glib
    make install
}

###############
#     Intltool     #
###############
function build_intltool {
    cpan install XML::Parser
    # Download libgsf dependency
    curl -L https://launchpad.net/intltool/trunk/0.51.0/+download/intltool-0.51.0.tar.gz -o intltool.tar.gz
    # Unzip
    tar -xvf intltool.tar.gz
    # Get into libgsf folder
    cd intltool-0.51.0
    # Configure build
    ./configure --prefix $OUT_PATH
    # Make gsf
    make
    # Install gsf
    make install
}

###############
#     GSF     #
###############
function build_gsf {
    # Download libgsf dependency
    curl -L https://github.com/GNOME/libgsf/archive/LIBGSF_1_14_46.tar.gz -o libgsf.tar.gz
    # Unzip
    tar -xvf libgsf.tar.gz
    # Get into libgsf folder
    cd libgsf-LIBGSF_1_14_46
    # Configure build
    ./configure --prefix $OUT_PATH
    # Make gsf
    make
    # Install gsf
    make install
}

###############
#   CFITSIO   #
###############
function build_cftsio {
    # Download CFITSIO dependency
    curl -L ftp://heasarc.gsfc.nasa.gov/software/fitsio/c/cfitsio3450.tar.gz -o cfitsio.tar.gz
    # Unzip
    tar -xvf cfitsio.tar.gz
    # Get into CFITSIO folder
    cd cfitsio
    # Configure build
    ./configure --prefix $OUT_PATH
    # Make cfitsio
    make
    # Install cfitsio
    make install
}

# SVG
function build_svg {
  curl -L https://github.com/GNOME/librsvg/archive/${SVG_VERSION}.tar.gz -o librsvg.tar.gz
  tar -xvf librsvg.tar.gz
  cd librsvg-${SVG_VERSION}
  ./configure --prefix $OUT_PATH --enable-shared --disable-static \
  --disable-dependency-tracking --disable-introspection --disable-tools
  make
  make install
}

# GIF
function build_gif {
  curl -L http://downloads.sourceforge.net/project/giflib/giflib-${GIF_VERSION}.tar.bz2 -o giflib.tar.bz2
  tar -xvf giflib.tar.bz2
  cd giflib-$GIF_VERSION
  ./configure --prefix $OUT_PATH --enable-shared --disable-static \
  --disable-dependency-tracking
  make
  make install
}

###############
#     LCMS    #
###############
function build_lcms2 {
    # Download lcms dependency
    curl -L http://downloads.sourceforge.net/project/lcms/lcms/2.9/lcms2-2.9.tar.gz -o lcms.tar.gz
    # Unzip
    tar -xvf lcms.tar.gz
    # Get into lcms folder
    cd lcms2-2.9
    # Configure build
    ./configure --prefix $OUT_PATH
    # Make lcms
    make
    # Install lcms
    make install
}

###############
#     VIPS    #
###############
function build_vips {
    # Download vips runtime
    curl -L https://github.com/libvips/libvips/releases/download/v$VIPS_VERSION/vips-$VIPS_VERSION.tar.gz -o vips.tar.gz
    # Unzip
    tar -xvf vips.tar.gz
    # Get into vips folder
    cd vips-$VIPS_VERSION
    # Configure build and output everything in /tmp/vips
    ./configure --prefix $OUT_PATH --enable-shared --disable-static --disable-dependency-tracking \
  --disable-debug --disable-introspection --without-python --without-fftw \
  --without-magick --without-pangoft2 --without-ppm --without-analyze --without-radiance \
  --with-giflib-includes=$OUT_PATH/include \
  --with-giflib-libraries=$OUT_PATH/lib
    # Make
    make
    # install vips
    make install
}


### Build
# TODO: separate what is built on Travis and Heroku, minimize by pulling in relevant packages from APT
cd $BUILD_PATH
build_webp
# cd $BUILD_PATH
# build_libtiff # DISABLED
cd $BUILD_PATH
build_glib
cd $BUILD_PATH
build_gsf
cd $BUILD_PATH
build_cftsio
cd $BUILD_PATH
build_lcms2
cd $BUILD_PATH
#build_svg
cd $BUILD_PATH
build_gif
cd $BUILD_PATH
build_vips


###############
#    Output   #
###############

# Get into output path
cd $OUT_PATH
# Clean useless files
rm -rf $OUT_PATH/share/{doc,gtk-doc}
# Create dist package
tar -cvzf libvips-${VERSION}-${TARGET}.tgz *

###############
#     S3      #
###############
if [ -z "$AMAZON_API_TOKEN" ];
then
    echo "Amazon API Token not provided, skipping upload";
else
    putS3 "libvips-${VERSION}-${TARGET}.tgz" "/bundles/" $AMAZON_API_ID $AMAZON_API_TOKEN $AMAZON_API_BUCKET
fi
