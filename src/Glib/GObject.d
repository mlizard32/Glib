module Glib.GObject;

import Glib.Transform;
import gl3n.linalg;
import Glib.Node;

class GObject:Node
{
	uint id;
	string name;
	GObjectCompenent[] components;
	
	this()
	{
		super();
	}
	this(Node parent)
	{
		super(parent);
	}

	
}
class GObjectCompenent
{
	GObject owner;

	this(GObject owner)
	{
		this.owner = owner;
	}
}