module Glib.Scene.Scene;

import Glib.System.System;
import Glib.Scene.Camera;
import Glib.Scene.RMObject;
import gl3n.linalg;
import Glib.Scene.Node;

import std.uuid;
import std.algorithm;
import std.array;

class Scene
{
	Camera mainCamera;
	Camera[] cameras;

	RMObject root;

	this()
	{
		
		root = new RMObject();
		root.name = "Scene";
		
		//world.addChild(mainCamera.transform);

		if(System.currentScene is null)
			System.currentScene = this;
		System.scenes ~= this;

		mainCamera = new Camera();
	}

	void Update()
	{

	}

	void prepend(RMObject newObj, RMObject destObj)
	{
		auto parent = destObj.getParent;
		
		auto children = parent.getChildren;
		auto destInx = children.countUntil(destObj);
		RMObject test = cast(RMObject) newObj.getParent;
		assert (test !is null);
		newObj.getParent.removeChild(newObj);
		parent.addChildInPlace(newObj, destInx);
	}

	RMObject findObjByID(UUID id)
	{
		return traverseScene(root, id);
	}

	RMObject traverseScene(RMObject g, UUID id)
	{
		if(g.id == id)
			return g;
		//Traverse Children
		foreach(Node gChild; g.getChildren())
		{
			RMObject temp = traverseScene(cast(RMObject)gChild, id);
			if (temp !is null)
				return temp;
		}
		return null;
	}
}