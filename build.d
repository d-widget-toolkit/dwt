#!/usr/bin/env dmd -run
//////////////////////////////////////////////////////////////////////////
// DWT2
//
import std.algorithm;
import std.array;
import std.conv;
import std.file;
import std.getopt;
import std.path;
import std.process;
import std.stdio;
import std.string;
import std.ascii : newline;

//////////////////////////////////////////////////////////////////////////
// Helpers
//
version (Windows) {
    immutable isWindows = true;
} else {
    immutable isWindows = false;
}

string win_path(string path) {
    static if (isWindows) {
        return path.replace( "/", "\\" );
    } else {
        return path;
    }
}

/// Checks existence of file before file operation.
void mkdirRecurseE(string path) {
    if (!path.exists()) {
        std.file.mkdirRecurse(path);
    }
}
/// ditto
void renameE(string from, string to) {
    if (to.exists()) {
        to.remove();
    }
    std.file.rename(from, to);
}
/// ditto
void removeE(string path) {
    if (path.exists()) {
        std.file.remove(path);
    }
}
/// ditto
void rmdirRecurseE(string path) {
    if (path.exists()) {
        std.file.rmdirRecurse(path);
    }
}

//////////////////////////////////////////////////////////////////////////
// Constants
//

void main(string[] args) {

immutable DIR_OBJ     = .absolutePath("obj");
immutable DIR_IMP     = .absolutePath("imp");
immutable DIR_RES     = .absolutePath("res");
immutable DIR_LIB     = .absolutePath("lib");
immutable DIR_BIN     = .absolutePath("bin");
immutable FILE_RSP    = .absolutePath("rsp");

immutable LOG_STDOUT  = .absolutePath("olog.txt");
immutable LOG_STDERR  = .absolutePath("elog.txt");


static if (isWindows) {
    immutable BASEDIR_SWT = "org.eclipse.swt.win32.win32.x86";
    immutable LIBEXT   = ".lib";
    immutable OBJEXT   = ".obj";
    immutable EXEEXT   = ".exe";
    immutable MAPEXT   = ".map";
    immutable PROG_LIB = "dmd.exe";
    immutable DIR_WINLIBS = .absolutePath(.buildPath(BASEDIR_SWT,"lib"));
} else {
    immutable BASEDIR_SWT = "org.eclipse.swt.gtk.linux.x86";
    immutable LIBEXT   = ".a";
    immutable OBJEXT   = ".o";
    immutable EXEEXT   = "";
    immutable PROG_LIB = "ar";
}
immutable PROG_DMD = "dmd" ~ EXEEXT;

static if (isWindows) {
    //LIBNAMES_BASIC  = [ "dwt-base" ]
    immutable LIBNAMES_BASIC  = [ "advapi32", "comctl32", "comdlg32", "gdi32", "kernel32",
                                  "shell32", "ole32", "oleaut32", "oleacc",
                                  "user32", "usp10", "msimg32", "opengl32", "shlwapi",
                                  "dwt-base" ];

} else {
    immutable SONAMES_BASIC   = [ "gtk-x11-2.0", "gdk-x11-2.0", "atk-1.0", "gdk_pixbuf-2.0",
                                  "gthread-2.0", "pangocairo-1.0", "fontconfig", "Xtst",
                                  "Xext", "Xrender", "Xinerama", "Xi", "Xrandr", "Xcursor",
                                  "Xcomposite", "Xdamage", "X11", "Xfixes", "pango-1.0",
                                  "gobject-2.0", "gmodule-2.0", "dl", "glib-2.0", "cairo",
                                  "gnomeui-2", "gnomevfs-2" ];
    immutable LIBNAMES_BASIC  = [ "dwt-base" ];
}

immutable LIBNAMES_SWT        = [ BASEDIR_SWT ];
immutable LIBNAMES_ICU        = [ "com.ibm.icu" ];
immutable LIBNAMES_EQUINOX    = [ "org.eclipse.osgi.osgi",
                                  "org.eclipse.osgi.supplement",
                                  "org.eclipse.equinox.common" ];

immutable LIBNAMES_CORE       = [ "org.eclipse.core.runtime",
                                  "org.eclipse.core.commands",
                                  "org.eclipse.core.databinding",
                                  "org.eclipse.core.databinding.beans",
                                  "org.eclipse.core.jobs" ];

immutable LIBNAMES_JFACE      = [ "org.eclipse.jface" ];

immutable LIBNAMES_JFACEBIND  = [ "org.eclipse.jface.databinding" ];

immutable LIBNAMES_JFACETEXT  = [ "org.eclipse.text",
                                  "org.eclipse.jface.text.projection",
                                  "org.eclipse.jface.text", ];

immutable LIBNAMES_UIFORMS    = [ "org.eclipse.ui.forms" ];

immutable LIBNAMES_DRAW2D     = [ "org.eclipse.draw2d" ];


//////////////////////////////////////////////////////////////////////////
// Routines
//

bool isDebug = ("1" == .environment.get("DEBUG", ""));
string[] extraOptions;

void createLib( in string[] libobjs, string name ) {
    .mkdirRecurseE(win_path(DIR_LIB));
    auto file_lib = .buildPath(DIR_LIB, name ~ LIBEXT);
    .removeE(file_lib);
    string[] rsp;
    static if (isWindows) {
        rsp ~= "-lib";
        rsp ~= "-of" ~ win_path(file_lib);
        foreach (obj; libobjs) {
            rsp ~= win_path(obj);
        }
    } else {
        rsp ~= "-r";
        rsp ~= "-c " ~ win_path(file_lib);
        foreach (obj; libobjs) {
            rsp ~= win_path(obj);
        }
    }

    rsp ~= extraOptions;

    std.file.write(FILE_RSP, rsp.join(.newline));

    static if (isWindows)
        auto cmd = PROG_LIB ~ " @" ~ FILE_RSP ~ " > " ~ LOG_STDOUT;
    else
        auto cmd = "cat " ~ FILE_RSP ~ " | xargs ar > " ~ LOG_STDOUT;

    writeln(cmd);
    if (0 != .wait(.spawnShell(cmd))) {
        throw new Exception("librarian error");
    }
    foreach (obj; libobjs) {
        obj.removeE();
    }
}

void buildTree( string basedir, string srcdir, string resdir, string[] dcargs=null, string libname=null ) {
    if (libname is null) {
        libname = basedir;
    }
    auto dbg_str = "";
    if (isDebug) {
        dbg_str = "Debug ";
    }

    auto resdir_abs = .absolutePath( .buildPath( basedir, resdir ));
    auto srcdir_abs = .absolutePath( .buildPath( basedir, srcdir ));

    stderr.writeln(dbg_str ~ "Building " ~ libname);
    stderr.writeln("workdir=>" ~ win_path(srcdir_abs));

    .mkdirRecurseE(DIR_IMP);
    .mkdirRecurseE(DIR_OBJ);
    .mkdirRecurseE(DIR_RES);
    foreach (string file; .dirEntries(resdir_abs, SpanMode.depth)) {
        file.copy(DIR_RES.buildPath(file.baseName()));
    }

    string[] rsp;
    rsp ~= "-H";
    //rsp ~= "-Hd" ~ win_path(DIR_IMP);
    rsp ~= "-I" ~ win_path(srcdir_abs);
    rsp ~= "-I" ~ win_path(DIR_IMP);
    rsp ~= "-J" ~ win_path(DIR_RES);
    if (dcargs !is null) {
        rsp ~= dcargs;
    }
    rsp ~= "-c";
    rsp ~= "-op";
    version (linux) {
        // DWT2-GTK is 64 bit supported.
    } else version (Windows) {
        // DWT2-Windows is 64 bit supported.
    } else {
        rsp ~= "-m32";
    }
    if (isDebug) {
        rsp ~= "-debug";
        rsp ~= "-g";
    }
    foreach (string path; srcdir_abs.dirEntries(SpanMode.depth)) {
        if (!path.endsWith(".d")) continue;
        if (-1 != std.string.indexOf(path, "browser")) continue;
        if (-1 != std.string.indexOf(path, "mozilla")) continue;
        rsp ~= win_path(path)[ srcdir_abs.length+1 .. $ ];
    }

    rsp ~= extraOptions;

    std.file.write(FILE_RSP, rsp.join(.newline));

    {
        auto current = getcwd();
        chdir(srcdir_abs);
        scope (exit) chdir(current);

        string cmd;
        static if (isWindows) {
            cmd = PROG_DMD ~ " @" ~ win_path(FILE_RSP);
        } else {
            cmd = "cat " ~ win_path(FILE_RSP) ~ " | xargs " ~ PROG_DMD;
        }
        writeln(cmd);
        if (0 != .wait(.spawnShell(cmd))) {
            foreach (string path; srcdir_abs.dirEntries(SpanMode.depth)) {
                if (path.isFile() && (path.endsWith(".o") || path.endsWith(".obj"))) {
                    path.removeE();
                }
                if (isFile(path) && path.endsWith(".di")) {
                    path.removeE();
                }
            }

            throw new Exception("compile error");
        }
    }

    foreach (string path; srcdir_abs.dirEntries(SpanMode.depth)) {
        if (path.isFile() && path.endsWith(".di")) {
            auto trgfile = .buildPath( DIR_IMP, path[ srcdir_abs.length+1 .. $ ]);
            .mkdirRecurseE(trgfile.dirName());
            .renameE(path, trgfile);
        }
    }

    string[] libobjs;
    auto srcdirparts = .split( srcdir_abs, dirSeparator ).length;
    foreach (string path; srcdir_abs.dirEntries(SpanMode.depth)) {
        if (path.isFile() && (path.endsWith(".o") || path.endsWith(".obj"))) {
            auto trgfile = .split( path, dirSeparator )[ srcdirparts .. $ ].join( "-" );
            .renameE(path, .buildPath( DIR_OBJ, trgfile ));
            libobjs ~= .buildPath( DIR_OBJ, trgfile );
        }
    }

    createLib( libobjs, libname );
}

void buildApp( string basedir, string srcdir, string resdir, in string[] dflags, string appnameprefix, string appname, string[] filelist, in string[] libnames ) {

    auto srcdir_abs = .absolutePath( .buildPath( basedir, srcdir));
    auto resdir_abs = .absolutePath( .buildPath( basedir, resdir));

    if (filelist is null) {
        filelist = [];
        foreach (string file; srcdir_abs.dirEntries(SpanMode.depth)) {
            if (file.baseName() == appname ~ ".d") {
                filelist ~= file;
            }
        }
        if (filelist.length == 0) {
            throw new Exception("'" ~ appname ~ ".d' not found");
        }
    }

    string[] rsp;
    rsp ~= "-I" ~ win_path(srcdir_abs);
    rsp ~= "-I" ~ win_path(DIR_IMP);
    rsp ~= "-J" ~ win_path(resdir_abs);
    rsp ~= "-J" ~ win_path(DIR_RES);
    version (linux) {
        // DWT2-GTK is 64 bit supported.
    } else version (Windows) {
        // DWT2-Windows is 64 bit supported.
    } else {
        rsp ~= "-m32";
    }
    if (isDebug) {
        rsp ~= "-debug";
        rsp ~= "-g";
    }
    if (dflags.length > 0) {
        rsp ~= dflags;
    }

    rsp ~= "-op";
    rsp ~= "-od" ~ win_path(DIR_OBJ);
    auto applfile = .buildPath(DIR_BIN ,appnameprefix ~ appname ~ EXEEXT);
    rsp ~= "-of" ~ win_path(applfile);
    foreach (path; filelist) {
        rsp ~= win_path(.absolutePath(path))[ srcdir_abs.length+1 .. $ ];
    }

    static if (isWindows) {
        if (extraOptions.canFind("-m64") || extraOptions.canFind("-m32mscoff")) {
            // 64-bit
            // Microsoft Incremental Linker
            rsp ~= "-L/SUBSYSTEM:CONSOLE";
            rsp ~= win_path(.absolutePath("win-res\\resource.res"));
            foreach (libname; libnames) {
                rsp ~= "-L" ~ libname ~ LIBEXT;
            }
            rsp ~= "-L/LIBPATH:" ~ win_path(DIR_LIB);
        } else {
            // 32-bit
            // OPTLINK
            rsp ~= "-L/NOM";
            rsp ~= "-L/SUBSYSTEM:CONSOLE:4.0";
            rsp ~= win_path(.absolutePath("win-res\\resource.res"));
            foreach (libname; libnames) {
                rsp ~= "-L+" ~ libname ~ LIBEXT;
            }
            rsp ~= "-L+" ~ win_path(DIR_LIB) ~ "\\";
        }
    } else {
        rsp ~= "-L-L" ~ win_path(DIR_LIB);
        foreach_reverse (libname; libnames) {
            auto absname = .buildPath( DIR_LIB, libname ~ LIBEXT );
            rsp ~= "-L" ~ absname;
        }
        foreach_reverse (soname; SONAMES_BASIC) {
            rsp ~= "-L-l" ~ soname;
        }
    }

    rsp ~= extraOptions;

    std.file.write(FILE_RSP, rsp.join(.newline));

    {
        auto current = getcwd();
        chdir(srcdir_abs);
        scope (exit) chdir(current);

        string cmd;
        static if (isWindows) {
            cmd = PROG_DMD ~ " @" ~ win_path(FILE_RSP);
        } else {
            cmd = "cat " ~ win_path(FILE_RSP) ~ " | xargs " ~ PROG_DMD;
        }
        writeln(cmd);
        if (0 != .wait(.spawnShell(cmd))) {
            throw new Exception("compile error");
        }
    }
    static if (isWindows) {
        .removeE(.buildPath(srcdir_abs,appname ~ MAPEXT));
    }
}

//////////////////////////////////////////////////////////////////////////
// Targets
//
string         [string] desc; // Description of tasks.
void delegate()[string] task; // Build tasks.
string[]       [string] dep;  // Dependency of tasks.
void delegate(string arg)[string] taskEx; // Build tasks with argument.
string                   [string] taskAg; // Argument name of build tasks.

desc["clean"] = "Clean";
task["clean"] = {
    writeln("Cleaning");
    .rmdirRecurseE(DIR_IMP);
    .rmdirRecurseE(DIR_OBJ);
    .rmdirRecurseE(DIR_LIB);
    .rmdirRecurseE(DIR_BIN);
    .rmdirRecurseE(DIR_RES);
    .removeE(FILE_RSP);
    .removeE(LOG_STDOUT);
    .removeE(LOG_STDERR);
};

desc["base"] = "Build Base (Java Environment and Helpers)";
task["base"] = {
    buildTree( "base", "src", "res", null, "dwt-base" );
};

desc["swt"] = "Build SWT";
task["swt"] = {
    buildTree( BASEDIR_SWT, "src", "res" );
    static if (isWindows) {
        if (extraOptions.canFind("-m64") || extraOptions.canFind("-m32mscoff")) {
            // Uses Windows SDK.
            foreach (string file; .dirEntries(DIR_WINLIBS, SpanMode.shallow)) {
                if (file.extension() == LIBEXT) {
                    auto lib = DIR_LIB.buildPath(file.baseName());
                    if (lib.exists()) {
                        .remove(lib);
                    }
                }
            }
        } else {
            foreach (string file; .dirEntries(DIR_WINLIBS, SpanMode.shallow)) {
                if (file.extension() == LIBEXT) {
                    .copy(file, DIR_LIB.buildPath(file.baseName()));
                }
            }
        }
    }
};

desc["default"] = "Build Equinox";
dep ["default"] = ["work"];
task["default"] = { };

desc["equinox"] = "Build Equinox";
task["equinox"] = {
    buildTree( "org.eclipse.osgi", "osgi/src"      , "res", null, "org.eclipse.osgi.osgi" );
    buildTree( "org.eclipse.osgi", "supplement/src", "res", null, "org.eclipse.osgi.supplement");
    buildTree( "org.eclipse.equinox.common", "src", "res" );

    buildTree( "org.eclipse.osgi", "console/src", "res", null, "org.eclipse.osgi.console");
    buildTree( "org.eclipse.osgi", "core/adaptor", "res", null, "org.eclipse.osgi.core.adaptor");
    buildTree( "org.eclipse.osgi", "core/framework", "res", null, "org.eclipse.osgi.core.framework");
    buildTree( "org.eclipse.osgi", "defaultAdaptor/src", "res", null, "org.eclipse.osgi.defaultadaptor");
    buildTree( "org.eclipse.osgi", "eclipseAdaptor/src", "res", null, "org.eclipse.osgi.eclipseadaptor");
    buildTree( "org.eclipse.osgi", "jarverifier", "res", null, "org.eclipse.osgi.jarverifier");
    buildTree( "org.eclipse.osgi", "resolver/src", "res", null, "org.eclipse.osgi.resolver");
    buildTree( "org.eclipse.osgi", "security/src", "res", null, "org.eclipse.osgi.security");
    buildTree( "org.eclipse.osgi", "supplement/src", "res", null, "org.eclipse.osgi.supplement");
    buildTree( "org.eclipse.osgi.services", "src", "res" );
    buildTree( "org.eclipse.equinox.app", "src", "res" );
    buildTree( "org.eclipse.equinox.preferences", "src", "res" );
    buildTree( "org.eclipse.equinox.registry", "src", "res" );
    buildTree( "org.eclipse.equinox.security", "src", "res" );
};

desc["work"] = "Build Current Working area";
task["work"] = {
    string[] searchdirs;
    searchdirs ~= "-I../../supplement/src ";
    searchdirs ~= "-I../../osgi/src ";
    searchdirs ~= "-I../../core/framework ";
    searchdirs ~= "-I../../supplement/src ";
    searchdirs ~= "-I../../console/src ";
    searchdirs ~= "-I../../core/adaptor ";
    searchdirs ~= "-I../../defaultAdaptor/src ";
    searchdirs ~= "-I../../eclipseAdaptor/src ";
    searchdirs ~= "-I../../jarverifier ";
    searchdirs ~= "-I../../resolver/src ";
    searchdirs ~= "-I../../security/src ";

    buildTree( "org.eclipse.osgi", "supplement/src", "res", searchdirs, "org.eclipse.osgi.supplement");
    buildTree( "org.eclipse.osgi", "osgi/src"      , "res", searchdirs, "org.eclipse.osgi.osgi" );
    buildTree( "org.eclipse.osgi", "core/framework", "res", searchdirs, "org.eclipse.osgi.core.framework");
    buildTree( "org.eclipse.osgi", "supplement/src", "res", null, "org.eclipse.osgi.supplement");
    buildTree( "org.eclipse.osgi", "console/src", "res", null, "org.eclipse.osgi.console");
    buildTree( "org.eclipse.osgi", "core/adaptor", "res", null, "org.eclipse.osgi.core.adaptor");
    buildTree( "org.eclipse.osgi", "defaultAdaptor/src", "res", null, "org.eclipse.osgi.defaultadaptor");
    buildTree( "org.eclipse.osgi", "eclipseAdaptor/src", "res", null, "org.eclipse.osgi.eclipseadaptor");
    buildTree( "org.eclipse.osgi", "jarverifier", "res", null, "org.eclipse.osgi.jarverifier");
    buildTree( "org.eclipse.osgi", "resolver/src", "res", null, "org.eclipse.osgi.resolver");
    buildTree( "org.eclipse.osgi", "security/src", "res", null, "org.eclipse.osgi.security");
    buildTree( "org.eclipse.osgi.services", "src", "res" );
    buildTree( "org.eclipse.equinox.common", "src", "res" );
    buildTree( "org.eclipse.equinox.app", "src", "res" );
    buildTree( "org.eclipse.equinox.preferences", "src", "res" );
    buildTree( "org.eclipse.equinox.registry", "src", "res" );
    buildTree( "org.eclipse.equinox.security", "src", "res" );
};

desc["core"] = "Build Eclipse Core";
task["core"] = {
    buildTree( "com.ibm.icu", "src", "res" );
    buildTree( "org.eclipse.core.runtime", "src", "res" );
    buildTree( "org.eclipse.core.commands", "src", "res" );
    buildTree( "org.eclipse.core.databinding", "src", "res" );
    buildTree( "org.eclipse.core.databinding.beans", "src", "res" );
    buildTree( "org.eclipse.core.jobs", "src", "res" );
};

desc["jface"] = "Build JFace";
task["jface"] = {
    buildTree( "org.eclipse.jface", "src", "res" );
    buildTree( "org.eclipse.jface.databinding", "src", "res" );
};

desc["eclipsetools"] = "Build Eclipse Tools";
task["eclipsetools"] = {
    buildTree( "org.eclipse.tools", "Sleak", "res" );
};

desc["jfacetext"] = "Build JFace.Text";
task["jfacetext"] = {
    buildTree( "org.eclipse.text", "src", "res" );
    buildTree( "org.eclipse.jface.text", "projection", "res", ["-I../src"], "org.eclipse.jface.text.projection" );
    buildTree( "org.eclipse.jface.text", "src", "res" );
};

desc["uiforms"] = "Build UI Forms";
task["uiforms"] = {
    buildTree( "org.eclipse.ui.forms", "src", "res" );
};

desc["draw2d"] = "Build Draw2D";
task["draw2d"] = {
    buildTree( "org.eclipse.draw2d", "src", "res" );
};

desc["all"] = "Build ALL";
dep ["all"] = [ "base", "swt", "equinox", "core", "jface", "jfacetext", "uiforms",
                "draw2d", "swtsnippets", "jfacesnippets" ];
task["all"] = { };

desc  ["swtsnippets"] = "Build SWT Snippet Collection";
taskAg["swtsnippets"] = "explicit_snp";
taskEx["swtsnippets"] = (string explicit_snp) {

    auto libnames = LIBNAMES_BASIC ~ LIBNAMES_SWT;
    auto snps_browser = [ "Snippet128", "Snippet136" ];
    auto snps_opengl = [ "Snippet174", "Snippet195" ];
    auto snps_ole = [ "Snippet81" ];

    string[] snps_exclude;
    static if (isWindows) {
        snps_exclude = snps_browser ~ snps_opengl ~ snps_ole;
    } else {
        snps_exclude = snps_browser ~ snps_opengl ~ snps_ole;
    }

    immutable PREFIX = "Swt";
    if (explicit_snp !is null) {
        auto snpname = explicit_snp;
        writeln("Building swtsnippets[" ~ snpname ~ "]");
        buildApp( "org.eclipse.swt.snippets", "src", "res", [], PREFIX, snpname, null, libnames );
    } else {
        foreach (string snp; .dirEntries(.buildPath("org.eclipse.swt.snippets", "src"), SpanMode.depth)) {
            if (snp.baseName().startsWith("Snippet") && snp.baseName().endsWith(".d")) {
                auto snpname = snp.baseName().stripExtension();
                writeln("Building swtsnippets[" ~ snpname ~ "]");
                if (-1 == .countUntil(snps_exclude, snpname)) {
                    buildApp( "org.eclipse.swt.snippets", "src", "res", [], PREFIX, snpname, null, libnames );
                }
            }
        }
    }
};

desc  ["jfacesnippets"] = "Build JFace Snippet Collection";
taskAg["jfacesnippets"] = "explicit_snp";
taskEx["jfacesnippets"] = (string explicit_snp) {

    immutable PREFIX = "JFace";
    immutable SRCPATH = "EclipseJfaceSnippets";
    immutable BASEPATH = "org.eclipse.jface.snippets";
    auto libnames = LIBNAMES_BASIC ~ LIBNAMES_SWT ~ LIBNAMES_EQUINOX
                    ~ LIBNAMES_CORE ~ LIBNAMES_JFACE ~ LIBNAMES_ICU;
    string[] snps_exclude = [];
    if (explicit_snp !is null) {
        auto snpname = explicit_snp;
        writeln("Building jfacesnippets[" ~ snpname ~ "]");
        buildApp( BASEPATH, SRCPATH, "res", [], PREFIX, explicit_snp, null, libnames );
    } else {
        foreach (string snp; .dirEntries(.buildPath(BASEPATH, SRCPATH), SpanMode.depth)) {
            if (!snp.endsWith(".d")) continue;
            auto snpname = snp.baseName().stripExtension();
            writeln("Building jfacesnippets[" ~ snpname ~ "]");
            if (-1 == .countUntil(snps_exclude, snpname)) {
                buildApp( BASEPATH, SRCPATH, "res", [], PREFIX, snpname, null, libnames );
            }
        }
    }
};


desc  ["bindsnippets"] = "Build JFace Databinding Snippet Collection";
taskAg["bindsnippets"] = "explicit_snp";
taskEx["bindsnippets"] = (string explicit_snp) {

    immutable PREFIX = "Bind";
    immutable SRCPATH = "src";
    immutable BASEPATH = "org.eclipse.jface.examples.databinding";
    auto libnames = LIBNAMES_BASIC ~ LIBNAMES_SWT ~ LIBNAMES_EQUINOX
                    ~ LIBNAMES_CORE ~ LIBNAMES_JFACE ~ LIBNAMES_JFACEBIND
                    ~ LIBNAMES_ICU;
    string[] snps_exclude = [];
    string[] allsnippets;
    foreach (string snp; .dirEntries(.buildPath(BASEPATH, SRCPATH), SpanMode.depth)) {
        if (!snp.endsWith(".d")) continue;
        allsnippets ~= snp;
    }
    auto rmlistadd = true;
    if (explicit_snp !is null) {
        string[] rmlist;
        foreach (string snp; allsnippets) {
            if (!snp.endsWith(".d")) continue;
            auto snpname = snp.baseName().stripExtension();
            if (snpname == explicit_snp) {
                rmlistadd = false;
            }
            if (rmlistadd) {
                rmlist ~= snp;
            }
        }
        foreach (snp; rmlist) {
            allsnippets = std.algorithm.remove(allsnippets, snp);
        }
    }
    foreach (string snp; allsnippets) {
        auto snpname = snp.baseName().stripExtension();
        writeln("Building bindsnippets[" ~ snpname ~ "]");
        if (-1 == .countUntil(snps_exclude, snpname)) {
            buildApp( BASEPATH, SRCPATH, "res", [], PREFIX, snpname, null, libnames );
        }
    }
};


//////////////////////////////////////////////////////////////////////////
// Starts build
//

bool printTasks = false;
bool printHelp = false;
.getopt(args,
    std.getopt.config.passThrough,
    "T|tasks",  &printTasks,
    "h|H|help", &printHelp
);

if (printTasks) {
    // Prints target list.
    size_t len = 0;
    auto tasks = (task.keys ~ taskEx.keys);
    .sort(tasks);
    auto names = new string[tasks.length];
    foreach (i, name; tasks) {
        auto pArg = name in taskAg;
        if (pArg) {
            name ~= "[" ~ *pArg ~ "]";
        }
        len = .max(len, name.length);
        names[i] = name;
    }
    writeln("(in " ~ getcwd() ~ ")");
    foreach (i, name; tasks) {
        writefln("./build %-" ~ .text(len) ~ "s  # %s", names[i], desc[name]);
    }
    return;
}

if (printHelp || args.length == 1) {
    // Prints help.
    writeln("Build script for DWT2");
    writeln("Usage:");
    writeln("  ./build [DEBUG=1] {options} targets...");
    writeln();
    writeln("  -T, --tasks     Print all build tasks and descriptions.");
    writeln("  -h, -H, --help  Print usage of 'build.d'.");
    return;
}


writeln("(in " ~ getcwd() ~ ")");

// The list of build tasks in order by dependency.
string[] taskSeq;
string[string] taskArg; // Argument of build tasks.

// Adds build task to list.
void addTaskSeq(string task) {
    if (-1 == taskSeq.countUntil(task)) {
        taskSeq ~= task;
    }
}
// Adds build task and dependency tasks to list.
void addDepAndTask(string task) {
    auto pDep = task in dep;
    if (pDep) {
        foreach (d; *pDep) {
            addDepAndTask(d);
        }
    }
    addTaskSeq(task);
}
foreach (arg; args[1 .. $]) {
    if (arg[0] == '-') {
        extraOptions ~= arg;
        continue;
    }
    else if (arg in task) {
        // Build task.
        addDepAndTask(arg);
        continue;
    } else if (arg in taskEx) {
        // Build task with argument (is null).
        addDepAndTask(arg);
        taskArg[arg] = null;
        continue;
    } else if (arg == "DEBUG=1") {
        // Enable debug build.
        isDebug = true;
        continue;
    } else {
        auto pi1 = std.string.indexOf(arg, "[");
        auto pi2 = std.string.lastIndexOf(arg, "]");
        if (-1 != pi1 && -1 != pi2 && pi1 < pi2) {
            // Build task with argument.
            auto name = arg[0 .. pi1];
            if (name in taskEx) {
                addDepAndTask(name);
                taskArg[name] = arg[pi1 + 1 .. pi2];
                continue;
            }
            throw new Exception("Unknown build task '" ~ name ~ "'");
        }
    }
    throw new Exception("Unknown build task '" ~ arg ~ "'");
}

// Processing tasks in order.
foreach (t; taskSeq) {
    auto pArg = t in taskArg;
    if (pArg) {
        taskEx[t](*pArg);
    } else {
        task[t]();
    }
}

}
