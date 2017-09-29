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
# Anno 1404: Gold Edition
# build native Linux packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20170928.1

# Set game-specific variables

GAME_ID='anno-1404'
GAME_NAME='Anno 1404'

ARCHIVES_LIST='ARCHIVE_GOG'

ARCHIVE_GOG='setup_anno_1404_gold_edition_2.01.5010_(13111).exe'
ARCHIVE_GOG_MD5='b19333f57c1c15b788e29ff6751dac20'
ARCHIVE_GOG_VERSION='2.01.5010-gog13111'
ARCHIVE_GOG_SIZE='6200000'
ARCHIVE_GOG_PART1='setup_anno_1404_gold_edition_2.01.5010_(13111)-1.bin'
ARCHIVE_GOG_PART1_MD5='17933b44bdb2a26d8d82ffbfdc494210'
ARCHIVE_GOG_PART1_TYPE='innosetup'
ARCHIVE_GOG_PART2='setup_anno_1404_gold_edition_2.01.5010_(13111)-2.bin'
ARCHIVE_GOG_PART2_MD5='2f71f5378b5f27a84a41cc481a482bd6'
ARCHIVE_GOG_PART2_TYPE='innosetup'

ARCHIVE_DOC_DATA_PATH='app'
ARCHIVE_DOC_DATA_FILES='./*.pdf'

ARCHIVE_GAME_BIN_PATH='app'
ARCHIVE_GAME_BIN_FILES='./*.exe ./*.dll ./bin ./tools'

ARCHIVE_GAME_DATA_PATH='app'
ARCHIVE_GAME_DATA_FILES='./addon ./data ./maindata ./resources'

CONFIG_FILES='./*.ini'

APP_WINETRICKS='d3dx9_36'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='anno4.exe'
APP_MAIN_ICON='anno4.exe'
APP_MAIN_ICON_RES='16 24 32 48 64 128 256'

APP_VENICE_ID="${GAME_ID}_venice"
APP_VENICE_TYPE='wine'
APP_VENICE_EXE='addon.exe'
APP_VENICE_ICON='addon.exe'
APP_VENICE_ICON_RES='16 24 32 48 64 128 256'
APP_VENICE_NAME="$GAME_NAME - Venice"

APP_L10N_ID="${GAME_ID}_l10n"
APP_L10N_TYPE='wine'
APP_L10N_EXE='language_selector.exe'
APP_L10N_ICON='language_selector.exe'
APP_L10N_ICON_RES='16 32 48'
APP_L10N_NAME="$GAME_NAME - language selector"
APP_L10N_CAT='Settings'

PACKAGES_LIST='PKG_DATA PKG_BIN'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS_DEB="$PKG_DATA_ID, winetricks, wine32-development | wine32 | wine-bin | wine-i386 | wine-staging-i386, wine:amd64 | wine"
PKG_BIN_DEPS_ARCH="$PKG_DATA_ID winetricks wine"

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

# Check that all parts of the installer are present

set_archive 'ARCHIVE_PART1' 'ARCHIVE_GOG_PART1'
[ "$ARCHIVE_PART1" ] || set_archive_error_not_found 'ARCHIVE_GOG_PART1'
set_archive 'ARCHIVE_PART2' 'ARCHIVE_GOG_PART2'
[ "$ARCHIVE_PART2" ] || set_archive_error_not_found 'ARCHIVE_GOG_PART2'
ARCHIVE='ARCHIVE_GOG'

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
set_standard_permissions "$PLAYIT_WORKDIR/gamedata"

for PKG in $PACKAGES_LIST; do
	organize_data "DOC_${PKG#PKG_}"   "$PATH_DOC"
	organize_data "GAME_${PKG#PKG_}"  "$PATH_GAME"
done

PKG='PKG_BIN'
extract_and_sort_icons_from 'APP_MAIN' 'APP_VENICE' 'APP_L10N'
move_icons_to 'PKG_DATA'

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

PKG='PKG_BIN'
write_launcher 'APP_MAIN' 'APP_VENICE' 'APP_L10N'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
