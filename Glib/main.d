import std.stdio;
import Glib.System;
import Glib.Scene;
import derelict.opengl3.gl3;

import derelict.sdl2.image;
import derelict.sdl2.sdl;
import imgui;
import gl3n.linalg;

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
	
	Log.info("test");
	//"..\\..\\resources\\suzanne.obj"
	Model model = new Model("..\\..\\resources\\suzanne.obj");
	PrimitiveObject sphere = new PrimitiveObject(PrimitiveObject.PrimitiveTypes.Sphere);

	GObject monkey = new GObject();
	//monkey.components ~= model;
	monkey.AttachComponent(model);
	

	GObject gSphere = new GObject();
	gSphere.AttachComponent(sphere);
	gSphere.transform.local_Position(vec3(2, 0, 0));
	gSphere.transform.local_Scale(vec3(.5f, .5f, .5f));

	monkey.addChild(gSphere);

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
		monkey.transform.local_Rotation(monkey.transform.local_Rotation_quat.rotatey(.05f));

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