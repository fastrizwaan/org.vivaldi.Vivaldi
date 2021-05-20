#!/bin/bash
#
# Copyright (c) 2011 The Chromium Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Let the wrapped binary know that it has been run through the wrapper.
export CHROME_WRAPPER="$(readlink -f "$0")"

HERE="$(dirname "$CHROME_WRAPPER")"

# Proprietary media check
VIVALDI_VERSION='3.8.2259.42'
CODECS_VERSION='89.0.4389.90'
if [ -e "/app/var/opt/vivaldi/media-codecs-$CODECS_VERSION/libffmpeg.so" ]; then
  if [ -n "$LD_PRELOAD" ]; then
    export LD_PRELOAD="$LD_PRELOAD:/app/var/opt/vivaldi/media-codecs-$CODECS_VERSION/libffmpeg.so"
  else
    export LD_PRELOAD="/app/var/opt/vivaldi/media-codecs-$CODECS_VERSION/libffmpeg.so"
  fi
  export VIVALDI_FFMPEG_FOUND=YES
  # Allow a way for third party maintainers to provide a suitable file
elif [ -e "$HERE/libffmpeg.so.${VIVALDI_VERSION%\.*\.*}" ]; then
  if [ -n "$LD_PRELOAD" ]; then
    export LD_PRELOAD="$LD_PRELOAD:$HERE/libffmpeg.so.${VIVALDI_VERSION%\.*\.*}"
  else
    export LD_PRELOAD="$HERE/libffmpeg.so.${VIVALDI_VERSION%\.*\.*}"
  fi
  export VIVALDI_FFMPEG_FOUND=YES
elif [ -e "$HOME/.local/lib/vivaldi/media-codecs-$CODECS_VERSION/libffmpeg.so" ]; then
  if [ -n "$LD_PRELOAD" ]; then
    export LD_PRELOAD="$LD_PRELOAD:$HOME/.local/lib/vivaldi/media-codecs-$CODECS_VERSION/libffmpeg.so"
  else
    export LD_PRELOAD="$HOME/.local/lib/vivaldi/media-codecs-$CODECS_VERSION/libffmpeg.so"
  fi
  export VIVALDI_FFMPEG_FOUND=YES
else
  export VIVALDI_FFMPEG_FOUND=NO
  # Fix up Proprietary media if not present
  if [ "x${VIVALDI_FFMPEG_AUTO:-1}" = "x1" ]; then
    echo "'Proprietary media' support is not installed. Attempting to fix this for the next restart." >&2
    nohup "$HERE/update-ffmpeg" --user > /dev/null 2>&1 &
  fi
fi

# Fix up Widevine if not present for 32 and 64bit PC architecture
find_user_data () {
  eval set -- "$(getopt -q -o '' -l user-data-dir: -- "$@")"
  if [ "x${1:-}" = "x--user-data-dir" -a "x${2:0:1}" != "x-" ]; then
    USER_DATA_DIR="${2:-}"
  else
    USER_DATA_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/vivaldi"
  fi
}
if [ "x${VIVALDI_WIDEVINE_AUTO:-1}" = "x1" ]; then
  if [ "x86_64" = "i386" ]; then
    if [ ! -e "$HERE/WidevineCdm" -a ! -e "$HOME/.local/lib/vivaldi/WidevineCdm" ]; then
      echo "The Widevine CDM is not installed. Attempting to fix this for the next restart." >&2
      nohup "$HERE/update-widevine" --user > /dev/null 2>&1 &
    fi
    find_user_data "$@"
    if [ -d "$HOME/.local/lib/vivaldi/WidevineCdm" -a ! -e "$USER_DATA_DIR/WidevineCdm/latest-component-updated-widevine-cdm" ]; then
      mkdir -p "$USER_DATA_DIR/WidevineCdm"
      echo "{\"Path\":\"$HOME/.local/lib/vivaldi/WidevineCdm\"}" > "$USER_DATA_DIR/WidevineCdm/latest-component-updated-widevine-cdm"
    fi
  fi
fi

export CHROME_VERSION_EXTRA="stable"

# We don't want bug-buddy intercepting our crashes. http://crbug.com/24120
export GNOME_DISABLE_CRASH_DIALOG=SET_BY_GOOGLE_CHROME

# Sanitize std{in,out,err} because they'll be shared with untrusted child
# processes (http://crbug.com/376567).
exec < /dev/null
exec > >(exec cat)
exec 2> >(exec cat >&2)


# Chrome loads cursors by itself, following the standard XCursor search
# directories. However, the fd.o runtime patches XCursor to look in
# $XDG_DATA_DIRS, but Chrome's own loading of course does not follow that.
# Therefore, we manually set the XCursor path to follow $XDG_DATA_DIRS here.
export XCURSOR_PATH=$(echo "$XDG_DATA_DIRS" | sed 's,\(:\|$\),/icons\1,g')
export TMPDIR="$XDG_RUNTIME_DIR/app/$FLATPAK_ID"
export ZYPAK_SANDBOX_FILENAME=vivaldi-sandbox
export ZYPAK_EXPOSE_WIDEVINE_PATH=/var/home/giesiger/.var/app/org.vivaldi.Vivaldi/config/vivaldi/WidevineCdm

 exec zypak-wrapper.sh /app/extra/vivaldi/vivaldi-bin "$@" 
