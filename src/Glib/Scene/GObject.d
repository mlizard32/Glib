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

	
}
interface IComponent
{
	//GObject owner;

	//this(GObject owner)
	//{
	//	this.owner = owner;
	//}
}