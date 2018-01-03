#!/usr/bin/env dub
/+
dub.sdl:
  name "build_snippets"
+/

import std.algorithm;
import std.array;
import std.exception;
import std.file;
import std.getopt;
import std.path;
import std.process;
import std.stdio;

immutable commonSkipList = [
    // depends on the browser
    "Snippet128", "Snippet136",

    // depends on OpenGL and OpenGLU
    "Snippet174",
    "Snippet195"
];

immutable windowsOnly = ["Snippet81"];

version (linux)
    immutable skipList = commonSkipList ~ windowsOnly;
else version (Windows)
    immutable skipList = commonSkipList;
else
    static assert(false, "Unsupported platform");

Options options;

struct Options
{
    bool failFast = false;
    string[] extraArgs = [];
}

struct Snippet
{
    string path;
    bool success;
}

bool shouldBuildSnippet(string path)
{
    auto snippet = baseName(path, extension(path));
    return !skipList.canFind(snippet);
}

Snippet build(string path)
{
    const command = ["dub", "build", "--single"] ~ options.extraArgs ~ path;
    immutable exitCode = spawnProcess(command).wait();

    if (options.failFast)
    {
        enforce(exitCode == 0, "The command: '" ~ command.join(" ") ~
            "' failed");
    }

    return Snippet(path, exitCode == 0);
}

bool didSnippetFail(Snippet snippet)
{
    return !snippet.success;
}

int main(string[] args)
{
    enum snippetsPath = "org.eclipse.swt.snippets/src/org/eclipse/swt/snippets";

    getopt(args, std.getopt.config.passThrough, "fail-fast", &options.failFast);
    options.extraArgs = args[1 .. $];

    auto failedSnippets = dirEntries(snippetsPath, "*.d", SpanMode.shallow)
        .filter!(shouldBuildSnippet)
        .map!(build)
        .filter!(didSnippetFail).array;

    if (failedSnippets.empty)
        return 0;

    writeln("The following snippets failed to build:");

    foreach (snippet ; failedSnippets)
        writeln("Failed to build snippet: ", snippet.path);

    return 1;
}
