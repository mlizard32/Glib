module Glib.Shader;

import derelict.opengl3.gl3;
import Glib.Log;
import std.conv;

class Shader
{
	static const defaultVertShader = "C:\\Users\\qtg843\\Documents\\Visual Studio 2012\\Projects\\Glib\\resources\\StandardShading.vertexshader";
	static const defaultFragShader = "C:\\Users\\qtg843\\Documents\\Visual Studio 2012\\Projects\\Glib\\resources\\StandardShading.fragmentshader";
	string vertSource;
	string fragSource;

	GLuint programID;

	char[] cstr;
	char[] cfstr;
	this(string vertexSourcePath, string fragmentSourcePath)
	{
		auto f = std.stdio.File(vertexSourcePath, "r");
		char[] line;
		while(f.readln(line))
		{
			vertSource ~= "\n" ~ line;
		}

		// Read the fragment shader code form file
		f = std.stdio.File(fragmentSourcePath, "r");
		while(f.readln(line))
		{
			fragSource ~= "\n" ~ line;
		}
	}

	this()
	{
		auto f = std.stdio.File(defaultVertShader, "r");
		char[] line;
		while(f.readln(line))
		{
			vertSource ~= "\n" ~ line;
		}

		// Read the fragment shader code form file
		f = std.stdio.File(defaultFragShader, "r");
		while(f.readln(line))
		{
			fragSource ~= "\n" ~ line;
		}
	}
	~this()
	{
		glDeleteProgram(programID);
	}
	GLuint LoadShader()
	{
		GLuint vertexShaderID = glCreateShader(GL_VERTEX_SHADER);
		GLuint fragmentShaderID = glCreateShader(GL_FRAGMENT_SHADER);

		GLint result = GL_FALSE;
		GLint infoLogLength;

		cstr = vertSource.dup;
		const char* vertexSourcePointer = cstr.ptr;
		const int vSourceLength = vertSource.length;
		//compile vertex shader
		glShaderSource(vertexShaderID, 1, &vertexSourcePointer, &vSourceLength);
		glCompileShader(vertexShaderID);

		glGetShaderiv(vertexShaderID, GL_COMPILE_STATUS, &result);
		glGetShaderiv(vertexShaderID, GL_INFO_LOG_LENGTH, &infoLogLength);


		if(result == GL_FALSE)
		{
			char[] vertexShaderErrorMessage;
			vertexShaderErrorMessage.length = infoLogLength + 1;
			glGetShaderInfoLog(vertexShaderID, infoLogLength, null, vertexShaderErrorMessage.ptr);
			infoLogLength = 0;
			Log.error(to!string(&vertexShaderErrorMessage[0]));
		}


		//Compile Fragment Shader
		cfstr = fragSource.dup;
		const char* fragmentSourcePointer = cfstr.ptr;
		const int fSourceLength = fragSource.length;
		//compile vertex shader
		glShaderSource(fragmentShaderID, 1, &fragmentSourcePointer, &fSourceLength);
		glCompileShader(fragmentShaderID);

		glGetShaderiv(fragmentShaderID, GL_COMPILE_STATUS, &result);
		glGetShaderiv(fragmentShaderID, GL_INFO_LOG_LENGTH, &infoLogLength);

		if(result == GL_FALSE)
		{
			char[] fragmentShaderErrorMessage;
			fragmentShaderErrorMessage.length = infoLogLength + 1;
			glGetShaderInfoLog(fragmentShaderID, infoLogLength, null, &fragmentShaderErrorMessage[0]);
			Log.error(to!string(&fragmentShaderErrorMessage[0]));
			infoLogLength = 0;
		}
		//Link Program

		programID = glCreateProgram();
		glAttachShader(programID, vertexShaderID);
		glAttachShader(programID, fragmentShaderID);
		glLinkProgram(programID);

		glGetProgramiv(programID, GL_LINK_STATUS, &result);
		glGetProgramiv(programID, GL_INFO_LOG_LENGTH, &infoLogLength);
		if(result == GL_FALSE)
		{
			char[] programErrorMessage;
			programErrorMessage.length = infoLogLength + 1;
			glGetProgramInfoLog(programID, infoLogLength, null, &programErrorMessage[0]);
			Log.error(to!string(&programErrorMessage[0]));
			infoLogLength = 0;
		}

		glDeleteShader(vertexShaderID);
		glDeleteShader(fragmentShaderID);


		GLuint returnval = programID;
		return returnval;
	}
}