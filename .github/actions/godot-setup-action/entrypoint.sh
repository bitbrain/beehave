#!/bin/sh

GODOT_URL=http://downloads.tuxfamily.org/godotengine/$INPUT_VERSION
GODOT_BINARY=Godot_v$INPUT_VERSION-${INPUT_PRERELEASE_VERSION}_linux.x86_64



if  [[ -z "$INPUT_PRERELEASE_VERSION" ]]
then
    echo "Downloading  $GODOT_URL/$GODOT_BINARY.zip..."
    curl $GODOT_URL/$GODOT_BINARY.zip > $GODOT_BINARY.zip
else
    echo "Downloading $GODOT_URL/$INPUT_PRERELEASE_VERSION/$GODOT_BINARY.zip..."
    curl $GODOT_URL/$INPUT_PRERELEASE_VERSION/$GODOT_BINARY.zip > $GODOT_BINARY.zip
fi

unzip $GODOT_BINARY.zip && rm $GODOT_BINARY.zip

ls -lsa