module Glib.Scene;

import Glib.System;
import Glib.Camera;
import Glib.GObject;
import gl3n.linalg;
import Glib.Node;

class Scene : Node
{
	Camera mainCamera;
	Camera[] cameras;

	GObject world;

	this()
	{
		scene = this;
		world = new GObject();
		//world.transform.curMatrix = mat4.identity();

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