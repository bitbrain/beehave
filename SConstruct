#!/usr/bin/env python
import os
import sys

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
sources = [
    Glob("extension/src/*.cpp"),
    Glob("extension/src/nodes/*.cpp")
]

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