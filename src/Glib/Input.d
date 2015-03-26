module Glib.Input;

import derelict.sdl2.sdl;
import gl3n.linalg;
import Glib.window;
import Glib.System;

class Input
{
	Mouse mouse;

	public void pollInput()
	{
		SDL_Event event;
		while(SDL_PollEvent(&event))
		{
			switch (event.type)
			{
				case SDL_WINDOWEVENT:
					foreach(window w; System.windows)
					{
						w.UpdateWindow(event);
					}
					break;
				case SDL_KEYDOWN:
					break;
				case SDL_KEYUP:
					break;
				case SDL_MOUSEMOTION:
					this.mouse.Position.x = event.motion.x;
					this.mouse.Position.y = event.motion.y;
					break;
				case SDL_MOUSEBUTTONDOWN:
					this.mouse.leftButton = true;
					break;
				case SDL_MOUSEBUTTONUP:
					this.mouse.leftButton = false;
					break;
				case SDL_MOUSEWHEEL:
					break;
				case SDL_QUIT:
					System.active = false;
					break;
				default:
					//unhandled event
					break;
			}

			SDL_Delay(1);
		}
	}

}

struct Mouse
{
	vec2 Position;
	bool leftButton;
	bool rightButton;
}