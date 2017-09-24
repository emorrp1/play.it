#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2017, Antoine Le Gonidec
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# This software is provided by the copyright holders and contributors "as is"
# and any express or implied warranties, including, but not limited to, the
# implied warranties of merchantability and fitness for a particular purpose
# are disclaimed. In no event shall the copyright holder or contributors be
# liable for any direct, indirect, incidental, special, exemplary, or
# consequential damages (including, but not limited to, procurement of
# substitute goods or services; loss of use, data, or profits; or business
# interruption) however caused and on any theory of liability, whether in
# contract, strict liability, or tort (including negligence or otherwise)
# arising in any way out of the use of this software, even if advised of the
# possibility of such damage.
###

###
# Invisible Inc.
# build native Linux packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20170924.1

# Set game-specific variables

GAME_ID='invisible-inc'
GAME_NAME='Invisible Inc.'

ARCHIVES_LIST='ARCHIVE_GOG'

ARCHIVE_GOG='gog_invisible_inc_2.6.0.11.sh'
ARCHIVE_GOG_MD5='97e6efdc9237ec17deb02b5cf5185cf5'
ARCHIVE_GOG_SIZE='1200000'
ARCHIVE_GOG_VERSION='2016.04.13-gog2.6.0.11'

ARCHIVE_ICONS='invisible-inc_icons.tar.gz'
ARCHIVE_ICONS_MD5='37a62fed1dc4185e95db3e82e6695c1d'

ARCHIVE_DOC1_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC1_DATA_FILES='./*'

ARCHIVE_DOC2_DATA_PATH='data/noarch/game'
ARCHIVE_DOC2_DATA_FILES='./LICENSE'

ARCHIVE_GAME_BIN32_PATH='data/noarch/game'
ARCHIVE_GAME_BIN32_FILES='./InvisibleInc32 ./lib32'

ARCHIVE_GAME_BIN64_PATH='data/noarch/game'
ARCHIVE_GAME_BIN64_FILES='./InvisibleInc64 ./lib64'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='./*.kwad ./*.lua ./hashes.dat ./scripts.zip'

ARCHIVE_ICONS_PATH='.'
ARCHIVE_ICONS_FILES='./16x16 ./32x32 ./64x64 ./128x128 ./256x256'

APP_MAIN_TYPE='native'
APP_MAIN_LIBS_BIN32='lib32'
APP_MAIN_LIBS_BIN64='lib64'
APP_MAIN_EXE_BIN32='InvisibleInc32'
APP_MAIN_EXE_BIN64='InvisibleInc64'
APP_MAIN_ICON_GOG='data/noarch/support/icon.png'
APP_MAIN_ICON_GOG_RES='256'

PACKAGES_LIST='PKG_DATA PKG_BIN32 PKG_BIN64'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS_DEB="$PKG_DATA_ID, libc6, libstdc++6, libsdl2-2.0-0, libgl1-mesa-glx | libgl1"
PKG_BIN32_DEPS_ARCH="$PKG_DATA_ID lib32-glibc lib32-gcc-libs lib32-sdl2 lib32-libgl"

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS_DEB="$PKG_BIN32_DEPS_DEB"
PKG_BIN64_DEPS_ARCH="$PKG_DATA_ID glibc gcc-libs sdl2 libgl"

# Load common functions

target_version='2.1'

if [ -z "$PLAYIT_LIB2" ]; then
	[ -n "$XDG_DATA_HOME" ] || XDG_DATA_HOME="$HOME/.local/share"
	if [ -e "$XDG_DATA_HOME/play.it/play.it-2/lib/libplayit2.sh" ]; then
		PLAYIT_LIB2="$XDG_DATA_HOME/play.it/play.it-2/lib/libplayit2.sh"
	elif [ -e './libplayit2.sh' ]; then
		PLAYIT_LIB2='./libplayit2.sh'
	else
		printf '\n\033[1;31mError:\033[0m\n'
		printf 'libplayit2.sh not found.\n'
		return 1
	fi
fi
. "$PLAYIT_LIB2"

# Try to load icons archive

ARCHIVE_MAIN="$ARCHIVE"
set_archive 'ICONS_PACK' 'ARCHIVE_ICONS'
ARCHIVE="$ARCHIVE_MAIN"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
if [ "$ICONS_PACK" ]; then  
	(
		ARCHIVE='ICONS_PACK'
		extract_data_from "$ICONS_PACK"
	)
fi

for PKG in $PACKAGES_LIST; do
	organize_data "DOC1_${PKG#PKG_}" "$PATH_DOC"
	organize_data "DOC2_${PKG#PKG_}" "$PATH_DOC"
	organize_data "GAME_${PKG#PKG_}" "$PATH_GAME"
done

if [ "$ICONS_PACK" ]; then
	organize_data 'ICONS' "$PATH_ICON_BASE"
else
	res="$APP_MAIN_ICON_GOG_RES"
	PATH_ICON="$PATH_ICON_BASE/${res}x${res}/apps"
	mkdir --parents "$PKG_DATA_PATH/$PATH_ICON"
	mv "$PLAYIT_WORKDIR/gamedata/$APP_MAIN_ICON_GOG" "$PKG_DATA_PATH/$PATH_ICON/$GAME_ID.png"
fi

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

for PKG in 'PKG_BIN32' 'PKG_BIN64'; do
	write_launcher 'APP_MAIN'
done

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

printf '\n'
printf '32-bit:'
print_instructions 'PKG_DATA' 'PKG_BIN32'
printf '64-bit:'
print_instructions 'PKG_DATA' 'PKG_BIN64'

exit 0
