#!/bin/sh

# Copyright (C) 2007 Segher Boessenkool <segher@kernel.crashing.org>
# Copyright (C) 2009 Hector Martin "marcan" <hector@marcansoft.com>
# Copyright (C) 2009 Andre Heider "dhewg" <dhewg@V850brew.org>
# Copyright (C) 2010 Alex Marshall "trap15" <trap15@raidenii.net>

# Released under the terms of the GNU GPL, version 2

GNU_FTP="http://ftp.gnu.org/gnu"
#GNU_FTP="ftp://mirrors.usc.edu/pub/gnu"

BINUTILS_VER=2.20
BINUTILS_DIR="binutils-$BINUTILS_VER"
BINUTILS_TARBALL="binutils-$BINUTILS_VER.tar.bz2"
BINUTILS_URI="$GNU_FTP/binutils/$BINUTILS_TARBALL"

GMP_VER=5.0.1
GMP_DIR="gmp-$GMP_VER"
GMP_TARBALL="gmp-$GMP_VER.tar.bz2"
GMP_URI="$GNU_FTP/gmp/$GMP_TARBALL"

MPFR_VER=2.4.2
MPFR_DIR="mpfr-$MPFR_VER"
MPFR_TARBALL="mpfr-$MPFR_VER.tar.bz2"
MPFR_URI="http://www.mpfr.org/mpfr-$MPFR_VER/$MPFR_TARBALL"
#MPFR_URI="ftp://mirrors.usc.edu/pub/gnu/mpfr/$MPFR_TARBALL"

MPC_VER=0.8.2
MPC_DIR="mpc-$MPC_VER"
MPC_TARBALL="mpc-$MPC_VER.tar.gz"
MPC_URI="http://www.multiprecision.org/mpc/download/$MPC_TARBALL"

GCC_VER=4.5.1
GCC_DIR="gcc-$GCC_VER"
GCC_TARBALL="gcc-$GCC_VER.tar.bz2"
GCC_URI="$GNU_FTP/gcc/gcc-$GCC_VER/$GCC_TARBALL"

GDB_VER=7.1
GDB_DIR="gdb-$GDB_VER"
GDB_TARBALL="gdb-$GDB_VER.tar.bz2"
GDB_URI="$GNU_FTP/gdb/$GDB_TARBALL"

NEWLIB_VER=1.18.0
NEWLIB_DIR="newlib-$NEWLIB_VER"
NEWLIB_TARBALL="newlib-$NEWLIB_VER.tar.gz"
NEWLIB_URI="ftp://sources.redhat.com/pub/newlib/$NEWLIB_TARBALL"

PATCHDIR=patches

BUILDTYPE=$1

SPU_TARGET=spu
PPU_TARGET=powerpc-eabi
PPU64_TARGET=powerpc64-linux

if [ -z $MAKEOPTS ]; then
	MAKEOPTS=-j3
fi

# End of configuration section.

case `uname -s` in
	*BSD*)
		MAKE=gmake
		;;
	*)
		MAKE=make
esac

export PATH=$PS3DEV/bin:$PATH

die() {
	echo $@
	exit 1
}

cleansrc() {
	[ -e $PS3DEV/$BINUTILS_DIR ] && rm -rf $PS3DEV/$BINUTILS_DIR
	[ -e $PS3DEV/$GCC_DIR ] && rm -rf $PS3DEV/$GCC_DIR
	[ -e $PS3DEV/$GDB_DIR ] && rm -rf $PS3DEV/$GDB_DIR
	[ -e $PS3DEV/$NEWLIB_DIR ] && rm -rf $PS3DEV/$NEWLIB_DIR
}

cleanbuild() {
	[ -e $PS3DEV/build_binutils ] && rm -rf $PS3DEV/build_binutils
	[ -e $PS3DEV/build_gcc ] && rm -rf $PS3DEV/build_gcc
	[ -e $PS3DEV/build_gdb ] && rm -rf $PS3DEV/build_gdb
	[ -e $PS3DEV/build_newlib ] && rm -rf $PS3DEV/build_newlib
}

download() {
	DL=1
	if [ -f "$PS3DEV/$2" ]; then
		echo "Testing $2..."
# Check bz2 and gz
		tar tjf "$PS3DEV/$2" >/dev/null 2>&1 && DL=0
		if [ $DL -eq 1 ]; then
			tar tzf "$PS3DEV/$2" >/dev/null 2>&1 && DL=0
		fi
	fi

	if [ $DL -eq 1 ]; then
		echo "Downloading $2..."
		wget "$1" -c -O "$PS3DEV/$2" || die "Could not download $2"
	fi
}

extract() {
	echo "Extracting $1..."
	tar xf "$PS3DEV/$1" -C "$2" || die "Error unpacking $1"
}

extract_archives() {
	cleansrc
	extract "$BINUTILS_TARBALL" "$PS3DEV"
	extract "$GCC_TARBALL" "$PS3DEV"
	extract "$NEWLIB_TARBALL" "$PS3DEV"
	extract "$GDB_TARBALL" "$PS3DEV"
	extract "$GMP_TARBALL" "$PS3DEV/$GCC_DIR"
	mv "$PS3DEV/$GCC_DIR/$GMP_DIR" "$PS3DEV/$GCC_DIR/gmp" || die "Error renaming $GMP_DIR -> gmp"
	extract "$MPFR_TARBALL" "$PS3DEV/$GCC_DIR"
	mv "$PS3DEV/$GCC_DIR/$MPFR_DIR" "$PS3DEV/$GCC_DIR/mpfr" || die "Error renaming $MPFR_DIR -> mpfr"
	extract "$MPC_TARBALL" "$PS3DEV/$GCC_DIR"
	mv "$PS3DEV/$GCC_DIR/$MPC_DIR" "$PS3DEV/$GCC_DIR/mpc" || die "Error renaming $MPC_DIR -> mpc"
}

create_syms() {
	TARGET=$1
	FOLDER=$2
	ln -s $PS3DEV/$FOLDER/bin/$TARGET-addr2line	$PS3DEV/$FOLDER/bin/$FOLDER-addr2line	 >/dev/null
	ln -s $PS3DEV/$FOLDER/bin/$TARGET-ar		$PS3DEV/$FOLDER/bin/$FOLDER-ar		 >/dev/null
	ln -s $PS3DEV/$FOLDER/bin/$TARGET-as		$PS3DEV/$FOLDER/bin/$FOLDER-as		 >/dev/null
	ln -s $PS3DEV/$FOLDER/bin/$TARGET-c++		$PS3DEV/$FOLDER/bin/$FOLDER-c++		 >/dev/null
	ln -s $PS3DEV/$FOLDER/bin/$TARGET-c++filt	$PS3DEV/$FOLDER/bin/$FOLDER-c++filt	 >/dev/null
	ln -s $PS3DEV/$FOLDER/bin/$TARGET-cpp		$PS3DEV/$FOLDER/bin/$FOLDER-cpp		 >/dev/null
	ln -s $PS3DEV/$FOLDER/bin/$TARGET-embedspu	$PS3DEV/$FOLDER/bin/$FOLDER-embedspu	 >/dev/null
	ln -s $PS3DEV/$FOLDER/bin/$TARGET-g++		$PS3DEV/$FOLDER/bin/$FOLDER-g++		 >/dev/null
	ln -s $PS3DEV/$FOLDER/bin/$TARGET-gcc		$PS3DEV/$FOLDER/bin/$FOLDER-gcc		 >/dev/null
	ln -s $PS3DEV/$FOLDER/bin/$TARGET-gcc-4.5.1	$PS3DEV/$FOLDER/bin/$FOLDER-gcc-4.5.1	 >/dev/null
	ln -s $PS3DEV/$FOLDER/bin/$TARGET-gccbug	$PS3DEV/$FOLDER/bin/$FOLDER-gccbug	 >/dev/null
	ln -s $PS3DEV/$FOLDER/bin/$TARGET-gcov		$PS3DEV/$FOLDER/bin/$FOLDER-gcov	 >/dev/null
	ln -s $PS3DEV/$FOLDER/bin/$TARGET-gdb		$PS3DEV/$FOLDER/bin/$FOLDER-gdb		 >/dev/null
	ln -s $PS3DEV/$FOLDER/bin/$TARGET-gdbtui	$PS3DEV/$FOLDER/bin/$FOLDER-gdbtui	 >/dev/null
	ln -s $PS3DEV/$FOLDER/bin/$TARGET-gprof		$PS3DEV/$FOLDER/bin/$FOLDER-gprof	 >/dev/null
	ln -s $PS3DEV/$FOLDER/bin/$TARGET-ld		$PS3DEV/$FOLDER/bin/$FOLDER-ld		 >/dev/null
	ln -s $PS3DEV/$FOLDER/bin/$TARGET-nm		$PS3DEV/$FOLDER/bin/$FOLDER-nm		 >/dev/null
	ln -s $PS3DEV/$FOLDER/bin/$TARGET-objcopy	$PS3DEV/$FOLDER/bin/$FOLDER-objcopy	 >/dev/null
	ln -s $PS3DEV/$FOLDER/bin/$TARGET-objdump	$PS3DEV/$FOLDER/bin/$FOLDER-objdump	 >/dev/null
	ln -s $PS3DEV/$FOLDER/bin/$TARGET-ranlib	$PS3DEV/$FOLDER/bin/$FOLDER-ranlib	 >/dev/null
	ln -s $PS3DEV/$FOLDER/bin/$TARGET-readelf	$PS3DEV/$FOLDER/bin/$FOLDER-readelf	 >/dev/null
	ln -s $PS3DEV/$FOLDER/bin/$TARGET-size		$PS3DEV/$FOLDER/bin/$FOLDER-size	 >/dev/null
	ln -s $PS3DEV/$FOLDER/bin/$TARGET-strings	$PS3DEV/$FOLDER/bin/$FOLDER-strings	 >/dev/null
	ln -s $PS3DEV/$FOLDER/bin/$TARGET-strip		$PS3DEV/$FOLDER/bin/$FOLDER-strip	 >/dev/null
}

makedirs() {
	mkdir -p $PS3DEV/build_binutils || die "Error making binutils build directory $PS3DEV/build_binutils"
	mkdir -p $PS3DEV/build_gcc || die "Error making gcc build directory $PS3DEV/build_gcc"
	mkdir -p $PS3DEV/build_gdb || die "Error making gdb build directory $PS3DEV/build_gdb"
	mkdir -p $PS3DEV/build_newlib || die "Error making newlib build directory $PS3DEV/build_newlib"
}

buildbinutils() {
	TARGET=$1
	FOLDER=$2
	(
		cd $PS3DEV/build_binutils && \
		$PS3DEV/$BINUTILS_DIR/configure --target=$TARGET --disable-multilib \
			--prefix=$PS3DEV/$FOLDER --disable-werror && \
		$MAKE $MAKEOPTS && \
		$MAKE install
	) || die "Error building binutils for target $TARGET"
}

buildnewlib() {
	TARGET=$1
	FOLDER=$2
	(
		cd $PS3DEV/build_newlib && \
		$PS3DEV/$NEWLIB_DIR/configure --target=$TARGET \
			--prefix=$PS3DEV/$FOLDER && \
		$MAKE $MAKEOPTS && \
		$MAKE install
	) || die "Error building newlib for target $TARGET"
}

buildgcc() {
	TARGET=$1
	FOLDER=$2
	NEWLIBFLAG=$3
	(
		cd $PS3DEV/build_gcc && \
		$PS3DEV/$GCC_DIR/configure --target=$TARGET --disable-multilib \
			--prefix=$PS3DEV/$FOLDER \
			--enable-languages="c,c++" \
			--enable-checking=release $NEWLIBFLAG && \
		$MAKE all-gcc $MAKEOPTS && \
		$MAKE install-gcc
	) || die "Error building gcc for target $TARGET"
}

buildgdb() {
	TARGET=$1
	FOLDER=$2
	(
		cd $PS3DEV/build_gdb && \
		$PS3DEV/$GDB_DIR/configure --target=$TARGET --disable-multilib \
			--prefix=$PS3DEV/$FOLDER --disable-werror \
			--disable-sim && \
		$MAKE $MAKEOPTS && \
		$MAKE install
	) || die "Error building gdb for target $TARGET"
}


buildspu() {
	extract_archives
	cleanbuild
	makedirs
	echo "******* Building SPU binutils"
	buildbinutils $SPU_TARGET spu
	echo "******* Building SPU GCC"
	buildgcc $SPU_TARGET spu
	echo "******* Building SPU Newlib"
	buildnewlib $SPU_TARGET spu
	echo "******* Building SPU GCC"
	buildgcc $SPU_TARGET spu --with-newlib
	echo "******* Building SPU GDB"
	buildgdb $SPU_TARGET spu
	echo "******* SPU toolchain built and installed"
}

buildppu() {
	extract_archives
	cleanbuild
	makedirs
	echo "******* Building PPU binutils"
	buildbinutils $PPU_TARGET ppu
	echo "******* Building PPU GCC"
	buildgcc $PPU_TARGET ppu
	echo "******* Building PPU Newlib"
	buildnewlib $PPU_TARGET ppu
	echo "******* Building PPU GCC"
	buildgcc $PPU_TARGET ppu --with-newlib
	echo "******* Building PPU GDB"
	buildgdb $PPU_TARGET ppu
	echo "******* Creating symlinks!"
	create_syms $PPU_TARGET ppu
	echo "******* PPU toolchain built and installed"
}

buildppu64() {
	extract_archives
	cleanbuild
	makedirs
	echo "******* Building PPU64 binutils"
	buildbinutils $PPU64_TARGET ppu64
	echo "******* Building PPU64 GCC"
	buildgcc $PPU64_TARGET ppu64
	echo "******* Building PPU64 Newlib"
	buildnewlib $PPU64_TARGET ppu64
	echo "******* Building PPU64 GCC"
	buildgcc $PPU64_TARGET ppu64 --with-newlib
	echo "******* Building PPU64 GDB"
	buildgdb $PPU64_TARGET ppu64
	echo "******* Creating symlinks!"
	create_syms $PPU64_TARGET ppu64
	echo "******* PPU64 toolchain built and installed"
}

if [ -z "$PS3DEV" ]; then
	die "Please set PS3DEV in your environment."
fi

if [ $# -eq 0 ]; then
	die "Please specify build type(s) (ppu/ppu64/spu/clean)"
fi

if [ "$BUILDTYPE" = "clean" ]; then
	cleanbuild
	cleansrc
	exit 0
fi

#cp -R $PATCHDIR $PS3DEV

download "$BINUTILS_URI" "$BINUTILS_TARBALL"
download "$GMP_URI" "$GMP_TARBALL"
download "$MPFR_URI" "$MPFR_TARBALL"
download "$MPC_URI" "$MPC_TARBALL"
download "$GCC_URI" "$GCC_TARBALL"
download "$NEWLIB_URI" "$NEWLIB_TARBALL"
download "$GDB_URI" "$GDB_TARBALL"

if [ "$1" = "all" ]; then
	buildppu
	buildppu64
	buildspu
	cleanbuild
	cleansrc
	exit 0
fi

while true; do
	if [ $# -eq 0 ]; then
		exit 0
	fi
	case $1 in
		ppu)		buildppu ;;
		ppu64)		buildppu64 ;;
		spu)		buildspu ;;
		clean)		cleanbuild; cleansrc; exit 0 ;;
		*)
			die "Unknown build type $1"
			;;
	esac
	shift;
done

