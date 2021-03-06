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
# Trine
# build native Linux packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20170824.1

# Set game-specific variables

GAME_ID='trine'
GAME_NAME='Trine'

ARCHIVES_LIST='ARCHIVE_GOG'

ARCHIVE_GOG='gog_trine_enchanted_edition_2.0.0.2.sh'
ARCHIVE_GOG_MD5='0e8d2338b568222b28cf3c31059b4960'
ARCHIVE_GOG_SIZE='1500000'
ARCHIVE_GOG_VERSION='2.12.508-gog2.0.0.2'

ARCHIVE_LIBPNG='libpng_1.2_32-bit.tar.gz'
ARCHIVE_LIBPNG_MD5='15156525b3c6040571f320514a0caa80'

ARCHIVE_DOC1_PATH='data/noarch/docs'
ARCHIVE_DOC1_FILES='./*'

ARCHIVE_DOC2_PATH='data/noarch/game'
ARCHIVE_DOC2_FILES='./*.txt'

ARCHIVE_GAME_BIN_PATH='data/noarch/game'
ARCHIVE_GAME_BIN_FILES='./bin/trine1_* ./lib'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='./*.fbq ./trine1.png ./data'

DATA_DIRS='./logs'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='bin/trine1_linux_launcher_32bit'
APP_MAIN_ICONS_LIST='APP_MAIN_ICON'
APP_MAIN_ICON='trine1.png'
APP_MAIN_ICON_RES='64'

PACKAGES_LIST='PKG_DATA PKG_BIN'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS_DEB="$PKG_DATA_ID, libc6, libstdc++6, libglu1-mesa | libglu1, libgtk2.0-0, libasound2-plugins, libopenal1, libvorbisfile3"
PKG_BIN_DEPS_ARCH="$PKG_DATA_ID lib32-glu lib32-gtk2 lib32-alsa-lib lib32-openal lib32-libvorbis"

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

# Use libpng 1.2 32-bit archive

set_archive 'LIBPNG' 'ARCHIVE_LIBPNG'
ARCHIVE='ARCHIVE_GOG'

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"

PKG='PKG_BIN'
organize_data 'GAME_BIN' "$PATH_GAME"

PKG='PKG_DATA'
organize_data 'DOC1'      "$PATH_DOC"
organize_data 'DOC2'      "$PATH_DOC"
organize_data 'GAME_DATA' "$PATH_GAME"

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Include libpng into the game directory

if [ "$LIBPNG" ]; then
	dir='libs'
	ARCHIVE='LIBPNG'
	extract_data_from "$LIBPNG"
	mkdir --parents "${PKG_BIN_PATH}${PATH_GAME}/$dir"
	mv "$PLAYIT_WORKDIR/gamedata"/* "${PKG_BIN_PATH}${PATH_GAME}/$dir"
	APP_MAIN_LIBS="$dir"
	rm --recursive "$PLAYIT_WORKDIR/gamedata"
fi

# Write launchers

PKG='PKG_BIN'
write_launcher 'APP_MAIN'
chmod 755 "${PKG_BIN_PATH}${PATH_GAME}/bin"/*

# Build package

postinst_icons_linking 'APP_MAIN'
write_metadata 'PKG_DATA'

cat > "$postinst" << EOF
if [ ! -e "$PATH_GAME/libs/libpng12.so.0" ]; then
	ln --symbolic ./libpng12.so.0.50.0 "$PATH_GAME/libs/libpng12.so.0"
fi
EOF

cat > "$prerm" << EOF
if [ -e "$PATH_GAME/libs/libpng12.so.0" ]; then
	rm "$PATH_GAME/libs/libpng12.so.0"
fi
EOF

write_metadata 'PKG_BIN'

build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
