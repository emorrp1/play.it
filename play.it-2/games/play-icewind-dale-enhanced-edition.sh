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
# Icewind Dale - Enhanced Edition
# build native Linux packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20170815.1

# Set game-specific variables

GAME_ID='icewind-dale-enhanced-edition'
GAME_NAME='Icewind Dale - Enhanced Edition'

ARCHIVES_LIST='ARCHIVE_GOG'

ARCHIVE_GOG='gog_icewind_dale_enhanced_edition_2.1.0.5.sh'
ARCHIVE_GOG_MD5='fc7244f4793eec365b8ac41d91a4edbb'
ARCHIVE_GOG_SIZE='2900000'
ARCHIVE_GOG_VERSION='1.4.0-gog2.1.0.5'

ARCHIVE_LIBSSL='libssl_1.0.0_32-bit.tar.gz'
ARCHIVE_LIBSSL_MD5='9443cad4a640b2512920495eaf7582c4'

ARCHIVE_ICONS='icewind-dale-enhanced-edition_icons.tar.gz'
ARCHIVE_ICONS_MD5='afe7a2a8013a859f7b56a3104eacd783'

ARCHIVE_DOC_PATH='data/noarch/docs'
ARCHIVE_DOC_FILES='./*'

ARCHIVE_GAME_BIN_PATH='data/noarch/game'
ARCHIVE_GAME_BIN_FILES='./IcewindDale'

ARCHIVE_GAME_L10N_PATH='data/noarch/game'
ARCHIVE_GAME_L10N_FILES='./lang'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='./data ./movies ./music ./scripts ./chitin.key'

ARCHIVE_ICONS_PATH='.'
ARCHIVE_ICONS_FILES='./16x16 ./32x32 ./48x48 ./64x64 ./128x128 ./256x256'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='IcewindDale'
APP_MAIN_ICON_GOG='data/noarch/support/icon.png'
APP_MAIN_ICON_GOG_RES='256'

PACKAGES_LIST='PKG_L10N PKG_DATA PKG_BIN'

PKG_L10N_ID="${GAME_ID}-l10n"
PKG_L10N_DESCRIPTION='localizations'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS_DEB="$PKG_L10N_ID, $PKG_DATA_ID, libc6, libstdc++6, libgl1-mesa-glx | libgl1, libjson-c3 | libjson-c2, libopenal1"
PKG_BIN_DEPS_ARCH="$PKG_L10N_ID $PKG_DATA_ID lib32-libgl lib32-openal lib32-json-c"

# Load common functions

target_version='2.0'

if [ -z "$PLAYIT_LIB2" ]; then
	[ -n "$XDG_DATA_HOME" ] || XDG_DATA_HOME="$HOME/.local/share"
	if [ -e "$XDG_DATA_HOME/play.it/libplayit2.sh" ]; then
		PLAYIT_LIB2="$XDG_DATA_HOME/play.it/libplayit2.sh"
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

# Use libSSL 1.0.0 32-bit archive

ARCHIVE_MAIN="$ARCHIVE"
set_archive 'LIBSSL' 'ARCHIVE_LIBSSL'
ARCHIVE="$ARCHIVE_MAIN"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
if [ "$ICONS_PACK" ]; then
	(
		ARCHIVE='ICONS_PACK'
		extract_data_from "$ICONS_PACK"
	)
fi

PKG='PKG_BIN'
organize_data 'GAME_BIN' "$PATH_GAME"

PKG='PKG_L10N'
organize_data 'GAME_L10N' "$PATH_GAME"

PKG='PKG_DATA'
organize_data 'DOC'       "$PATH_DOC"
organize_data 'GAME_DATA' "$PATH_GAME"

if [ "$ICONS_PACK" ]; then
	organize_data 'ICONS' "$PATH_ICON_BASE"
else
	res="$APP_MAIN_ICON_GOG_RES"
	PATH_ICON="$PATH_ICON_BASE/${res}x${res}/apps"
	mkdir --parents "$PKG_DATA_PATH/$PATH_ICON"
	mv "$PLAYIT_WORKDIR/gamedata/$APP_MAIN_ICON_GOG" "$PKG_DATA_PATH/$PATH_ICON/$GAME_ID.png"
fi

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Include libSSL into the game directory

if [ "$LIBSSL" ]; then
	dir='libs'
	ARCHIVE='LIBSSL'
	extract_data_from "$LIBSSL"
	mkdir --parents "${PKG_BIN_PATH}${PATH_GAME}/$dir"
	mv "$PLAYIT_WORKDIR/gamedata"/* "${PKG_BIN_PATH}${PATH_GAME}/$dir"
	APP_MAIN_LIBS="$dir"
	rm --recursive "$PLAYIT_WORKDIR/gamedata"
fi

# Write launchers

PKG='PKG_BIN'
write_launcher 'APP_MAIN'

# Build package

cat > "$postinst" << EOF
if [ ! -e /lib/i386-linux-gnu/libjson.so.0 ] && [ -e /lib/i386-linux-gnu/libjson-c.so ] ; then
	ln --symbolic libjson-c.so /lib/i386-linux-gnu/libjson.so.0
elif [ ! -e /lib/i386-linux-gnu/libjson.so.0 ] && [ -e /lib/i386-linux-gnu/libjson-c.so.2 ] ; then
	ln --symbolic libjson-c.so.2 /lib/i386-linux-gnu/libjson.so.0
elif [ ! -e /lib/i386-linux-gnu/libjson.so.0 ] && [ -e /lib/i386-linux-gnu/libjson-c.so.3 ] ; then
	ln --symbolic libjson-c.so.3 /lib/i386-linux-gnu/libjson.so.0
elif [ ! -e /usr/lib32/libjson.so.0 ] && [ -e /usr/lib32/libjson-c.so ] ; then
	ln --symbolic libjson-c.so /usr/lib32/libjson.so.0
fi
EOF

write_metadata 'PKG_BIN'
rm "$postinst"
write_metadata 'PKG_L10N' 'PKG_DATA'
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
