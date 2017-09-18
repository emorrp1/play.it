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
# Baldur’s Gate - Enhanced Edition
# build native Linux packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20170918.2

# Set game-specific variables

GAME_ID='baldurs-gate-enhanced-edition'
GAME_NAME='Baldur’s Gate - Enhanced Edition'

ARCHIVES_LIST='ARCHIVE_GOG ARCHIVE_GOG_OLD'

ARCHIVE_GOG='gog_baldur_s_gate_enhanced_edition_2.5.0.9.sh'
ARCHIVE_GOG_MD5='224be273fd2ec1eb0246f407dda16bc4'
ARCHIVE_GOG_SIZE='3200000'
ARCHIVE_GOG_VERSION='2.3.67.3-gog2.5.0.9'

ARCHIVE_GOG_OLD='gog_baldur_s_gate_enhanced_edition_2.5.0.7.sh'
ARCHIVE_GOG_OLD_MD5='37ece59534ca63a06f4c047d64b82df9'
ARCHIVE_GOG_OLD_SIZE='3200000'
ARCHIVE_GOG_OLD_VERSION='2.3.67.3-gog2.5.0.7'

ARCHIVE_LIBSSL='libssl_1.0.0_32-bit.tar.gz'
ARCHIVE_LIBSSL_MD5='9443cad4a640b2512920495eaf7582c4'

ARCHIVE_DOC_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC_DATA_FILES='./*'

ARCHIVE_GAME_BIN_PATH='data/noarch/game'
ARCHIVE_GAME_BIN_FILES='./BaldursGate ./engine.lua'

ARCHIVE_GAME_AREAS_PATH='data/noarch/game'
ARCHIVE_GAME_AREAS_FILES='./data/AR*'

ARCHIVE_GAME_L10N_PATH='data/noarch/game'
ARCHIVE_GAME_L10N_FILES='./lang'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='./movies ./music ./chitin.key ./Manuals ./scripts ./data/25* ./data/C* ./data/D* ./data/E* ./data/G* ./data/H* ./data/I* ./data/L* ./data/M* ./data/N* ./data/O* ./data/P* ./data/S* ./data/T* ./data/v*'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='BaldursGate'
APP_MAIN_ICON='data/noarch/support/icon.png'
APP_MAIN_ICON_RES='256'

PACKAGES_LIST='PKG_AREAS PKG_L10N PKG_DATA PKG_BIN'

PKG_AREAS_ID="${GAME_ID}-areas"
PKG_AREAS_DESCRIPTION='areas'

PKG_L10N_ID="${GAME_ID}-l10n"
PKG_L10N_DESCRIPTION='localizations'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS_DEB="$PKG_AREAS_ID, $PKG_L10N_ID, $PKG_DATA_ID, libc6, libstdc++6, libgl1-mesa-glx | libgl1, libjson0, libopenal1"
PKG_BIN_DEPS_ARCH="$PKG_AREAS_ID $PKG_L10N_ID $PKG_DATA_ID lib32-glibc lib32-gcc-libs lib32-libgl lib32-json-c lib32-openal"

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

# Use libSSL 1.0.0 32-bit archive

set_archive 'LIBSSL' 'ARCHIVE_LIBSSL'
ARCHIVE='ARCHIVE_GOG'

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"

for PKG in $PACKAGES_LIST; do
	organize_data "DOC_${PKG#PKG_}"  "$PATH_GAME"
	organize_data "GAME_${PKG#PKG_}" "$PATH_GAME"
done

res="$APP_MAIN_ICON_RES"
PATH_ICON="$PATH_ICON_BASE/${res}x${res}/apps"
mkdir --parents "$PKG_DATA_PATH/$PATH_ICON"
mv "$PLAYIT_WORKDIR/gamedata/$APP_MAIN_ICON" "$PKG_DATA_PATH/$PATH_ICON/$GAME_ID.png"

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
if [ ! -e /usr/lib32/libjson.so.0 ] && [ -e /usr/lib32/libjson-c.so ] ; then
	ln --symbolic libjson-c.so /usr/lib32/libjson.so.0
fi
EOF

write_metadata 'PKG_BIN'
rm "$postinst"
write_metadata 'PKG_AREAS' 'PKG_L10N' 'PKG_DATA'
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
