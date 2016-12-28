#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2016, Antoine Le Gonidec
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
# Heroes of Might and Magic III
# build native Linux packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20161227.1

# Set game-specific variables

GAME_ID='heroes-of-might-and-magic-3'
GAME_NAME='Heroes of Might and Magic III'

ARCHIVE_GOG_EN='setup_homm3_complete_2.0.0.16.exe'
ARCHIVE_GOG_EN_MD5='263d58f8cc026dd861e9bbcadecba318'
ARCHIVE_GOG_EN_PATCH='patch_heroes_of_might_and_magic_3_complete_2.0.1.17.exe'
ARCHIVE_GOG_EN_PATCH_MD5='815b9c097cd57d0e269beb4cc718dad3'
ARCHIVE_GOG_EN_PATCH_VERSION='3.0-gog2.0.1.17'
ARCHIVE_GOG_EN_UNCOMPRESSED_SIZE='1100000'

ARCHIVE_GOG_FR='setup_homm3_complete_french_2.1.0.20.exe'
ARCHIVE_GOG_FR_MD5='ca8e4726acd7b5bc13c782d59c5a459b'
ARCHIVE_GOG_FR_VERSION='3.0-gog2.1.0.20'
ARCHIVE_GOG_FR_UNCOMPRESSED_SIZE='1100000'

ARCHIVE_DOC1_PATH='tmp'
ARCHIVE_DOC1_FILES='./*eula.txt'
ARCHIVE_DOC2_PATH='app'
ARCHIVE_DOC2_FILES='./eula ./*.cnt ./*.hlp ./*.pdf ./*.txt'
ARCHIVE_GAME_BIN_PATH='app'
ARCHIVE_GAME_BIN_FILES='./binkw32.dll ./h3ccmped.exe ./h3maped.exe ./heroes3.exe ./ifc20.dll ./ifc21.dll ./mcp.dll ./mp3dec.asi ./mss32.dll ./smackw32.dll'
ARCHIVE_GAME_DATA_PATH='app'
ARCHIVE_GAME_DATA_FILES='./data ./maps'
ARCHIVE_GAME_MUSIC_PATH='app'
ARCHIVE_GAME_MUSIC_FILES='./mp3'
ARCHIVE_GAME_PATCH_PATH='tmp'
ARCHIVE_GAME_PATCH_FILES='./heroes3.exe'

CONFIG_DIRS='./config'
DATA_DIRS='./games ./maps ./random_maps'
DATA_FILES='data/h3ab_bmp.lod data/h3ab_spr.lod data/h3bitmap.lod data/h3sprite.lod'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='./heroes3.exe'
APP_MAIN_ICON='./heroes3.exe'
APP_MAIN_ICON_RES='16x16 32x32 48x48 64x64'

APP_EDITOR_MAP_TYPE='wine'
APP_EDITOR_MAP_ID="${GAME_ID}_map-editor"
APP_EDITOR_MAP_EXE='./h3maped.exe'
APP_EDITOR_MAP_ICON='./h3maped.exe'
APP_EDITOR_MAP_ICON_RES='16x16 32x32 48x48 64x64'
APP_EDITOR_MAP_NAME="$GAME_NAME - map editor"

APP_EDITOR_CAMPAIGN_TYPE='wine'
APP_EDITOR_CAMPAIGN_ID="${GAME_ID}_campaign-editor"
APP_EDITOR_CAMPAIGN_EXE='./h3ccmped.exe'
APP_EDITOR_CAMPAIGN_ICON='./h3ccmped.exe'
APP_EDITOR_CAMPAIGN_ICON_RES='16x16 32x32 48x48 64x64'
APP_EDITOR_CAMPAIGN_NAME="$GAME_NAME - campaign editor"

PKG_MUSIC_ID="${GAME_ID}-music"
PKG_MUSIC_ARCH_DEB='all'
PKG_MUSIC_ARCH_ARCH='any'
PKG_MUSIC_DESC_DEB="$GAME_NAME - music\n
 ./play.it script version $script_version"
PKG_MUSIC_DESC_ARCH="$GAME_NAME - music - ./play.it script version $script_version"

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_ARCH_DEB='all'
PKG_DATA_ARCH_ARCH='any'
PKG_DATA_DESC_DEB="$GAME_NAME - data\n
 ./play.it script version $script_version"
PKG_DATA_DESC_ARCH="$GAME_NAME - data - ./play.it script version $script_version"

PKG_BIN_ARCH_DEB='i386'
PKG_BIN_ARCH_ARCH='any'
PKG_BIN_DEPS_DEB="$PKG_DATA_ID, $PKG_MUSIC_ID, winetricks, wine:amd64 | wine, wine32 | wine-bin | wine1.6-i386 | wine1.4-i386 | wine-staging-i386"
PKG_BIN_DEPS_ARCH="$PKG_DATA_ID $PKG_MUSIC_ID winetricks wine"
PKG_BIN_DESC_DEB="$GAME_NAME\n
 ./play.it script version $script_version"
PKG_BIN_DESC_ARCH="$GAME_NAME - ./play.it script version $script_version"

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

if [ ${library_version%.*} -ne ${target_version%.*} ] || [ ${library_version#*.} -lt ${target_version#*.} ]; then
	printf '\n\033[1;31mError:\033[0m\n'
	printf 'wrong version of libplayit2.sh\n'
	printf 'target version is: %s\n' "$target_version"
	return 1
fi

# Set extra variables

set_common_defaults
fetch_args "$@"

# Set source archive

set_source_archive 'ARCHIVE_GOG_EN' 'ARCHIVE_GOG_FR'
if [ "${SOURCE_ARCHIVE##*/}" = "$ARCHIVE_GOG_EN" ]; then
	MAIN_ARCHIVE="$SOURCE_ARCHIVE"
	unset SOURCE_ARCHIVE
	set_source_archive 'ARCHIVE_GOG_EN_PATCH'
	PATCH_ARCHIVE="$SOURCE_ARCHIVE"
	SOURCE_ARCHIVE="$MAIN_ARCHIVE"
	unset ARCHIVE
fi
check_deps
set_common_paths
file_checksum "$SOURCE_ARCHIVE" 'ARCHIVE_GOG_EN' 'ARCHIVE_GOG_FR'
if [ "${SOURCE_ARCHIVE##*/}" = "$ARCHIVE_GOG_EN" ]; then
	unset ARCHIVE
	file_checksum "$PATCH_ARCHIVE" 'ARCHIVE_GOG_EN_PATCH'
	ARCHIVE='ARCHIVE_GOG_EN'
fi
check_deps

# Extract game data

set_workdir 'PKG_BIN' 'PKG_MUSIC' 'PKG_DATA'
extract_data_from "$SOURCE_ARCHIVE"
if [ "${SOURCE_ARCHIVE##*/}" = "$ARCHIVE_GOG_EN" ]; then
	extract_data_from "$PATCH_ARCHIVE"
fi

PKG='PKG_BIN'
organize_data_generic 'GAME_BIN'   "$PATH_GAME"
organize_data_generic 'GAME_PATCH' "$PATH_GAME"

PKG='PKG_MUSIC'
organize_data_generic 'GAME_MUSIC' "$PATH_GAME"

PKG='PKG_DATA'
organize_data_generic 'DOC1'      "$PATH_DOC"
organize_data_generic 'DOC2'      "$PATH_DOC"
organize_data_generic 'GAME_DATA' "$PATH_GAME"

if [ "$NO_ICON" = '0' ]; then
	(
		cd "${PKG_BIN_PATH}${PATH_GAME}"

		extract_icon_from "$APP_MAIN_ICON"
		extract_icon_from "$PLAYIT_WORKDIR/icons"/*.ico
		sort_icons 'APP_MAIN'
		rm --recursive "$PLAYIT_WORKDIR/icons"

		extract_icon_from "$APP_EDITOR_MAP_ICON"
		extract_icon_from "$PLAYIT_WORKDIR/icons"/*.ico
		sort_icons 'APP_EDITOR_MAP'
		rm --recursive "$PLAYIT_WORKDIR/icons"

		extract_icon_from "$APP_EDITOR_CAMPAIGN_ICON"
		extract_icon_from "$PLAYIT_WORKDIR/icons"/*.ico
		sort_icons 'APP_EDITOR_CAMPAIGN'
		rm --recursive "$PLAYIT_WORKDIR/icons"
	)
fi

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

PKG='PKG_BIN'
write_bin     'APP_MAIN' 'APP_EDITOR_MAP' 'APP_EDITOR_CAMPAIGN'
write_desktop 'APP_MAIN' 'APP_EDITOR_MAP' 'APP_EDITOR_CAMPAIGN'

for file in "${PKG_BIN_PATH}${PATH_BIN}"/*; do
	sed -i 's|\trm "${WINEPREFIX}/dosdevices/z:"|&\n\twinetricks vd=800x600|' "$file"
done

# Build package

write_metadata 'PKG_BIN' 'PKG_MUSIC' 'PKG_DATA'
build_pkg      'PKG_BIN' 'PKG_MUSIC' 'PKG_DATA'

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions "$PKG_MUSIC_PKG" "$PKG_DATA_PKG" "$PKG_BIN_PKG"

exit 0