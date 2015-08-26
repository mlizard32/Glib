module Glib.System.Log;

import std.stdio;
import std.file;

struct Log
{
	/// Use these options to specify logging levels.
	enum Level
	{	INFO, /// 
	WARN, /// ditto
	ERROR, /// ditto
	TRACE /// ditto
	}

	enum Output
	{	CONSOLE = 1, ///
	FILE = 2 /// ditto
	}
	

	static Level level = Level.INFO; /// Only logs of this level or greater will be written.
	static uint output = Output.CONSOLE | Output.FILE; /// Specify where to log.
	static string filePath = "log.txt"; /// If output includes File, write to this file.
	private static bool firstRun = true;

	/**
	* Write to the log.  Arguments are the same as std.stdio.writefln in Phobos.
	* Returns true if the output settings allowed anything to be written. */
	static bool info(string msg)
	{	return internalWrite(Level.INFO, msg);
	}

	/// ditto
	static bool warn(string msg)
	{	return internalWrite(Level.WARN, msg);
	}

	/// ditto
	static bool error(string msg)
	{	return internalWrite(Level.ERROR, msg);
	}

	/// ditto
	static bool write(string msg)
	{	return internalWrite(Level.TRACE, msg);
	}

	/// Recursively print a data structure.
	//static void dump(T)(T t)
	//{	write(Json.encode(t));
	//}


	private static bool internalWrite(Level level, string msg)
	{
		if ((level >= this.level) && output)
		{	
			synchronized(typeid(Log))
			{	
				if (output & Output.CONSOLE)				
				{	try {
					writeln(msg ~ "\n");
				} catch (Exception e) {}
				}
				if (output & Output.FILE)
				{	try {
					remove(filePath);
					auto f = File(filePath, "w");
					if (firstRun)
					{
						f.writeln( msg ~ "\r\n");
						firstRun = false;
					}
					else
						f.writeln(msg ~ "\r\n");	
				} catch (Exception e) { // If can't write to file, notify on the console
					if (output & Output.CONSOLE)
						writeln(e.toString() ~ "\r\n");
					output ^= Output.FILE;
				}
				}
				return cast(bool)output;
			}
		}
		return false;
	}
}
