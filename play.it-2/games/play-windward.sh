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
# Windward
# build native Linux packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20170824.1

# Set game-specific variables

GAME_ID='windward'
GAME_NAME='Windward'

ARCHIVES_LIST='ARCHIVE_GOG ARCHIVE_HUMBLE ARCHIVE_GOG_OLD ARCHIVE_GOG_OLDER'

ARCHIVE_GOG='gog_windward_2.36.0.40.sh'
ARCHIVE_GOG_MD5='6afbdcfda32a6315139080822c30396a'
ARCHIVE_GOG_SIZE='130000'
ARCHIVE_GOG_VERSION='20170617.0-gog2.36.0.40'

ARCHIVE_GOG_OLD='gog_windward_2.35.0.39.sh'
ARCHIVE_GOG_OLD_MD5='12fffaf6f405f36d2f3a61b4aaab89ba'
ARCHIVE_GOG_OLD_SIZE='130000'
ARCHIVE_GOG_OLD_VERSION='20160707.0-gog2.35.0.39'

ARCHIVE_GOG_OLDER='gog_windward_2.35.0.38.sh'
ARCHIVE_GOG_OLDER_MD5='f5ce09719bf355e48d2eac59b84592d1'
ARCHIVE_GOG_OLDER_SIZE='120000'
ARCHIVE_GOG_OLDER_VERSION='20160707-gog2.35.0.38'

ARCHIVE_HUMBLE='WindwardLinux_HB.zip'
ARCHIVE_HUMBLE_MD5='f2d1a9a91055ecb6c5ce1bd7e3ddd803'
ARCHIVE_HUMBLE_SIZE='130000'
ARCHIVE_HUMBLE_VERSION='20160707-humble1'

ARCHIVE_DOC_PATH_GOG='data/noarch/docs'
ARCHIVE_DOC_FILES='./*'

ARCHIVE_GAME_BIN_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_BIN_PATH_HUMBLE='.'
ARCHIVE_GAME_BIN_FILES='./Windward.x86 ./Windward_Data/Plugins ./Windward_Data/Mono'

ARCHIVE_GAME_DATA_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_DATA_PATH_HUMBLE='.'
ARCHIVE_GAME_DATA_FILES='./Windward_Data'

DATA_DIRS='./logs'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='Windward.x86'
APP_MAIN_OPTIONS='-logFile ./logs/$(date +%F-%R).log'
APP_MAIN_ICONS_LIST='APP_MAIN_ICON'
APP_MAIN_ICON='*_Data/Resources/UnityPlayer.png'
APP_MAIN_ICON_RES='128'

PACKAGES_LIST='PKG_DATA PKG_BIN'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS_DEB="$PKG_DATA_ID, libc6, libstdc++6, libglu1-mesa | libglu1, libxcursor1"
PKG_BIN_DEPS_ARCH="$PKG_DATA_ID lib32-glu lib32-libxcursor lsb-release"

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

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"

PKG='PKG_BIN'
organize_data 'GAME_BIN' "$PATH_GAME"

PKG='PKG_DATA'
organize_data 'DOC'       "$PATH_DOC"
organize_data 'GAME_DATA' "$PATH_GAME"

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

PKG='PKG_BIN'
write_launcher 'APP_MAIN'

# Build package

postinst_icons_linking 'APP_MAIN'
write_metadata 'PKG_DATA'
rm "$postinst" "$prerm"
write_metadata 'PKG_BIN'
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

#print instructions

print_instructions

exit 0
