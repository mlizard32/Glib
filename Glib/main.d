import std.stdio;
import Glib.System;
import Glib.Scene;
import derelict.opengl3.gl3;

import derelict.sdl2.image;
import derelict.sdl2.sdl;
import imgui;

int sW = 720;
int sH = 480;

int main(string[] argv)
{
	System.init();
	

	window w = new window();
	w.SetResolution(sW, sH);
	string fontPath = "..\\..\\resources\\DroidSans.ttf";
	imguiInit(fontPath);
	Scene s = new Scene();
	
	//"..\\..\\resources\\suzanne.obj"
	//Model model = new Model("..\\..\\resources\\suzanne.obj");
	PrimitiveObject model = new PrimitiveObject(PrimitiveObject.PrimitiveTypes.Sphere);

	GObject monkey = new GObject();
	monkey.components ~= model;

	Render renderer;

	const( char )* verstr = glGetString( GL_VERSION );
	char major = *verstr;
	char minor = *( verstr + 2 );

	renderer.initializeFrameBuffer(w.size.x, w.size.y);

	GLenum error = glGetError();
	if(error != GL_NO_ERROR)
		System.active = false;
	while(System.active)
	{
		Input.pollInput();

		renderer.rScene(s, w);

		w.SwapWindow();

		error = glGetError();
		if(error != GL_NO_ERROR)
			System.active = false;
	}

	System.deInit();
	imguiDestroy();
    writeln("Hello D-World!");
    return 0;
}

//temporary
GLuint initTex(){ 
	SDL_Surface *s=IMG_Load("..\\..\\resources\\Gray.png"); 
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