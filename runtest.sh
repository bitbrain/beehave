#!/bin/sh

if [ -z "$GODOT_BIN" ]; then
    echo "'GODOT_BIN' is not set."
    echo "Please set the environment variable"
    exit 1
fi

timeout 30 $GODOT_BIN --headless --quit --editor --path $PWD
$GODOT_BIN --headless --quit --editor --path $PWD --script addons/gdUnit4/bin/GdUnitCmdTool.gd $*
exit_code=$?
$GODOT_BIN --headless --quit --editor --path $PWD --script addons/gdUnit4/bin/GdUnitCopyLog.gd $* > /dev/null
exit $exit_code