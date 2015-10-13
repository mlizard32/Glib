module Glib.Scene.GObject;

import Glib.Scene.Transform;
import gl3n.linalg;
import Glib.Scene.Node;

class GObject:Node
{
	uint id;
	string name;
	IComponent[] components;
	
	this()
	{
		super();
	}
	this(Node parent)
	{
		super(parent);
	}

	void AttachComponent(IComponent comp)
	{
		comp.owner = this;
		components ~= comp;
	}

	void DetachComponent(IComponent comp)
	{
		//not implemented
	}
	
}
abstract class IComponent
{
	GObject owner;

	//this(GObject owner)
	//{
	//	this.owner = owner;
	//}
}