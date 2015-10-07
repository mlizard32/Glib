module Glib.Scene.Light;

import Glib.Scene.GObject;
import gl3n.linalg;

class Light: IComponent
{
	vec3 color;
	bool castShadows;

	this(vec3 color)
	{
		this.color = color;
		castShadows = false;
	}
}

class PointLight : Light
{
	float radius;
	float fallOff;
	//intensity

	this(vec3 color = vec3(1.0f), float radius = 1.0f, float fallOff = 1.0f)
	{
		this.radius = radius;
		this.fallOff = fallOff;
		super(color);
	}
}

/*
//directional light stub
class DirectionalLight : Light
{
//projection view
//intensity
}

//spotlight stub
class SpotLight : Light
{
//direction
//radius
//falloff
//intensity
}
*/