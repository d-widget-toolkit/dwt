require 'find'
require 'fileutils'
require 'set'

def ProcessModule( path, modName, modList )
    puts "ProcessModule #{path}"
    identifiers = Set.new
    File.open(path).each_line do |s|
        if s =~ /^[ \t]*\*/ then
            next
        end
        s.split( /[^0-9A-Za-z_]/ ).each do |tok|
            if tok =~ /^[_A-Z][_A-Za-z0-9]*$/ then
                identifiers << tok
            end
        end
    end
    lines = IO.readlines(path)
    w=File.new(path,"wb+")
    lines.each do |s|
        if s =~/\/\/ packageimport$/ then
        else
            w.print "#{s}"
        end
        if s =~ /^module +((([a-zA-Z0-9_]+)\.)*)([a-zA-Z0-9_]+);/ then
            packname = $1
            (modList-modName).intersection(identifiers).each do|id|
                w.print "import #{packname}#{id};\n"
            end
        end
    end
end

def ProcessDirectory( path )
    puts path
    modList = Set.new
    Dir.foreach(path) do |entry|
        filename = File.join(path,entry)
        if FileTest.file?(filename) && filename =~ /\.d$/ then
            modList << entry[ 0 .. -3 ]
        end
    end
    Dir.foreach(path) do |entry|
        filename = File.join(path,entry)
        if FileTest.file?(filename) && filename =~ /\.d$/ then
            ProcessModule( filename, entry[ 0 .. -3 ], modList )
        end
    end
end

ARGV.each do|startpath|
    puts "processing #{startpath}"
    if !FileTest.directory?(startpath) then
        raise "Argument is not a directory"
    end
    Find.find( startpath ) do |path|
        if FileTest.directory?(path) then
            ProcessDirectory(path)
        end
    end
end

