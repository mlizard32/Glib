module Glib.Scene.Scene;

import Glib.System.System;
import Glib.Scene.Camera;
import Glib.Scene.GObject;
import gl3n.linalg;
import Glib.Scene.Node;

class Scene
{
	Camera mainCamera;
	Camera[] cameras;

	GObject root;

	this()
	{
		
		root = new GObject();

		mainCamera = new Camera();
		//world.addChild(mainCamera.transform);

		if(System.currentScene is null)
			System.currentScene = this;
		System.scenes ~= this;
	}

	void Update()
	{

	}
}