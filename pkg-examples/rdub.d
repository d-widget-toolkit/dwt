/+

 Copyright (C) 2017 by jasc2v8 at yahoo dot com
 License: https://opensource.org/licenses/MIT
 
 Version: 2.0.0 accepts mutiple files on command line or wildcard path/*.d

	rdub is a front end for DUB, a D language build tool

    Refer to showHelp() below.

+/

module dlang.apps.rdub;

import std.ascii;
import std.conv;
import std.file; 
import std.path;
import std.process;
import std.stdio;
import std.string;

enum ERR             = "rdub ERROR ";
enum srcDir          = "src";
enum sourceDir       = "source";
enum srcDirBackup    = srcDir ~ "_bak";
enum sourceDirBackup = sourceDir ~ "_bak";
enum SUCCESS=0, ERROR=1;

string[] files, flags, dubFlags;
string dubArgs;
string sourceFile, targetFile;

int main(string[] args)
{

	//get files and flags, ignore arg[0] which is this exe
	for (int i=1; i < args.length; i++) {
		if ( args[i].startsWith("-") ) {
			flags ~= args[i];
		} else {
			if (args[i] !="") files ~= args[i];  //.bat files could pass empty args
		}
	}
	
	//check option flags and strip so they are not passed as dub args
	//this will detect both -h and --help
	for (int i; i < flags.length; i++)
	{
		if ( indexOf(flags[i], "-h") != -1 ) {
			showHelp();
			return SUCCESS;
		} else if ( indexOf(flags[i], "-DISABLE") != -1 ) {
			//yesFlag = true;
		} else {
			dubFlags ~= flags[i];
		}
	}

	if ( files.length == 0 ) {
	
		//if no files given, dub will use defaults src\app.d, source\app.d
		
	} else {

		if (srcDir.exists && !srcDirBackup.exists) {
			std.file.rename (srcDir, srcDirBackup);
		}

		if (sourceDir.exists && !sourceDirBackup.exists) {
			std.file.rename (sourceDir, sourceDirBackup);
		}
		
		//remove the src folder and all files
		if (srcDir.exists) rmdirRecurse(srcDir);

		//create a new src folder
		mkdir(srcDir);

		foreach (f; files) {
			if (f.indexOf("*") != -1) {
			
				copyWild(f, srcDir);
				
			} else {

				//default is .d file
				if (f.extension == "") f ~= ".d";
				
				//if exists copy else error
				if (f.exists) {
					copyFile(f, buildPath(srcDir, f.baseName));
				} else {
					writeln(ERR~"file not found: " ~ f);
					return ERROR;
				}
			}
		}
	}
		
	//form args to pass to dub command line
	foreach (f; dubFlags)
		dubArgs ~= f ~ " ";

	//run dub with args passed from the rdub command line
	string cmd = "dub " ~ dubArgs;

	int returnCode = doPipeShell(cmd);
	
	if (returnCode == ERROR) {
		writeln(ERR~"pipe shell error code: ", returnCode);
	}
	
	return SUCCESS;

}

void copyWild(string sourceFiles, string srcDir) {

	string path = sourceFiles.dirName;
	
    foreach (string file; dirName(sourceFiles).dirEntries(SpanMode.shallow))
//    foreach (string file; path.dirEntries(SpanMode.shallow))
	{
        if (file.isFile() && file.endsWith(".d")) {
			copyFile(file, buildPath(srcDir, file.baseName));
        }
    }
}

void copyFile(string sourceFile, string targetFile) {
		writeln("rdub copy ", sourceFile, " to ",targetFile);
		copy(sourceFile, targetFile);
}

int doPipeShell(string cmd) {
	
	int returnCode = 0;
	
	auto pipes = pipeShell(cmd, Redirect.stdout | Redirect.stderr, null, Config.suppressConsole);
	
	scope(exit) {
	    wait(pipes.pid);
	}
	
	foreach (line; pipes.stdout.byLine) {
	    writeln(to!string(line));	
	}
	
	foreach (line; pipes.stderr.byLine) {
	    writeln(to!string(line));
	    returnCode = 1;
	}
	
	return returnCode;
}

void showHelp()
{

string helpText = `
	
  rdub is a front end for DUB, a D language build tool

  rdub [-h] [path/foo.d ... path/fooN.d] | [path/*.d] [dub args]

  -h    --help This help information

  rdub            = run dub with defaults ./src/app.d or ./source/app.d
	
  rdub path/foo.d = run dub as follows:
	
  1. If first run, copy src to src_bak, and source to source_bak
  2. Delete src/* and source/* to avoid more than one main() file
  3. Copy path/foo.d to ./src/foo.d
  4. Run dub to build and run ./src/foo.d
  5. Pass all [dub args] to dub, except: -h
	
  Requires: dub.json or dub.sdl must have
            name "yourexename" and targetType "executable"
	
`;

    writeln(helpText);

}
