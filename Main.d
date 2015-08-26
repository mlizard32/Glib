module Main;

import gl3n.linalg;

import GLib.window;
import Glib.System;
import Glib.Input;
import Glib.Scene;
import Glib.Font;
import Glib.FontTwo;
import Glib.Log;
import Glib.Model;
import Glib.Camera;
import Glib.Transform;
import Glib.GObject;

import derelict.assimp.assimp;
import derelict.opengl3.gl3;
import derelict.util.loader;
import derelict.sdl2.sdl;
import derelict.freetype.ft;
import derelict.util.exception;
import derelict.sdl2.image;

//import std.File;
import core.stdc.stdio;

pragma(lib, "DerelictASSIMP.lib");
pragma(lib, "DerelictFT.lib");
pragma(lib, "DerelictGL3.lib");
pragma(lib, "DerelictUtil.lib");


vec3[] verts;
vec3i[] indices;

int main()
{	
	System.init();
	Input input = new Input();
	
	try
	{
		DerelictFT.load();
		DerelictASSIMP.load();
	}
	catch(DerelictException de)
	{
		Log.error("Derelict failed to load: " ~ de.toString);
	}
	
	Model myTestModel = new Model("C:\\Users\\qtg843\\Documents\\Visual Studio 2012\\Projects\\Glib\\resources\\suzanne.obj");
	
	window w = new window();
	w.SetResolution(720, 445, 0, false, 0);
	System.currentWindow = w;
	Scene scene = new Scene();


	GObject gtest = new GObject(scene);
	gtest.transform.local_Position = vec3(0,0,1);
	GObject gtest2 = new GObject(gtest);
	vec3 vtest = gtest2.transform.local_Position;
	vtest = gtest2.transform.world_Position;
	gtest2.transform.world_Position(vec3(2, 0, 0));
	vtest = gtest2.transform.world_Position;
	vtest = gtest2.transform.local_Position;
	gtest2.transform.local_Position(vec3(0,0,0));
	vtest = gtest2.transform.world_Position;
	//quat q = quat.euler_rotation(0,0,90);
	//Log.info(to!string(q.yaw));
//Log.info(to!string(q.pitch));
//Log.info(to!string(q.roll));
	gtest.transform.world_Rotation(vec3(0,0,90));
	vtest = gtest.transform.world_Rotation;
	vtest = gtest2.transform.world_Rotation;
	vtest = gtest2.transform.local_Rotation;
	//********************************
	
	
	// Enable depth test
	glEnable(GL_DEPTH_TEST);
	//glEnable(GL_BLEND);
	//glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    glEnable(GL_TEXTURE_2D);
	// Accept fragment if it closer to the camera than the former one
	glDepthFunc(GL_LESS); 

	// Cull triangles which normal is not towards the camera
	glEnable(GL_CULL_FACE);

	glClearColor(0.0f, 0.0f, 0.3f, 0.0f);


	GLuint fontPID = GhettoLoadShaders("C:\\Users\\qtg843\\Documents\\Visual Studio 2012\\Projects\\Glib\\resources\\text.vertexshader"
									   ,"C:\\Users\\qtg843\\Documents\\Visual Studio 2012\\Projects\\Glib\\resources\\text.fragmentshader");

	FontTwo newFont = new FontTwo(fontPID, 24, "arial.ttf");

	GLuint programID;
	foreach(mesh; myTestModel.meshes)
	{
		if(!mesh.BindMesh())
			Log.error("error binding mesh");
		programID = mesh.shader.programID;
	}

	Camera camera = new Camera();

	glUseProgram(programID);

	GLuint MatrixID = glGetUniformLocation(programID, "MVP");
	GLuint ViewMatrixID = glGetUniformLocation(programID, "V");
	GLuint ModelMatrixID = glGetUniformLocation(programID, "M");

	GLuint Texture = initTex();
	GLuint TextureID  = glGetUniformLocation(programID, "myTextureSampler");

	GLuint lightID = glGetUniformLocation(programID, "LightPosition_worldspace");

	GLenum error = glGetError();
	if(error != GL_NO_ERROR)
		System.active = false;

	double lastTime = SDL_GetTicks();
	int numFrames = 0;
	string fps = "0";
	while(System.active)
	{
		// Clear the screen
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

		input.pollInput();
		if(input.mouse.leftButton)
			camera.updateCameraControls(input.mouse.Position.x, input.mouse.Position.y);
		//Log.info("test" ~ to!string(input.mouse.Position.x) ~ ": " ~ to!string(input.mouse.Position.y));
		glUseProgram(programID);

		mat4 projection = camera.getPerspeciveMatrix();

		mat4 view = camera.getViewMatrix();

		mat4 model = mat4.identity();
	
		mat4 MVP = projection * view * model;


		glUniformMatrix4fv(MatrixID, 1, GL_TRUE, MVP.value_ptr);
		glUniformMatrix4fv(ModelMatrixID, 1, GL_TRUE, model.value_ptr);
		glUniformMatrix4fv(ViewMatrixID, 1, GL_TRUE, view.value_ptr);

		vec3 lightPos = vec3(4,4,4);
		glUniform3f(lightID, lightPos.x, lightPos.y, lightPos.z);

		// Bind our texture in Texture Unit 0
		glActiveTexture(GL_TEXTURE0);
		glBindTexture(GL_TEXTURE_2D, Texture);
		// Set our "myTextureSampler" sampler to user Texture Unit 0
		glUniform1i(TextureID, 0);

		foreach(mesh; myTestModel.meshes)
		{
			mesh.Draw();
		}

		double currentTime = SDL_GetTicks();
		numFrames++;

		//glBindTexture(GL_TEXTURE_2D, 0);
		//glActiveTexture(0);
		

//FPS Counter
		if(currentTime -lastTime >= 1000.0)
		{
			fps = to!string(numFrames);
			numFrames = 0;
			lastTime = currentTime;
		}

		glUseProgram(fontPID);
		
		float sx = 2.0 / 720.0;
		float sy = 2.0 / 445.0;
		newFont.render_text(fps, -1 + 8 * sx, 1 - 50 * sy, sx, sy);
//End FPS Counter
		
		SDL_GL_SwapWindow(System.currentWindow.sdlWindow);

		if(error != GL_NO_ERROR)
			System.active = false;

	}

	glDeleteTextures(1, &Texture);
	
	System.deInit();
	DerelictASSIMP.unload();
	return 0;
}

GLuint initTex(){ 
	SDL_Surface *s=IMG_Load("suzanne_uvmap.png"); 
	assert(s); 

	GLuint tid;

	glGenTextures(1, &tid); 
	assert(tid > 0); 
	glBindTexture(GL_TEXTURE_2D, tid); 

	glPixelStorei(GL_UNPACK_ALIGNMENT, 1); 

	int mode = GL_RGB; 
	if(s.format.BytesPerPixel == 4) mode=GL_RGBA; 

	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );

	//glTexImage2D(GL_TEXTURE_2D, 0, s.format.BytesPerPixel, s.w, s.h, 0, mode, GL_UNSIGNED_BYTE, flip(s).pixels); 
	glTexImage2D(GL_TEXTURE_2D, 0, s.format.BytesPerPixel, s.w, s.h, 0, mode, GL_UNSIGNED_BYTE, s.pixels); 

	SDL_FreeSurface(s); 
	return tid; 
} 

GLuint GhettoLoadShaders(string vertex_file_path, string fragment_file_path)
{
	GLuint vertexShaderID = glCreateShader(GL_VERTEX_SHADER);
	GLuint fragmentShaderID = glCreateShader(GL_FRAGMENT_SHADER);

	// Read the vertex shader code from file
	string vertexShaderCode;
	auto f = std.stdio.File(vertex_file_path, "r");
	char[] line;
	while(f.readln(line))
	{
		vertexShaderCode ~= "\n" ~ line;
	}

	// Read the fragment shader code form file

	string fragmentShaderCode;
	f = std.stdio.File(fragment_file_path, "r");
	while(f.readln(line))
	{
		fragmentShaderCode ~= "\n" ~ line;
	}


	GLint result = GL_FALSE;
	GLint infoLogLength;

	const char[] cstr = vertexShaderCode.dup;
	const char* vertexSourcePointer = cstr.ptr;
	//compile vertex shader
	glShaderSource(vertexShaderID, 1, &vertexSourcePointer, null);
	glCompileShader(vertexShaderID);

	glGetShaderiv(vertexShaderID, GL_COMPILE_STATUS, &result);
	glGetShaderiv(vertexShaderID, GL_INFO_LOG_LENGTH, &infoLogLength);


	if(result == GL_FALSE)
	{
		char[] vertexShaderErrorMessage;
		vertexShaderErrorMessage.length = infoLogLength + 1;
		glGetShaderInfoLog(vertexShaderID, infoLogLength, null, vertexShaderErrorMessage.ptr);
		infoLogLength = 0;
		printf("%s\n", &vertexShaderErrorMessage[0]);
	}


	//Compile Fragment Shader
	const char[] cfstr = fragmentShaderCode.dup;
	const char* fragmentSourcePointer = cfstr.ptr;
	//compile vertex shader
	glShaderSource(fragmentShaderID, 1, &fragmentSourcePointer, null);
	glCompileShader(fragmentShaderID);

	glGetShaderiv(fragmentShaderID, GL_COMPILE_STATUS, &result);
	glGetShaderiv(fragmentShaderID, GL_INFO_LOG_LENGTH, &infoLogLength);

	if(result == GL_FALSE)
	{
		char[] fragmentShaderErrorMessage;
		fragmentShaderErrorMessage.length = infoLogLength + 1;
		glGetShaderInfoLog(fragmentShaderID, infoLogLength, null, &fragmentShaderErrorMessage[0]);
		printf("%s\n", &fragmentShaderErrorMessage[0]);
		infoLogLength = 0;
	}
	//Link Program

	GLuint programID = glCreateProgram();
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
		printf("%s\n", &programErrorMessage[0]);
		infoLogLength = 0;
	}

	glDeleteShader(vertexShaderID);
	glDeleteShader(fragmentShaderID);

	return programID;
}