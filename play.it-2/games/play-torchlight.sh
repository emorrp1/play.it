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
# Torchlight
# build native Linux packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20170902.1

# Set game-specific variables

GAME_ID='torchlight'
GAME_NAME='Torchlight'

ARCHIVES_LIST='ARCHIVE_GOG'

ARCHIVE_GOG='setup_torchlight_2.0.0.12.exe'
ARCHIVE_GOG_MD5='4b721e1b3da90f170d66f42e60a3fece'
ARCHIVE_GOG_VERSION='1.15-gog2.0.0.12'
ARCHIVE_GOG_SIZE='460000'

ARCHIVE_DOC1_DATA_PATH='tmp'
ARCHIVE_DOC1_DATA_FILES='./*.txt'

ARCHIVE_DOC2_DATA_PATH='app'
ARCHIVE_DOC2_DATA_FILES='./*.pdf'

ARCHIVE_GAME_BIN_PATH='app'
ARCHIVE_GAME_BIN_FILES='./torchlight.exe ./ceguibase.dll ./ceguiexpatparser.dll ./ceguifalagardwrbase.dll ./cg.dll ./d3dx9_39.dll ./fmodex.dll ./msvcp90.dll ./msvcr90.dll ./ogreguirenderer.dll ./ogremain.dll ./ois.dll ./particleuniverse.dll ./plugin_cgprogrammanager.dll ./plugin_octreescenemanager.dll ./plugin_particlefx.dll ./referenceapplayer.dll ./rendersystem_direct3d9.dll ./rendersystem_gl.dll ./*.cfg'

ARCHIVE_GAME_DATA_PATH='app'
ARCHIVE_GAME_DATA_FILES='./buildver.txt ./runicgames.ico ./torchlight.ico ./logo.bmp ./pak.zip ./icons ./music ./programs'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='torchlight.exe'
APP_MAIN_ICON='torchlight.ico'
APP_MAIN_ICON_RES='16 24 32 48 256'

PACKAGES_LIST='PKG_DATA PKG_BIN'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ID="$GAME_ID"
PKG_BIN_ARCH='32'
PKG_BIN_DEPS_DEB="$PKG_DATA_ID, wine32-development | wine32 | wine-bin | wine-i386 | wine-staging-i386, wine:amd64 | wine, libxcursor1"
PKG_BIN_DEPS_ARCH="$PKG_DATA_ID wine lib32-libxcursor"

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
		exit 1
	fi
fi
. "$PLAYIT_LIB2"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"

for PKG in $PACKAGES_LIST; do
	organize_data "DOC1_${PKG#PKG_}" "$PATH_DOC"
	organize_data "DOC2_${PKG#PKG_}" "$PATH_DOC"
	organize_data "GAME_${PKG#PKG_}" "$PATH_GAME"
done

PKG='PKG_DATA'
extract_and_sort_icons_from 'APP_MAIN'

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

PKG='PKG_BIN'
write_launcher 'APP_MAIN'

# Store saved games outside of WINE prefix

for file in "${PKG_BIN_PATH}${PATH_BIN}"/*; do
	sed --in-place 's#cp --force --recursive --symbolic-link --update "$PATH_GAME"/\* "$PATH_PREFIX"#&\n\tmkdir --parents "$WINEPREFIX/drive_c/users/$(whoami)/Application Data/runic games/torchlight"\n\tmkdir --parents "$PATH_DATA/save"\n\tln --symbolic "$PATH_DATA/save" "$WINEPREFIX/drive_c/users/$(whoami)/Application Data/runic games/torchlight"#' "$file"
done

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
