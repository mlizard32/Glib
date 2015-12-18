module Glib.System.System;

import derelict.sdl2.sdl;
import derelict.sdl2.image;
//import derelict.alure.alure;
import derelict.util.loader;
import derelict.util.exception;
import derelict.freeimage.freeimage;
import derelict.assimp3.assimp;
import derelict.opengl3.gl3;

import Glib.System.Window;
import Glib.Scene.Scene;

pragma(lib, "DerelictSDL2.lib");
pragma(lib, "DerelictFI.lib");
//pragma(lib, "DerelictALURE.lib");
pragma(lib, "DerelictUtil.lib");
pragma(lib, "DerelictASSIMP3.lib");
pragma(lib, "DerelictGL3.lib");

abstract class System
{
	static bool active = false;		// true if between a call to init and deinit, inclusive
	protected static bool initialized=false;	// true if between a call to init and deinit, exclusive
	protected static bool aborted = false; 		// this flag is set when the engine is ready to exit.

	static window[] windows;
	static window currentWindow; 

	static Scene[] scenes;
	static Scene currentScene;

	static void init()
	{	
		if(!initialized)
		{
			active = true;

			// load shared libraries (should these be loaded lazily?)
			// Currently DerelictGL and DerelcitGLU are loaded in Window's constructor.
			try{
				DerelictFI.load("..//..//Libs//FreeImage.dll");
				//DerelictFI.load();
				FreeImage_Initialise();
				DerelictSDL2.load("..//..//Libs//SDL2.dll");
				DerelictSDL2Image.load("..//..//Libs//SDL2_image.dll");
				DerelictASSIMP3.load("..//..//Libs//Assimp32.dll");
				DerelictGL3.load();
			}
			catch(DerelictException de)
			{
				string test = de.msg;
				throw de;
			}
	//Breaking ?
	//		DerelictALURE.load();
			//Libraries.loadVorbis();
			//Libraries.loadFreeType();

			// Create OpenAL device, context, and start sound processing thread.
			//SoundContext.init();

			initialized = true;
			//Log.info("initialized successfully.");
		}
	}

	static void deInit()
	{
		SDL_Quit();
		DerelictSDL2.unload();
		DerelictSDL2Image.unload();
		DerelictASSIMP3.unload();
		FreeImage_DeInitialise();
		DerelictFI.unload();
	}
	/*
	static void deInit()
	{	assert(isSystemThread());

		initialized = false;

		SDL_WM_GrabInput(SDL_GRAB_OFF);
		SDL_ShowCursor(true);

		SoundContext.deInit(); // stop the sound thread

		foreach_reverse (s; Scene.getAllScenes().values)
			s.dispose();

		Render.cleanup(0); // textures, vbo's, and other OpenGL resources	

		ResourceManager.dispose();

		if (Window.getInstance())
			Window.getInstance().dispose();

		// TODO: This shouldn't be needed to force any calls to dispose.
		//GC.collect(); // Crashes when called in debug mode

		SDL_Quit();
		DerelictSDL.unload();
		DerelictSDLImage.unload();
		DerelictAL.unload();
		Libraries.loadVorbis(false);
		Libraries.loadFreeType(false);
		active = false;
		Log.info("Yage has been de-initialized successfully.");
	}
	*/

}