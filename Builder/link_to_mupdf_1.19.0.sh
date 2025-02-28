#!/usr/bin/env bash
#. ~/.profile

# get the location of this script, we will checkout mupdf into the same directory
BUILD_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd $BUILD_DIR

VERSION_TAG=1.19.0

MUPDF_ROOT=$BUILD_DIR/mupdf-$VERSION_TAG
MUPDF_JAVA=$MUPDF_ROOT/platform/librera

SRC=jni/~mupdf-$VERSION_TAG
DEST=$MUPDF_ROOT/source/
SRC_FILES=$SRC/src_files/
LIBS=$BUILD_DIR/../app/src/main/jniLibs


echo "MUPDF :" $VERSION_TAG
echo "================== "
mkdir mupdf-$VERSION_TAG
git clone --recursive git://git.ghostscript.com/mupdf.git --branch $VERSION_TAG mupdf-$VERSION_TAG

cd mupdf-$VERSION_TAG

git reset --hard
#git clean -f -d

echo "=================="

if [ "$1" == "clean" ]; then
  make clean
fi

make release
make generate
echo "=================="

cd ..

mkdir -p $MUPDF_JAVA/jni

rm -rf  $MUPDF_JAVA/jni
cp -rRp jni $MUPDF_JAVA/jni
mv $MUPDF_JAVA/jni/Android-$VERSION_TAG.mk $MUPDF_JAVA/jni/Android.mk

rm -r $LIBS
mkdir $LIBS

ln -s $MUPDF_JAVA/libs/armeabi-v7a $LIBS
ln -s $MUPDF_JAVA/libs/arm64-v8a $LIBS
ln -s $MUPDF_JAVA/libs/x86 $LIBS
ln -s $MUPDF_JAVA/libs/x86_64 $LIBS

rm -rfv $SRC_FILES
mkdir $SRC_FILES

cp -rpv $DEST/html/css-apply.c $SRC_FILES
cp -rpv $DEST/html/epub-doc.c $SRC_FILES
cp -rpv $DEST/html/html-layout.c $SRC_FILES
cp -rpv $DEST/html/html-parse.c $SRC_FILES
cp -rpv $DEST/cbz/mucbz.c $SRC_FILES


cp -rpv $SRC/html-layout.c       $DEST/html/html-layout.c
cp -rpv $SRC/epub-doc.c          $DEST/html/epub-doc.c
cp -rpv $SRC/html-parse.c        $DEST/html/html-parse.c
cp -rpv $SRC/css-apply.c         $DEST/html/css-apply.c
cp -rpv $SRC/mucbz.c             $DEST/cbz/mucbz.c


cd $MUPDF_JAVA

if [ "$1" == "clean2" ]; then
ndk-build clean
fi

ndk-build

echo "=================="
echo "MUPDF:" $MUPDF_JAVA
echo "LIBS:"  $LIBS
echo "=================="
