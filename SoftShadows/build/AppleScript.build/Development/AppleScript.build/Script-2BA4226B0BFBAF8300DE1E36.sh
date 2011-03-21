#!/bin/sh
mkdir -p "$HOME/Library/Graphics/Quartz Composer Patches/"
rm -Rf "$HOME/Library/Graphics/Quartz Composer Patches/$FULL_PRODUCT_NAME/"
mv "$TARGET_BUILD_DIR/$FULL_PRODUCT_NAME" "$HOME/Library/Graphics/Quartz Composer Patches/"	
