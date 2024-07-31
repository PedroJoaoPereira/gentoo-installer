#!/bin/sh

THIS_FONTS_DIR="${HOME}/.local/share/fonts/"
THIS_FONTS_REPOSITORY=https://github.com/ryanoasis/nerd-fonts/releases/latest/download/

# recreate fonts folder
rm -rf $THIS_FONTS_DIR
mkdir -p $THIS_FONTS_DIR

# iterate each argument - font name
for THIS_FONT_NAME in "$@"; do
    echo "Installing ${THIS_FONT_NAME}..."
    # download
    curl -sSOL "${THIS_FONTS_REPOSITORY}${THIS_FONT_NAME}.tar.xz" --output-dir ${THIS_FONTS_DIR}
    # decompress
    tar xf "${THIS_FONTS_DIR}${THIS_FONT_NAME}.tar.xz" --directory ${THIS_FONTS_DIR}
    # remove tar file
    rm -rf "${THIS_FONTS_DIR}${THIS_FONT_NAME}.tar.xz"
done

# refreshing fonts cache
fc-cache -fv
