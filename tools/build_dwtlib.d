/+

 Copyright (C) 2017 by jasc2v8 at yahoo dot com
 License: https://opensource.org/licenses/MIT
 
 Versions:  1.2.1   fix help
            1.2.0   combine java and swt in /src
            1.5.0   add is64bit
            1.4.0   add chdir to work in dwt folder
            1.3.0   fix clean only
            1.2.0   fix cd dwtDir
            1.1.0   check for dwt two levels up
            1.0.0   release

 Description:
 
    Builds the dwtlib static libraries
  
    See showHelp() for command line arguments
  
+/

module dlang.apps.build_dwtlib;

import std.algorithm, std.ascii, std.array;
import std.conv;
import std.file;
import std.path, std.process;
import std.stdio, std.string;

enum SUCCESS=0, ERROR=1;
enum ERR        = "Build_dwtlib ERROR ";

enum dwtDir1    = "dwt";
enum dwtDir2    = ".." ~ dirSeparator ~ "dwt";
enum dwtDir3    = ".." ~ dirSeparator ~ ".." ~ dirSeparator ~"dwt";

string buildArch, buildArgs, cmd, dwtDir;

bool cleanOnly = false;

version (Windows) {
    immutable isWindows = true;
    immutable buildPlatform = "Windows";
} else {
    immutable isWindows = false;
    immutable buildPlatform = "Posix";  //Ubuntu reports "Posix"
}

version (X86_64) {
    immutable is64bit = true;
} else {
    immutable is64bit = false;
}

int main(string[] args) 
{
    //find the dwt folder
    if (dwtDir1.exists) {
        dwtDir = dwtDir1;
    } else if (dwtDir2.exists) {
        dwtDir = dwtDir2;
    } else if (dwtDir3.exists) {
        dwtDir = dwtDir3;
    } else {
        writeln(ERR, "dwt directory not found.");
        return ERROR;
    }
    
    //define paths
    immutable swtImp = "imp";
    immutable swtLib = "lib";
    immutable swtObj = "obj";
    immutable swtRes = "res";
    immutable swtSrc = "src";
    immutable swtStr = "views";

    //if any args, strip off arg[0] and pass args to dwt/build.d
    if (args.length > 1) {
        foreach (arg; args[1 .. $])
            buildArgs ~= arg ~ " ";
    }

    //parse help
    if (buildArgs.canFind("-h")) {
        showHelp();
        return SUCCESS;
    }
    
    //add defaults if missing
    if (!buildArgs.canFind("clean ")) buildArgs ~= "clean ";
    if (!buildArgs.canFind("base " )) buildArgs ~= "base ";
    if (!buildArgs.canFind("swt "  )) buildArgs ~= "swt ";
    
    //parse windows args
    if (isWindows) {
        if (buildArgs.canFind("-m64")) {
            buildArch = "64-bit";
            if (buildArgs.canFind("-m32mscoff")) {
                writeln(ERR~"can't have -m32mscoff with a 64-bit build.");
                return ERROR;
            }
        } else {
            buildArch = "32-bit";
            if (buildArgs.canFind("-m32mscoff")) {
                buildArch = "32-bit and write MS-COFF object files";
            }
        }
    } else {
        if (is64bit) {
            buildArch = "64-bit";
        } else {
            buildArch = "32-bit";
        }
    }
    
    //work in the dwt folder
    chdir(dwtDir);
    writeln("Build_dwtlib working in  : ", getcwd());
    
    //if the only arg is "clean", then clean, else clean and build
    if (args.length == 2 && args[1] == "clean") {
        cleanOnly = true;
        writeln ("Build_dwtlib cleaning");
        cmd = "rdmd build.d clean";
    } else {
        writeln ("Build_dwtlib builiding   : " ~ buildPlatform ~ " " ~ buildArch);
        cmd = "rdmd build.d " ~ buildArgs;
    }
    
    writeln("Build_dwtlib command line: ",cmd);
 
    //spawn cmd
    if (0 != wait(spawnShell(cmd))) {
        throw new Exception(ERR~"spawning cmd.");
    }
	
    if (cleanOnly) {

        if (swtImp.exists) rmdirRecurse(swtImp);
        if (swtLib.exists) rmdirRecurse(swtLib);
        if (swtObj.exists) rmdirRecurse(swtObj);
        if (swtRes.exists) rmdirRecurse(swtRes);
        if (swtSrc.exists) rmdirRecurse(swtSrc);
        if (swtStr.exists) rmdirRecurse(swtStr);
        
        if (".git".exists) rmdirRecurse(".git");
        if (".gitattributes".exists) std.file.remove(".gitattributes");
        if (".gitignore".exists) std.file.remove(".gitignore");
        if (".gitmodules".exists) std.file.remove(".gitmodules");
        
    } else {
    
        writeln("Build_dwtlib creating dwtlib folder structure");
        
        //remove old dirs, if present
        if (swtSrc.exists) rmdirRecurse(swtSrc);
        if (swtStr.exists) rmdirRecurse(swtStr);
        
        //create new dirs
        mkdir(swtSrc);
        mkdir(swtStr);

        //copy files
        copyFolder("res", "*.properties", "views");
        copyFolder("base/src/java", "*.d", "src/java");
        if (isWindows) {
            copyFolder("org.eclipse.swt.win32.win32.x86/src", "*.d", "src");
        } else {
            copyFolder("org.eclipse.swt.gtk.linux.x86/src"  , "*.d", "src");
        }
        
        //cleanup
        if (swtImp.exists)  rmdirRecurse(swtImp);
        if (swtObj.exists)  rmdirRecurse(swtObj);
        if (swtRes.exists)  rmdirRecurse(swtRes);
        
    }
    
    //finished
    writeln("Build_dwtlib finished.");

	return SUCCESS;

}

int copyFolder(string sourceFolder, string pattern, string targetFolder) {

    foreach (string file; dirEntries(sourceFolder, pattern, SpanMode.depth).filter!(a => a.isFile))
    {
        //append source path as subdir to target path
        string targetPath = targetFolder ~ file[sourceFolder.length .. $];
        mkdirRecurse(targetPath.dirName);
        copy(file, targetPath);
    }
    
    return SUCCESS;
}

string fixPath(string path) {
    if (isWindows) {
        return path.replace( "/", "\\" );
    } else {
        return path;
    }
}

void showHelp()
{

string helpText = `

  Executes the DWT build.d file to build the dwtlib static libraries 'base' and 'swt'

    Usage: rdmd ./build_dwtlib.d [-h|--help] [clean] [base] [swt] [-m64] [-m32mscoff]
    
    Copies DWT files to dwtlib files as follows:
  
        ./src/base	base (java) *.d source import files
        ./src/swt   swt *.d source import files
        ./views     swt *.properties string import files
        ./lib       dwt static libraries, differs by platform and arch	
`;
    writeln(helpText);
}
