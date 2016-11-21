# write package meta-data
# USAGE: write_metadata $pkg
# NEEDED VARS: $pkg_ARCH, $pkg_CONFLICTS, $pkg_DEPS, $pkg_DESC, $pkg_ID, $pkg_PATH, $pkg_VERSION, $PACKAGE_TYPE
# CALLS: testvar, liberror, write_metadata_deb
write_metadata() {
for pkg in $@; do
	testvar "$pkg" 'PKG' || liberror 'pkg' 'write_metadata'
	local pkg_arch="$(eval echo \$${pkg}_ARCH)"
	local pkg_conflicts="$(eval echo \$${pkg}_CONFLICTS)"
	[ -n "$pkg_conflicts" ] || pkg_conflicts=''
	local pkg_deps="$(eval echo \$${pkg}_DEPS)"
	[ -n "$pkg_deps" ] || pkg_deps=''
	local pkg_desc="$(eval echo \$${pkg}_DESC)"
	local pkg_id="$(eval echo \$${pkg}_ID)"
	[ -n "$pkg_id" ] || pkg_id="$GAME_ID"
	local pkg_maint="$(whoami)@$(hostname)"
	local pkg_path="$(eval echo \$${pkg}_PATH)"
	local pkg_version="$(eval echo \$${pkg}_VERSION)"
	[ -n "$pkg_version" ] || pkg_version='1.0-1'
	local pkg_size=$(du --total --block-size=1K --summarize "$pkg_path" | tail --lines=1 | cut --fields=1)
	case $PACKAGE_TYPE in
		deb) write_metadata_deb ;;
		tar) return 0 ;;
	esac
done
}

# write .deb package meta-data
# USAGE: write_metadata_deb
# CALLED BY: write_metadata
write_metadata_deb() {
local target="${pkg_path}/DEBIAN/control"
mkdir --parents "${target%/*}"
cat > "${target}" << EOF
Package: $pkg_id
Version: $pkg_version
Architecture: $pkg_arch
Maintainer: $pkg_maint
Installed-Size: $pkg_size
Conflicts: $pkg_conflicts
Depends: $pkg_deps
Section: non-free/games
Description: $pkg_desc
EOF
if [ "$pkg_arch" = 'all' ]; then
	sed -i 's/Architecture: all/&\nMulti-Arch: foreign/' "${target}"
fi
}
