module Glib.Scene.Transform;

/*
import gl3n.linalg;
import Glib.GObject;

class Transform
{
	GObject gObject;
	GObject parent;
	private:
		mat4 translationMatrix;
		mat3 rotationMatrix;
		vec3 scale;

	this()
	{
		
	}

	vec3 eulerRotation() const @property
	{
		quat q = quat.from_matrix(rotationMatrix);
		return vec3(q.yaw, q.pitch, q.roll);
	}
	void eulerRotation(vec3 rotation) @property 
	{
		quat q = quat.euler_rotation(rotation.x, rotation.y, rotation.z);
		mat3 m = q.to_matrix!(3,3);
		rotationMatrix = m;
	}
	vec3 position() const @property 
	{
		return vec3(translationMatrix[0][3], translationMatrix[1][3], translationMatrix[2][3]);
	}
	void position(vec3 position) @property 
	{
		mat4 m = mat4.identity();
		translationMatrix = m.translation(position.x, position.y, position.z);
	}
	vec3 scale() const @property 
	{
		return scale;
	}
	void scale(vec3 newScale) @property 
	{
		this.scale = newScale;
		mat4 m = mat4.identity();
		scaleMatrix = m.scale(scale.x, scale.y, scale.z);
	}
	mat4 transformMatrix() const @property 
	{
		mat4 m = mat4.identity();
		return translationMatrix * mat4(rotationMatrix) * m.scale(scale.x, scale.y, scale.z);
	}
}
*/