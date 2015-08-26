module Glib.Scene.Render;

import derelict.opengl3.gl3;
import derelict.sdl2.sdl;
import gl3n.linalg;
import Glib.Scene.Scene;
import Glib.Scene.GObject;
import Glib.Scene.Node;
import Glib.System.Window;
import Glib.System.Log;

struct Render
{

	void Complete()
	{
		//swap buffers
		//SDL_GL_SwapWindow
	}
	
	void rScene(Scene scene, window w)
	{
		if(!scene)
			Log.error("no active scene to render");
		if(!scene.mainCamera)
			Log.error("no camera set in scene");


		//w.MakeCurrentGLContext();
		//traverse tree and call draw
		TraverseDraw(scene.root);
		//need to make a check to see if obj is even visible


		//render geometry 

		//render shadow pass

		//render light pass
		
		//vec3 lightPos = vec3(4,4,4);
		//glUniform3f(lightID, lightPos.x, lightPos.y, lightPos.z);

		//render UI
	}

	void TraverseDraw(GObject g)
	{
		//Draw This object
		foreach(IComponent component; g.components)
		{
			IDrawable draw = cast(IDrawable) component;
			if(draw !is null)
				draw.Draw();
		}
		
		//Draw Children
		foreach(Node gChild; g.getChildren())
		{
			
			TraverseDraw(cast(GObject)gChild);
		}
	}
}

interface IDrawable
{
	void Draw();
}

