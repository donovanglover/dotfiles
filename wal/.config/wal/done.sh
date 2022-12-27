#!/bin/sh

if [ -e ~/.cache/wal/kitty ]; then
  for kitty_window in `fd kitty /tmp`; do
    kitty @ --to unix:$kitty_window set-colors -c -a ~/.cache/wal/kitty
  done
fi
