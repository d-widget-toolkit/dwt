#!/usr/bin/env dub
/+
dub.sdl:
  name "test_snippets"
+/

import std.algorithm;
import std.array;
import std.exception;
import std.file;
import std.getopt;
import std.path;
import std.process;
import std.stdio;
import std.range;

enum Arch
{
    x86,
    x86_64
}

version (X86)
    enum defaultArch = Arch.x86;
else version(X86_64)
    enum defaultArch = Arch.x86_64;
else
    static assert("Unsupported architecture");

Arch arch = defaultArch;

immutable commonSkipList = [
    // depends on the browser
    "Snippet128", "Snippet136",

    // depends on OpenGL and OpenGLU
    "Snippet174",
    "Snippet195"
];

immutable windowsOnly = ["Snippet81"];

version (linux)
{
    immutable skipList = commonSkipList ~ windowsOnly;
    immutable compilerArgs = [
        "-Iorg.eclipse.swt.gtk.linux.x86/src",
        `-I"org.eclipse.swt/Eclipse SWT/common"`,
        "-Jorg.eclipse.swt.gtk.linux.x86/res"
    ];
}
else version (Windows)
{
    immutable skipList = commonSkipList;
    immutable compilerArgs = [
        "-Iorg.eclipse.swt.win32.win32.x86/src",
        `-I"org.eclipse.swt/Eclipse SWT/common"`,
        "-Jorg.eclipse.swt.win32.win32.x86/res"
    ];
}
else
    static assert(false, "Unsupported platform");

bool shouldBuildSnippet(string path)
{
    auto snippet = baseName(path, extension(path));
    return !skipList.canFind(snippet);
}

int build(string filename)
{
    immutable compiler = environment.get("DC", "dmd");
    immutable command = [compiler, "@" ~ filename];

    return spawnProcess(command).wait();
}

auto archFlag()
{
    return only(arch == Arch.x86 ? "-m32" : "-m64");
}

string writeArgsFile(Snippets)(Snippets snippets)
    if (isInputRange!Snippets)
{
    enum filename = "args.txt";
    auto defaultCompilerArgs = only(
        "-Ibase/src", "-Jres", "-Jorg.eclipse.swt.snippets/res", "-o-"
    );

    auto content = compilerArgs
        .chain(defaultCompilerArgs)
        .chain(archFlag)
        .chain(snippets)
        .join("\n");

    std.file.write(filename, content);

    return filename;
}

int main(string[] args)
{
    enum snippetsPath = "org.eclipse.swt.snippets/src/org/eclipse/swt/snippets";

    getopt(args, "arch", &arch);

    return dirEntries(snippetsPath, "*.d", SpanMode.shallow)
        .filter!(shouldBuildSnippet)
        .writeArgsFile
        .build;
}
