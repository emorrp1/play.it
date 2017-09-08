# write .pkg.tar package meta-data
# USAGE: pkg_write_arch
# NEEDED VARS: GAME_NAME PKG_DEPS_ARCH
# CALLED BY: write_metadata
pkg_write_arch() {
	local pkg_deps
	if [ "$(eval printf -- '%b' \"\$${pkg}_DEPS\")" ]; then
		pkg_set_deps_arch $(eval printf -- '%b' \"\$${pkg}_DEPS\")
	fi
	if [ "$(eval printf -- '%b' \"\$${pkg}_DEPS_ARCH_${ARCHIVE#ARCHIVE_}\")" ]; then
		pkg_deps="$pkg_deps $(eval printf -- '%b' \"\$${pkg}_DEPS_ARCH_${ARCHIVE#ARCHIVE_}\")"
	elif [ "$(eval printf -- '%b' \"\$${pkg}_DEPS_ARCH\")" ]; then
		pkg_deps="$pkg_deps $(eval printf -- '%b' \"\$${pkg}_DEPS_ARCH\")"
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

# set list or Arch Linux dependencies from generic names
# USAGE: pkg_set_deps_arch $dep[…]
# CALLS: pkg_set_deps_arch32 pkg_set_deps_arch64
# CALLED BY: pkg_write_arch
pkg_set_deps_arch() {
	local architecture
	if [ "$(eval printf -- '%b' \"\$${pkg}_ARCH_${ARCHIVE#ARCHIVE_}\")" ]; then
		architecture="$(eval printf -- '%b' \"\$${pkg}_ARCH_${ARCHIVE#ARCHIVE_}\")"
	else
		architecture="$(eval printf -- '%b' \"\$${pkg}_ARCH\")"
	fi
	case $architecture in
		('32')
			pkg_set_deps_arch32 $@
		;;
		('64')
			pkg_set_deps_arch64 $@
		;;
	esac
}

# set list or Arch Linux 32-bit dependencies from generic names
# USAGE: pkg_set_deps_arch32 $dep[…]
# CALLED BY: pkg_set_deps_arch
pkg_set_deps_arch32() {
	for dep in $@; do
		case $dep in
			('dosbox')
				pkg_deps="$pkg_deps dosbox"
			;;
			('glibc')
				pkg_deps="$pkg_deps lib32-glibc"
			;;
			('glu')
				pkg_deps="$pkg_deps lib32-glu"
			;;
			('glx')
				pkg_deps="$pkg_deps lib32-libgl"
			;;
			('libstdc++')
				pkg_deps="$pkg_deps lib32-gcc-libs"
			;;
			('libxrandr')
				pkg_deps="$pkg_deps lib32-libxrandr"
			;;
			('openal')
				pkg_deps="$pkg_deps lib32-openal"
			;;
			('pulseaudio')
				pkg_deps="$pkg_deps pulseaudio"
			;;
			('sdl2')
				pkg_deps="$pkg_deps lib32-sdl2"
			;;
			('vorbis')
				pkg_deps="$pkg_deps lib32-libvorbis"
			;;
			('wine')
				pkg_deps="$pkg_deps wine"
			;;
			('xcursor')
				pkg_deps="$pkg_deps lib32-libxcursor"
			;;
			(*)
				pkg_deps="$pkg_deps $dep"
			;;
		esac
	done
}

# set list or Arch Linux 64-bit dependencies from generic names
# USAGE: pkg_set_deps_arch64 $dep[…]
# CALLED BY: pkg_set_deps_arch
pkg_set_deps_arch64() {
	for dep in $@; do
		case $dep in
			('dosbox')
				pkg_deps="$pkg_deps dosbox"
			;;
			('glibc')
				pkg_deps="$pkg_deps glibc"
			;;
			('glu')
				pkg_deps="$pkg_deps glu"
			;;
			('glx')
				pkg_deps="$pkg_deps libgl"
			;;
			('libstdc++')
				pkg_deps="$pkg_deps gcc-libs"
			;;
			('libxrandr')
				pkg_deps="$pkg_deps libxrandr"
			;;
			('openaL')
				pkg_deps="$pkg_deps openal"
			;;
			('pulseaudio')
				pkg_deps="$pkg_deps pulseaudio"
			;;
			('sdl2')
				pkg_deps="$pkg_deps sdl2"
			;;
			('vorbis')
				pkg_deps="$pkg_deps libvorbis"
			;;
			('wine')
				pkg_deps="$pkg_deps wine"
			;;
			('xcursor')
				pkg_deps="$pkg_deps libxcursor"
			;;
			(*)
				pkg_deps="$pkg_deps $dep"
			;;
		esac
	done
}

# build .pkg.tar package
# USAGE: pkg_build_arch $pkg_path
# NEEDED VARS: (OPTION_COMPRESSION) (LANG) PLAYIT_WORKDIR
# CALLS: pkg_print
# CALLED BY: build_pkg
pkg_build_arch() {
	local pkg_filename="$PWD/${1##*/}.pkg.tar"

	if [ -e "$pkg_filename" ]; then
		pkg_build_print_already_exists "${pkg_filename##*/}"
		export ${pkg}_PKG="$pkg_filename"
		return 0
	fi

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

	print_ok
}

