module Glib.System.Window;

import derelict.opengl3.gl3;
import derelict.sdl2.sdl;
import gl3n.linalg;
import std.conv;
import Glib.System.System;


pragma(lib, "DerelictSDL2.lib");
pragma(lib, "gl3n.lib");

class window
{
	vec2i size;
	bool fullscreen;
	static bool loaded;
	SDL_Window* sdlWindow;
	uint windowID;
	SDL_GLContext glcontext;

	this()
	{
		if (!loaded)
		{
			
		
			if(SDL_Init(SDL_INIT_VIDEO) < 0)
			{
			//throw exception
			}
			loaded = true;
		}
	}
	~this()
	{
		SDL_GL_DeleteContext(glcontext);
	}

	void ResizeWindow(SDL_Event event)
	{
		size.x = event.window.data1;
		size.y = event.window.data2;

		glViewport(0,0, cast(GLsizei)size.x, cast(GLsizei)size.y);
	}

	void UpdateWindow(SDL_Event event)
	{
		if(event.window.windowID == windowID)
		{
			switch(event.window.event)
			{
				case SDL_WINDOWEVENT_SIZE_CHANGED:  
					ResizeWindow(event);
					break;

				case SDL_WINDOWEVENT_CLOSE:  
					if(System.windows.length <= 1)
					{
						event.type = SDL_QUIT;
						SDL_PushEvent(&event);
					}
					SDL_DestroyWindow(sdlWindow);
					break;

				case SDL_WINDOWEVENT_SHOWN:
					//SDL_Log("Window %d shown", event->window.windowID);
					break;

				case SDL_WINDOWEVENT_HIDDEN:
					//SDL_Log("Window %d hidden", event->window.windowID);
					break;

				case SDL_WINDOWEVENT_EXPOSED:
					//SDL_Log("Window %d exposed", event->window.windowID);
					break;

				case SDL_WINDOWEVENT_MOVED:
					//SDL_Log("Window %d moved to %d,%d",
					//		event->window.windowID, event->window.data1,
					//		event->window.data2);
					break;

				case SDL_WINDOWEVENT_RESIZED:
					//SDL_Log("Window %d resized to %dx%d",
					//		event->window.windowID, event->window.data1,
					//		event->window.data2);
					break;

				case SDL_WINDOWEVENT_MINIMIZED:
					//SDL_Log("Window %d minimized", event->window.windowID);
					break;

				case SDL_WINDOWEVENT_MAXIMIZED:
					//SDL_Log("Window %d maximized", event->window.windowID);
					break;

				case SDL_WINDOWEVENT_RESTORED:
					//SDL_Log("Window %d restored", event->window.windowID);
					break;

				case SDL_WINDOWEVENT_ENTER:
					//SDL_Log("Mouse entered window %d",
					//		event->window.windowID);
					break;

				case SDL_WINDOWEVENT_LEAVE:
					//SDL_Log("Mouse left window %d", event->window.windowID);
					break;

				case SDL_WINDOWEVENT_FOCUS_GAINED:
					//SDL_Log("Window %d gained keyboard focus",
					//		event->window.windowID);
					break;

				case SDL_WINDOWEVENT_FOCUS_LOST:
					//SDL_Log("Window %d lost keyboard focus",
					//		event->window.windowID);
					break;
				default:
					break;
			}
		}
	}
	void SetResolution(int width, int height, ubyte depth=0, bool fullscreen = false, ubyte samples = 1)
	{
		assert(depth==0 || depth==16 || depth==24 || depth==32); // 0 for current screen depth
		assert(width>0 && height>0);

		SDL_GL_SetAttribute(SDL_GL_RED_SIZE,        8);
		SDL_GL_SetAttribute(SDL_GL_GREEN_SIZE,      8);
		SDL_GL_SetAttribute(SDL_GL_BLUE_SIZE,       8);
		SDL_GL_SetAttribute(SDL_GL_ALPHA_SIZE,      8);

		SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE,      16);
		SDL_GL_SetAttribute(SDL_GL_BUFFER_SIZE,        32);

		SDL_GL_SetAttribute(SDL_GL_ACCUM_RED_SIZE,    8);
		SDL_GL_SetAttribute(SDL_GL_ACCUM_GREEN_SIZE,    8);
		SDL_GL_SetAttribute(SDL_GL_ACCUM_BLUE_SIZE,    8);
		SDL_GL_SetAttribute(SDL_GL_ACCUM_ALPHA_SIZE,    8);

		SDL_GL_SetAttribute(SDL_GL_MULTISAMPLEBUFFERS,  1);
		SDL_GL_SetAttribute(SDL_GL_MULTISAMPLESAMPLES,  2);

		size.x = width;
		size.y = height;

		//uint flags = SDL_HWSURFACE | SDL_GL_DOUBLEBUFFER | SDL_OPENGL | SDL_RESIZABLE | SDL_HWPALETTE | SDL_HWACCEL;
		uint flags = SDL_WINDOW_SHOWN|SDL_WINDOW_OPENGL|SDL_WINDOW_RESIZABLE;
		//if (fullscreen_) flags |= SDL_FULLSCREEN;
		//	sdlSurface = SDL_SetVideoMode(size.x, size.y, depth, flags);
		sdlWindow = SDL_CreateWindow("New Window", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, size.x, size.y, flags);
		
		if(!sdlWindow)
			return;

		windowID = SDL_GetWindowID(sdlWindow);

		glcontext = SDL_GL_CreateContext(sdlWindow);
		string test = to!string(glGetString(GL_VERSION));
		SDL_GL_SetSwapInterval(1);
		glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
		glViewport(0,0, cast(GLsizei)size.x, cast(GLsizei)size.y);
		//maybe move
		GLVersion glver = DerelictGL3.reload();

		if(glver < GLVersion.GL33)
			throw new Exception("OpenGL version too low.");
	}

	void MakeCurrentGLContext()
	{
		// returns error if i need
		SDL_GL_MakeCurrent(sdlWindow, glcontext);
	}

	void SwapWindow()
	{
		SDL_GL_SwapWindow(sdlWindow);
	}
}