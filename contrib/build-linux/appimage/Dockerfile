# Note: we deliberately use an old Ubuntu LTS as base image.
# from https://docs.appimage.org/introduction/concepts.html :
# "[AppImages] should be built on the oldest possible system, allowing them to run on newer system[s]"
FROM ubuntu:20.04
LABEL description="Dedicated to building Electrum Dash appimage for Linux"

ENV LC_ALL=C.UTF-8 LANG=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -q && \
    apt-get install -qy \
        git \
        wget \
        make \
        cmake \
        autotools-dev \
        autoconf \
        libtool \
        autopoint \
        xz-utils \
        libssl-dev \
        libssl1.1 \
        openssl \
        zlib1g-dev \
        libffi-dev \
        libncurses5-dev \
        libsqlite3-dev \
        libusb-1.0-0-dev \
        libudev-dev \
        gettext \
        libzbar0  \
        libdbus-1-3 \
        libxkbcommon-x11-0 \
        libxcb1 \
        libxcb-xinerama0 \
        libxcb-randr0 \
        libxcb-render0 \
        libxcb-shm0 \
        libxcb-shape0 \
        libxcb-sync1 \
        libxcb-xfixes0 \
        libxcb-xkb1 \
        libxcb-icccm4 \
        libxcb-image0 \
        libxcb-keysyms1 \
        libxcb-util1 \
        libxcb-render-util0 \
        libx11-xcb1 \
        libc6-dev \
        libgmp-dev \
        && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get autoremove -y && \
    apt-get clean

# note: compiling python 3.8.x requires at least glibc 2.27,
#       which is first available on ubuntu 18.04
ENV PYTHON_VERSION=3.10.13 \
    PY_SHA=5c88848668640d3e152b35b4536ef1c23b2ca4bd2c957ef1ecbb053f571dd3f6 \
    LIBSECP_VERSION=dbd41db16a0e91b2566820898a3ab2d7dad4fe00 \
    APPDIR=/var/build/appimage/electrum-dash.AppDir \
    PYTHON_FTP=https://www.python.org/ftp/python

ENV PY_FILE=Python-$PYTHON_VERSION.tar.xz

RUN wget $PYTHON_FTP/$PYTHON_VERSION/$PY_FILE \
    && echo "$PY_SHA  $PY_FILE" > $PY_FILE.sha256 \
    && shasum -a256 -s -c $PY_FILE.sha256 \
    && tar xf $PY_FILE \
    && cd Python-$PYTHON_VERSION \
    && ./configure \
      --prefix="$APPDIR/usr" \
      --enable-ipv6 \
      --enable-shared \
      -q \
    && make -s \
    && make -s install > /dev/null \
    && cd .. && rm -rf $PY_FILE Python-$PYTHON_VERSION \
    && git clone https://github.com/bitcoin-core/secp256k1 \
    && cd secp256k1 \
    && git reset --hard "$LIBSECP_VERSION" \
    && git clean -f -x -q \
    && ./autogen.sh \
    && echo "LDFLAGS = -no-undefined" >> Makefile.am \
    && ./configure \
      --prefix="$APPDIR/usr" \
      --enable-module-recovery \
      --enable-experimental \
      --enable-module-ecdh \
      --disable-jni \
      --disable-benchmark \
      -q \
    && make -s \
    && make -s install > /dev/null \
    && cd .. && rm -rf secp256k1
