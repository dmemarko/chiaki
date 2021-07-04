#!/bin/bash

cd $(dirname "${BASH_SOURCE[0]}")/..
cd "./$1"
shift
ROOT="`pwd`"

TAG=n4.3.1

# git clone https://git.ffmpeg.org/ffmpeg.git --depth 1 -b $TAG && cd ffmpeg || exit 1
cd ffmpeg

./configure --disable-all --enable-avcodec --enable-decoder=h264 --enable-decoder=h264_vda --enable-hwaccel=h264_vda --enable-hwaccel=h264_videotoolbox --enable-videotoolbox --prefix="$ROOT/ffmpeg-prefix" "$@" || exit 1
make -j4 || exit 1
make install || exit 1
