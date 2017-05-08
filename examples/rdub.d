/+

 Copyright (C) 2017 by jasc2v8 at yahoo dot com
 License: https://opensource.org/licenses/MIT
 
 Version: 1.1.1 added ERR

    rdub is a front end for DUB, a D language build tool

    Refer to showHelp() below.

+/

module dlang.apps.rdub;

import std.ascii;
import std.conv;
import std.file;
import std.path, std.process;
import std.stdio, std.string;

enum SUCCESS=0, ERROR=1;
enum ERR       = "rdub ERROR ";
enum srcDir    = "src";
enum srcApp    = "src"    ~ dirSeparator ~ "app.d";
enum sourceApp = "source" ~ dirSeparator ~ "app.d";

string[] files, flags, dubFlags;
string dubArgs, rdubArgs;
string sourceFile, targetFile;

bool helpFlag, yesFlag;

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
	
	//check option flags and strip from the command line so they are not passed as dub args
	//incidently, this will also detect --help and --yes
	for (int i; i < flags.length; i++)
	{
		if ( indexOf(flags[i], "-h") != -1 ) {
			helpFlag = true;
		} else if ( indexOf(flags[i], "-y") != -1 ) {
			yesFlag = true;
		} else {
			dubFlags ~= flags[i];
		}
	}

	//show help
	if (helpFlag) {
		showHelp();
		return SUCCESS;
	}
	
	//if more than 1 file as arg, error
	if ( files.length > 1 ) {
		writeln(ERR~"only one 1 file allowed");
		return ERROR;
	}

	//if no file as arg, use default
	if ( files.length == 0 ) {
	
		if (srcApp.exists) {
			files ~= srcApp;	
		} else if (sourceApp.exists) {
			files ~= sourceApp;	
		} else {
			writeln(ERR ~ srcApp ~ " or " ~ sourceApp ~ " not found");
			return ERROR;
		}
		
	} else {

		//if no extension, add .d
		sourceFile = files[0];
		if (sourceFile.extension == "") sourceFile ~= ".d";
		
		//exists?
		if (!sourceFile.exists) {
			writeln(ERR~"file not found: " ~ sourceFile);
			return ERROR;
		}
		
		//is main?
		if (!sourceFile.isMain) {
			writeln(ERR~"file not main(): " ~ sourceFile);
			return ERROR;
		}
		
		//if src exists and yes flag, remove
		if (srcDir.exists) {
			if (yesFlag) {
				rmdirRecurse(srcDir);			
			} else {
				writeln("rdub WARNING src folder exists, use --yes to overwrite");
				return SUCCESS;
			}
		}

		//mkdir src and copy \path\foo.d \src\foo.d
		mkdir(srcDir);
		targetFile = srcDir ~ dirSeparator ~ baseName(sourceFile);
		copy(sourceFile, targetFile);

	}
		
	//form args to pass to dub command line
	foreach (f; dubFlags)
		dubArgs ~= f ~ " ";

	//run dub with args passed from the rdub command line
	string cmd = "dub " ~ dubArgs;

	int returnCode = doPipeShell(cmd);
	
	if (returnCode == ERROR)
	{
		writeln(ERR~"pipe shell error code: ", returnCode);
	}
	
	return SUCCESS;

}

bool isMain(string filePath) {
	string line;
	
	if ( filePath.exists )
	{
		try
	    {
	        auto file = File(filePath, "r");
	        while ((line = file.readln()) !is null)
	        {
				if (indexOf(line.removechars(whitespace), "main(") != -1) {
					return true;
				}
	        }
	    }
	    catch (FileException ex)
	    {
	        writeln("ERROR reading file: ", filePath);
	    }
	}
	return false;
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

  rdub [-y] [-h] /path/source[.d] [dub args]

  -y    --yes  Overwrite ./src/*.*
  -h    --help This help information

  rdub            = run dub with defaults ./src/app.d or ./source/app.d
	
  rdub path/foo.d = run dub as follows:
	
  1. Copy /path/foo.d to ./src/foo.d
  2. Ask before deleting all other files in ./src to avoid more than 1 main()
  2. Run dub to build and run ./src/foo.d
  3. Pass all [dub args] to dub, except: -h or -y
	
  Requires: dub.json or dub.sdl must have name "yourexename" and targetType "executable"
	
`;

    writeln(helpText);

}
