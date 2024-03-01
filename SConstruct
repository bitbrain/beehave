#!/usr/bin/env python
import os
import sys

def recursive_glob(rootdir, pattern):
    matches = []
    for root, dirnames, filenames in os.walk(rootdir):
        for filename in filenames:
            if filename.endswith(pattern):
                matches.append(os.path.join(root, filename))
    return matches

env = SConscript("godot-cpp/SConstruct")

# Add those directory manually, so we can skip the godot_cpp directory when including headers in C++ files
source_path = [
    os.path.join("godot-cpp", "include","godot_cpp"),
    os.path.join("godot-cpp", "gen", "include","godot_cpp")
]
env.Append(CPPPATH=[env.Dir(d) for d in source_path])

# For the reference:
# - CCFLAGS are compilation flags shared between C and C++
# - CFLAGS are for C-specific compilation flags
# - CXXFLAGS are for C++-specific compilation flags
# - CPPFLAGS are for pre-processor flags
# - CPPDEFINES are for pre-processor defines
# - LINKFLAGS are for linking flags

# tweak this if you want to use different folders, or more folders, to store your source code in.
env.Append(CPPPATH=["extension/src/"])

sources = recursive_glob('extension/src', '.cpp')

if env["platform"] == "macos":
    library = env.SharedLibrary(
        "addons/beehave/libs/{}/beehave.{}.{}.framework/beehave.{}.{}".format(
            env["platform"], env["platform"], env["target"], env["platform"], env["target"]
        ),
        source=sources,
    )
else:
    library = env.SharedLibrary(
        "addons/beehave/libs/{}/beehave{}{}".format(env["platform"], env["suffix"], env["SHLIBSUFFIX"]),
        source=sources,
    )

Default(library)