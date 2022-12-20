#!/bin/sh

if [ -z "$GODOT_BIN" ]; then
    echo "'GODOT_BIN' is not set."
    exit 1
fi

# we not use no-window because of issue https://github.com/godotengine/godot/issues/55379
#$GODOT_BIN --no-window -s -d ./addons/gdUnit4/bin/GdUnitCmdTool.gd $*
$GODOT_BIN --headless -s -d ./../addons/gdUnit4/bin/GdUnitCmdTool.gd $*
exit_code=$?
$GODOT_BIN --no-window --headless --quiet -s -d ./../addons/gdUnit4/bin/GdUnitCopyLog.gd $* > /dev/null
exit $exit_code
