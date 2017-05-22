# put files from archive in the right package directories
# USAGE: organize_data $id $path
# NEEDED VARS: $PKG, $PKG_PATH, $PLAYIT_WORKDIR
organize_data() {
	local archive_path="$(eval echo \"\$ARCHIVE_${1}_PATH\")"
	if [ -z "$archive_path" ]; then
		archive_path="$(eval echo \"\$ARCHIVE_${1}_PATH_${ARCHIVE#ARCHIVE_}\")"
	fi
	local archive_files="$(eval echo \"\$ARCHIVE_${1}_FILES\")"
	if [ -z "$archive_files" ]; then
		archive_files="$(eval echo \"\$ARCHIVE_${1}_FILES_${ARCHIVE#ARCHIVE_}\")"
	fi
	if [ "$archive_path" ] && [ -e "$PLAYIT_WORKDIR/gamedata/$archive_path" ]; then
		local pkg_path="$(eval echo \$${PKG}_PATH)${2}"
		mkdir --parents "$pkg_path"
		(
			cd "$PLAYIT_WORKDIR/gamedata/$archive_path"
			for file in $archive_files; do
				if [ -e "$file" ]; then
					cp --recursive --force --link --parents "$file" "$pkg_path"
					rm --recursive "$file"
				fi
			done
		)
	fi
}
