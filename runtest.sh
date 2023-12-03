#!/bin/sh

if [ -z "$GODOT_BIN" ]; then
    echo "'GODOT_BIN' is not set."
    echo "Please set the environment variable  'export GODOT_BIN=/Applications/Godot.app/Contents/MacOS/Godot'"
    exit 1
fi

$GODOT_BIN --path . -s -d ./addons/gdUnit4/bin/GdUnitCmdTool.gd $*
exit_code=$?
$GODOT_BIN --headless --path . --quiet -s -d ./addons/gdUnit4/bin/GdUnitCopyLog.gd $* > /dev/null
exit $exit_code
