# put files from archive in the right package directories
# USAGE: organize_data $id $path
# NEEDED VARS: (LANG) PLAYIT_WORKDIR (PKG) PKG_PATH
organize_data() {
	if [ -z "$PKG" ]; then
		organize_data_error_missing_pkg
	fi
	local archive_path
	if [ -n "$(eval printf -- '%b' \"\$ARCHIVE_${1}_PATH_${ARCHIVE#ARCHIVE_}\")" ]; then
		archive_path="$(eval printf -- '%b' \"\$ARCHIVE_${1}_PATH_${ARCHIVE#ARCHIVE_}\")"
	elif [ -n "$(eval printf -- '%b' \"\$ARCHIVE_${1}_PATH\")" ]; then
		archive_path="$(eval printf -- '%b' \"\$ARCHIVE_${1}_PATH\")"
	else
		unset archive_path
	fi

	local archive_files
	if [ -n "$(eval printf -- '%b' \"\$ARCHIVE_${1}_FILES_${ARCHIVE#ARCHIVE_}\")" ]; then
		archive_files="$(eval printf -- '%b' \"\$ARCHIVE_${1}_FILES_${ARCHIVE#ARCHIVE_}\")"
	elif [ -n "$(eval printf -- '%b' \"\$ARCHIVE_${1}_FILES\")" ]; then
		archive_files="$(eval printf -- '%b' \"\$ARCHIVE_${1}_FILES\")"
	else
		unset archive_files
	fi

	if [ "$archive_path" ] && [ "$archive_files" ] && [ -d "$PLAYIT_WORKDIR/gamedata/$archive_path" ]; then
		local pkg_path="$(eval printf -- '%b' \"\$${PKG}_PATH\")${2}"
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

# display an error when calling organize_data() with $PKG unset or empty
# USAGE: organize_data_error_missing_pkg
# NEEDED VARS: (LANG)
organize_data_error_missing_pkg() {
	print_error
	case "${LANG%_*}" in
		('fr')
			string='organize_data ne peut pas être appelé si $PKG n’est pas défini.\n'
		;;
		('en'|*)
			string='organize_data can not be called if $PKG is not set.\n'
		;;
	esac
	printf "$string"
	return 1
}

