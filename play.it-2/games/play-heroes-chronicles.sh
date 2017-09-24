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
# Heroes Chronicles
# build native Linux packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20170924.1

# Set game-specific variables

GAME_ID='heroes-chronicles'
GAME_NAME='Heroes Chronicles'

ARCHIVES_LIST='ARCHIVE_GOG_1 ARCHIVE_GOG_2 ARCHIVE_GOG_3 ARCHIVE_GOG_4 ARCHIVE_GOG_5 ARCHIVE_GOG_6 ARCHIVE_GOG_7 ARCHIVE_GOG_8'

ARCHIVE_GOG_1='setup_heroes_chronicles_chapter1_2.1.0.42.exe'
ARCHIVE_GOG_1_MD5='f584d6e11ed47d1d40e973a691adca5d'
ARCHIVE_GOG_1_VERSION='1.0-gog2.1.0.42'
ARCHIVE_GOG_1_SIZE='500000'

ARCHIVE_GOG_2='setup_heroes_chronicles_chapter2_2.1.0.43.exe'
ARCHIVE_GOG_2_MD5='0d240bc0309814ba251c2d9b557cf69f'
ARCHIVE_GOG_2_VERSION='1.0-gog2.1.0.42'
ARCHIVE_GOG_2_SIZE='510000'

ARCHIVE_GOG_3='setup_heroes_chronicles_chapter3_2.1.0.41.exe'
ARCHIVE_GOG_3_MD5='cb21751572960d47a259efc17b92c88c'
ARCHIVE_GOG_3_VERSION='1.0-gog2.1.0.42'
ARCHIVE_GOG_3_SIZE='490000'

ARCHIVE_GOG_4='setup_heroes_chronicles_chapter4_2.1.0.42.exe'
ARCHIVE_GOG_4_MD5='922291e16176cb4bd37ca88eb5f3a19e'
ARCHIVE_GOG_4_VERSION='1.0-gog2.1.0.42'
ARCHIVE_GOG_4_SIZE='490000'

ARCHIVE_GOG_5='setup_heroes_chronicles_chapter5_2.1.0.42.exe'
ARCHIVE_GOG_5_MD5='57b3ec588e627a2da30d3bc80ede5b1d'
ARCHIVE_GOG_5_VERSION='1.0-gog2.1.0.42'
ARCHIVE_GOG_5_SIZE='470000'

ARCHIVE_GOG_6='setup_heroes_chronicles_chapter6_2.1.0.42.exe'
ARCHIVE_GOG_6_MD5='64becfde1882eecd93fb02bf215eff11'
ARCHIVE_GOG_6_VERSION='1.0-gog2.1.0.42'
ARCHIVE_GOG_6_SIZE='470000'

ARCHIVE_GOG_7='setup_heroes_chronicles_chapter7_2.1.0.42.exe'
ARCHIVE_GOG_7_MD5='07c189a731886b2d3891ac1c65581d40'
ARCHIVE_GOG_7_VERSION='1.0-gog2.1.0.42'
ARCHIVE_GOG_7_SIZE='500000'

ARCHIVE_GOG_8='setup_heroes_chronicles_chapter8_2.1.0.42.exe'
ARCHIVE_GOG_8_MD5='2b3e4c366db0f7e3e8b15b0935aad528'
ARCHIVE_GOG_8_VERSION='1.0-gog2.1.0.42'
ARCHIVE_GOG_8_SIZE='480000'

ARCHIVE_DOC_DATA_PATH_GOG_1='app/warlords of the wasteland'
ARCHIVE_DOC_DATA_PATH_GOG_2='app/conquest of the underworld'
ARCHIVE_DOC_DATA_PATH_GOG_3='app/masters of the elements'
ARCHIVE_DOC_DATA_PATH_GOG_4='app/clash of the dragons'
ARCHIVE_DOC_DATA_PATH_GOG_5='app/the world tree'
ARCHIVE_DOC_DATA_PATH_GOG_6='app/the fiery moon'
ARCHIVE_DOC_DATA_PATH_GOG_7='app/revolt of the beastmasters'
ARCHIVE_DOC_DATA_PATH_GOG_8='app/the sword of frost'
ARCHIVE_DOC_DATA_FILES='./*.pdf ./*.txt'

ARCHIVE_DOC_COMMON_PATH='tmp'
ARCHIVE_DOC_COMMON_FILES='./*.txt'

ARCHIVE_GAME_BIN_PATH='app'
ARCHIVE_GAME_BIN_FILES='./*/*.asi ./*/*.exe ./*/binkw32.dll ./*/ifc20.dll ./*/mcp.dll ./*/mss32.dll ./*/smackw32.dll'

ARCHIVE_GAME_DATA_PATH='app'
ARCHIVE_GAME_DATA_FILES='./*/data ./*/maps'

ARCHIVE_GAME_COMMON_PATH='app'
ARCHIVE_GAME_COMMON_FILES='./data ./mp3'

DATA_DIRS='./*/games ./*/maps'
DATA_FILES='./data/*.lod ./*/data/*.lod'

APP_WINETRICKS='vd=800x600'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE_GOG_1='warlords of the wasteland/warlords.exe'
APP_MAIN_EXE_GOG_2='conquest of the underworld/underworld.exe'
APP_MAIN_EXE_GOG_3='masters of the elements/elements.exe'
APP_MAIN_EXE_GOG_4='clash of the dragons/dragons.exe'
APP_MAIN_EXE_GOG_5='the world tree/worldtree.exe'
APP_MAIN_EXE_GOG_6='the fiery moon/fierymoon.exe'
APP_MAIN_EXE_GOG_7='revolt of the beastmasters/beastmaster.exe'
APP_MAIN_EXE_GOG_8='the sword of frost/sword.exe'
APP_MAIN_ICON_GOG_1="$APP_MAIN_EXE_GOG_1"
APP_MAIN_ICON_GOG_2="$APP_MAIN_EXE_GOG_2"
APP_MAIN_ICON_GOG_3="$APP_MAIN_EXE_GOG_3"
APP_MAIN_ICON_GOG_4="$APP_MAIN_EXE_GOG_4"
APP_MAIN_ICON_GOG_5="$APP_MAIN_EXE_GOG_5"
APP_MAIN_ICON_GOG_6="$APP_MAIN_EXE_GOG_6"
APP_MAIN_ICON_GOG_7="$APP_MAIN_EXE_GOG_7"
APP_MAIN_ICON_GOG_8="$APP_MAIN_EXE_GOG_8"
APP_MAIN_ICON_RES='16 32 48 64'

PACKAGES_LIST='PKG_COMMON PKG_DATA PKG_BIN'

PKG_COMMON_ID="${GAME_ID}-common"
PKG_COMMON_DESCRIPTION='common files'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS_DEB="$PKG_COMMON_ID, $PKG_DATA_ID, wine32-development | wine32 | wine-bin | wine-i386 | wine-staging-i386, wine:amd64 | wine, winetricks"
PKG_BIN_DEPS_ARCH="$PKG_COMMON_ID, $PKG_DATA_ID wine winetricks"

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

# Set GAME_ID, GAME_NAME, APP_EXE and APP_ICON based on archive

GAME_ID_COMMON="$GAME_ID"
GAME_NAME_COMMON="$GAME_NAME"
case "${SOURCE_ARCHIVE##*/}" in
	($ARCHIVE_GOG_1)
		GAME_ID="${GAME_ID}-1"
		GAME_NAME="$GAME_NAME 1 - Warlords of the Wasteland"
		APP_MAIN_EXE="$APP_MAIN_EXE_GOG_1"
		APP_MAIN_ICON="$APP_MAIN_ICON_GOG_1"
	;;
	($ARCHIVE_GOG_2)
		GAME_ID="${GAME_ID}-2"
		GAME_NAME="$GAME_NAME 2 - Conquest of the Underworld"
		APP_MAIN_EXE="$APP_MAIN_EXE_GOG_2"
		APP_MAIN_ICON="$APP_MAIN_ICON_GOG_2"
	;;
	($ARCHIVE_GOG_3)
		GAME_ID="${GAME_ID}-3"
		GAME_NAME="$GAME_NAME 3 - Masters of the Elements"
		APP_MAIN_EXE="$APP_MAIN_EXE_GOG_3"
		APP_MAIN_ICON="$APP_MAIN_ICON_GOG_3"
	;;
	($ARCHIVE_GOG_4)
		GAME_ID="${GAME_ID}-4"
		GAME_NAME="$GAME_NAME 4 - Clash of the Dragons"
		APP_MAIN_EXE="$APP_MAIN_EXE_GOG_4"
		APP_MAIN_ICON="$APP_MAIN_ICON_GOG_4"
	;;
	($ARCHIVE_GOG_5)
		GAME_ID="${GAME_ID}-5"
		GAME_NAME="$GAME_NAME 5 - The World Tree"
		APP_MAIN_EXE="$APP_MAIN_EXE_GOG_5"
		APP_MAIN_ICON="$APP_MAIN_ICON_GOG_5"
	;;
	($ARCHIVE_GOG_6)
		GAME_ID="${GAME_ID}-6"
		GAME_NAME="$GAME_NAME 6 - The Fiery Moon"
		APP_MAIN_EXE="$APP_MAIN_EXE_GOG_6"
		APP_MAIN_ICON="$APP_MAIN_ICON_GOG_6"
	;;
	($ARCHIVE_GOG_7)
		GAME_ID="${GAME_ID}-7"
		GAME_NAME="$GAME_NAME 7 - Revolt of the Beastmasters"
		APP_MAIN_EXE="$APP_MAIN_EXE_GOG_7"
		APP_MAIN_ICON="$APP_MAIN_ICON_GOG_7"
	;;
	($ARCHIVE_GOG_8)
		GAME_ID="${GAME_ID}-8"
		GAME_NAME="$GAME_NAME 8 - The Sword of Frost"
		APP_MAIN_EXE="$APP_MAIN_EXE_GOG_8"
		APP_MAIN_ICON="$APP_MAIN_ICON_GOG_8"
	;;
esac

# Update PKG_ID based on new GAME_ID value

PKG_BIN_ID="$GAME_ID"
PKG_DATA_ID="${GAME_ID}-data"
PKG_BIN_DEPS_DEB="$PKG_COMMON_ID, $PKG_DATA_ID, wine32-development | wine32 | wine-bin | wine-i386 | wine-staging-i386, wine:amd64 | wine, winetricks"
PKG_BIN_DEPS_ARCH="$PKG_COMMON_ID $PKG_DATA_ID wine winetricks"

# Update PATH_DOC and PATH_GAME based on new GAME_ID value

case $OPTION_PACKAGE in
	('arch')
		PATH_DOC="$OPTION_PREFIX/share/doc/$GAME_ID"
		PATH_GAME="$OPTION_PREFIX/share/$GAME_ID"
	;;
	('deb')
		PATH_DOC="$OPTION_PREFIX/share/doc/$GAME_ID"
		PATH_GAME="$OPTION_PREFIX/share/games/$GAME_ID"
	;;
	(*)
		liberror 'OPTION_PACKAGE' "$0"
	;;
esac
set_temp_directories $PACKAGES_LIST

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"

for PKG in 'PKG_DATA' 'PKG_BIN'; do
	organize_data "DOC_${PKG#PKG_}"  "$PATH_DOC"
	organize_data "GAME_${PKG#PKG_}" "$PATH_GAME"
done

PKG='PKG_COMMON'
organize_data 'DOC_COMMON'  "$(printf "$PATH_DOC"  | sed "s,/$GAME_ID$,/$GAME_ID_COMMON,")"
organize_data 'GAME_COMMON' "$(printf "$PATH_GAME" | sed "s,/$GAME_ID$,/$GAME_ID_COMMON,")"

PKG='PKG_BIN'
extract_and_sort_icons_from 'APP_MAIN'
move_icons_to 'PKG_DATA'

(
	cd "${PKG_DATA_PATH}${PATH_GAME}"/*
	mkdir --parents 'games' 'maps'
)

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

PKG='PKG_BIN'
write_launcher 'APP_MAIN'
file="${PKG_BIN_PATH}${PATH_BIN}/$GAME_ID"
sed --in-place 's,cd "$PATH_PREFIX",cd "$PATH_PREFIX/${APP_EXE%/*}",'                     "$file"
sed --in-place 's,wine "$APP_EXE" $APP_OPTIONS $@,wine "${APP_EXE##*/}" $APP_OPTIONS $@,' "$file"

# Build package

cat > "$postinst" << EOF
for dir in 'data' 'mp3'; do
	if [ ! -e "$PATH_GAME/\$dir" ]; then
		cp --force --recursive --symbolic-link --update "$(printf "$PATH_GAME" | sed "s,/$GAME_ID$,/$GAME_ID_COMMON,")/\$dir" "$PATH_GAME"
	fi
done
EOF
cat > "$prerm" << EOF
for dir in 'data' 'mp3'; do
	if [ -e "$PATH_GAME/\$dir" ]; then
		rm --force --recursive "$PATH_GAME/\$dir"
	fi
done
EOF
write_metadata 'PKG_DATA'
rm "$postinst" "$prerm"
write_metadata 'PKG_BIN'
GAME_NAME="$GAME_NAME_COMMON"
write_metadata 'PKG_COMMON'
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
