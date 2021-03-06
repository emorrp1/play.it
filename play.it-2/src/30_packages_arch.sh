# write .pkg.tar package meta-data
# USAGE: pkg_write_arch
# NEEDED VARS: GAME_NAME PKG_DEPS_ARCH
# CALLED BY: write_metadata
pkg_write_arch() {
	local pkg_deps
	if [ "$(eval printf -- '%b' \"\$${pkg}_DEPS_ARCH_${ARCHIVE#ARCHIVE_}\")" ]; then
		pkg_deps="$(eval printf -- '%b' \"\$${pkg}_DEPS_ARCH_${ARCHIVE#ARCHIVE_}\")"
	else
		pkg_deps="$(eval printf -- '%b' \"\$${pkg}_DEPS_ARCH\")"
	fi
	local pkg_size=$(du --total --block-size=1 --summarize "$pkg_path" | tail --lines=1 | cut --fields=1)
	local target="$pkg_path/.PKGINFO"

	mkdir --parents "${target%/*}"

	cat > "$target" <<- EOF
	pkgname = $pkg_id
	pkgver = $pkg_version
	packager = $pkg_maint
	builddate = $(date +"%m%d%Y")
	size = $pkg_size
	arch = $pkg_architecture
	EOF

	if [ "$pkg_description" ]; then
		cat >> "$target" <<- EOF
		pkgdesc = $GAME_NAME - $pkg_description - ./play.it script version $script_version
		EOF
	else
		cat >> "$target" <<- EOF
		pkgdesc = $GAME_NAME - ./play.it script version $script_version
		EOF
	fi

	for dep in $pkg_deps; do
		cat >> "$target" <<- EOF
		depend = $dep
		EOF
	done

	if [ $pkg_provide ]; then
		cat >> "$target" <<- EOF
		conflict = $pkg_provide
		provides = $pkg_provide
		EOF
	fi

	target="$pkg_path/.INSTALL"

	if [ -e "$postinst" ]; then
		cat >> "$target" <<- EOF
		post_install() {
		$(cat "$postinst")
		}

		post_upgrade() {
		post_install
		}
		EOF
	fi

	if [ -e "$prerm" ]; then
		cat >> "$target" <<- EOF
		pre_remove() {
		$(cat "$prerm")
		}

		pre_upgrade() {
		pre_remove
		}
		EOF
	fi
}

# build .pkg.tar package
# USAGE: pkg_build_arch $pkg_path
# NEEDED VARS: (OPTION_COMPRESSION) (LANG) PLAYIT_WORKDIR
# CALLS: pkg_print
# CALLED BY: build_pkg
pkg_build_arch() {
	local pkg_filename="$PWD/${1##*/}.pkg.tar"
	local tar_options='--create --group=root --owner=root'

	case $OPTION_COMPRESSION in
		('gzip')
			tar_options="$tar_options --gzip"
			pkg_filename="${pkg_filename}.gz"
		;;
		('xz')
			tar_options="$tar_options --xz"
			pkg_filename="${pkg_filename}.xz"
		;;
		('none') ;;
		(*)
			liberror 'OPTION_COMPRESSION' 'pkg_build_arch'
		;;
	esac

	pkg_print "${pkg_filename##*/}"

	(
		cd "$1"
		local files='.PKGINFO *'
		if [ -e '.INSTALL' ]; then
			files=".INSTALL $files"
		fi
		tar $tar_options --file "$pkg_filename" $files
	)

	export ${pkg}_PKG="$pkg_filename"
}

