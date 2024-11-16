#!/bin/sh

set -oex pipefail
set +u

# from RPMs on Github
# Space-separated list of repo/package strings
repos="quexten/goldwarden"

# Loop through each repo/package
for repo_package in $repos; do
    # Split the string into repo and package using parameter expansion
    repo=${repo_package%/*}
    package=${repo_package#*/}

    # Fetch the latest release download URL for .rpm assets
    download_url=$(wget -qO- "https://api.github.com/repos/$repo/$package/releases/latest" \
        | jq -r '.assets[] | select(.name | match(".rpm")) | .browser_download_url')

    # Download the asset as <PACKAGE>.rpm
    wget -qO "$package.rpm" "$download_url"

    # Install the package
    rpm-ostree install "$package.rpm"
done
