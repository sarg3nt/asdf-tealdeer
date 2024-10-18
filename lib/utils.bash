#!/usr/bin/env bash

set -euo pipefail

GH_REPO="https://github.com/tealdeer-rs/tealdeer"
TOOL_NAME="tldr"
TOOL_TEST="tldr --version"

fail() {
	echo -e "asdf-$TOOL_NAME: $*"
	exit 1
}

curl_opts=(-fsSL)

if [ -n "${GITHUB_API_TOKEN:-}" ]; then
	curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

sort_versions() {
	sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
		LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_github_tags() {
	git ls-remote --tags --refs "$GH_REPO" |
		grep -o 'refs/tags/.*' | cut -d/ -f3- |
		sed 's/^v//' # NOTE: You might want to adapt this sed to remove non-version strings from tags
}

list_all_versions() {
	list_github_tags
}

get_platform() {
	local -r kernel="$(uname -s)"
	if [[ ${OSTYPE} == "msys" || ${kernel} == "CYGWIN"* || ${kernel} == "MINGW"* ]]; then
		echo windows
	elif [[ ${kernel} == "Darwin" ]]; then
		echo macos
	else
		uname | tr '[:upper:]' '[:lower:]'
	fi
}

get_arch() {
	local -r machine="$(uname -m)"

	if [[ ${machine} == "arm64" ]] || [[ ${machine} == "aarch64" ]]; then
		echo "arm64"
	elif [[ ${machine} == "arm" ]]; then
		echo "armv7"
	elif [[ ${machine} == *"armv"* ]] || [[ ${machine} == *"aarch"* ]]; then
		echo "arm"
	elif [[ ${machine} == *"386"* ]]; then
		echo "386"
	else
		echo "x86_64"
	fi
}
get_download_name() {
	local -r platform="$(get_platform)"
	local -r arch="$(get_arch)"
	if [[ ${platform} == "linux" ]] && [[ ${arch} == "x86_64" ]]; then
		echo "tealdeer-linux-x86_64-musl"
	elif [[ ${platform} == "macos" ]] && [[ ${arch} == "x86_64" ]]; then
		echo "tealdeer-macos-x86_64"
	elif [[ ${platform} == "linux" ]] && [[ ${arch} == "arm" ]]; then
		echo "tealdeer-linux-arm-musleabihf"
	elif [[ ${platform} == "linux" ]] && [[ ${arch} == "armv7" ]]; then
		echo "tealdeer-linux-armv7-musleabihf"
	elif [[ ${platform} == "windows" ]] && [[ ${arch} == "x86_64" ]]; then
		echo "tealdeer-windows-x86_64-msvc.exe"
	else
		fail "Unknown or unsupported platform ${platform}-${arch} detected."
	fi
}

download_release() {
	local version filename url
	version="$1"
	filename="$2"
	local -r downloadname="$(get_download_name)"
	url="$GH_REPO/releases/download/v${version}/${downloadname}"

	echo "* Downloading $downloadname release $version..."

	curl "${curl_opts[@]}" -o "$filename" -C - "$url" || fail "Could not download $url"
	chmod +x "$filename"
}

install_version() {
	local install_type="$1"
	local version="$2"
	local install_path="${3%/bin}/bin"

	if [ "$install_type" != "version" ]; then
		fail "asdf-$TOOL_NAME supports release installs only"
	fi

	(
		mkdir -p "$install_path"
		cp -r "$ASDF_DOWNLOAD_PATH"/* "$install_path"
		mv "$install_path/${TOOL_NAME}-${version}" "$install_path/${TOOL_NAME}"

		local tool_cmd
		tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
		test -x "$install_path/${tool_cmd}" || fail "Expected $install_path/$tool_cmd to be executable."

		echo "$TOOL_NAME $version installation was successful!"
	) || (
		rm -rf "$install_path"
		fail "An error occurred while installing $TOOL_NAME $version."
	)
}
