module Glib.Node;

import std.algorithm;
import gl3n.linalg;
import Glib.Scene;
import std.math;

class Node:Tree!(Node)
{
	Transform transform;
	Scene scene;

	invariant()
	{	assert(parent !is this);
	}
	this()
	{
		transform.thisNode = this;
		this(null);
	}

	this(Node parent) /// ditto
	{	if (parent)
		{	
			parent.addChild(this);
		}
		transform.thisNode = this;
	}
	/*
	vec3 position() const @property
	{
		if (parent && parent !is scene)
			return this.localPosition + parent.position;
		else
			return this.transform.position;
	}
	
	void position(vec3 position) @property
	{
		if (parent && parent !is scene)
			this.transform.position = parent.position - position;
	}

	vec3 localPosition() const @property
	{
		return transform.position;
	}
	*/
	

}

struct Transform
{
	public bool worldDirty;
private:
	vec3 localScale = vec3(1,1,1);	
	vec3 localPosition = vec3(0,0,0);
	quat localRotation = quat.identity;

	vec3 worldScale = vec3(1,1,1);	
	vec3 worldPosition = vec3(0,0,0);
	quat worldRotation = quat.identity;

	Node thisNode;

	void SetWorldDirty()
	{
		foreach(child; thisNode.children)
		{
			child.transform.worldDirty = true;
		}
	}
	float DegToRad(const float degree)
	{
		enum float degToRad = PI / 180.0f;
		float result = degree * degToRad;
		return result;
	}
	float RadToDeg(const float radian) const
	{
		enum float radToDeg = 180.0f / PI;
		float result = radian * radToDeg;
		return result;
	}
	public void CalcWorld()
	{
		/*
		if (this.worldDirty)
		{		
			if (thisNode.parent && thisNode.parent !is thisNode.scene)
			{	thisNode.parent.transform.CalcWorld();

				this.worldPosition = this.localPosition * thisNode.parent.transform.worldScale;
				if (thisNode.parent.transform.worldRotation != quat.identity) // Because rotation is more expensive
				{	this.worldPosition = this.worldPosition.rotate(thisNode.parent.transform.worldRotation);
					this.worldRotation = thisNode.parent.transform.worldRotation * this.localRotation;
				} else
					this.worldRotation = this.localRotation;

				this.worldPosition += thisNode.parent.transform.worldPosition;
				this.worldScale =  thisNode.parent.transform.worldScale * transform.scale;

			} else
			{	
				this.worldPosition = this.localPosition;
				this.worldRotation = this.localRotation;
				this.worldScale = this.localScale;
			}
			this.worldDirty = false;
		}
		*/
	}
public:
	vec3 local_Rotation() const @property
	{
		return vec3(localRotation.yaw, localRotation.pitch, localRotation.roll);
	}
	void local_Rotation(vec3 rotation) @property 
	{
		localRotation = quat.euler_rotation(rotation.x, rotation.y, rotation.z);
		SetWorldDirty();
	}
	vec3 local_Position() const @property 
	{
		return localPosition;
	}
	void local_Position(vec3 position) @property 
	{
		localPosition = position;
		SetWorldDirty();
	}
	vec3 local_Scale() const @property 
	{
		return localScale;
	}
	void local_Scale(vec3 newScale) @property 
	{
		this.localScale = newScale;
		SetWorldDirty();
	}

	vec3 world_Rotation() const @property
	{
		if(thisNode.parent && thisNode.parent !is thisNode.scene) 
			return vec3(RadToDeg(worldRotation.yaw), RadToDeg(worldRotation.pitch), RadToDeg(worldRotation.roll));
		else return  vec3(localRotation.yaw, localRotation.pitch, localRotation.roll);
	}
	void world_Rotation(vec3 rotation) @property
	{
		worldRotation = quat.euler_rotation(DegToRad(rotation.x), DegToRad(rotation.y), DegToRad(rotation.z));
		//set localrotation
		localRotation = worldRotation * thisNode.parent.transform.worldRotation;
		SetWorldDirty();
	}

	vec3 world_Position() const @property
	{
		if(thisNode.parent && thisNode.parent !is thisNode.scene) 
			return this.localPosition + thisNode.parent.transform.world_Position;
		else return this.localPosition;
	}
	void world_Position(vec3 position) @property
	{
		this.worldPosition = position;
		this.localPosition = this.worldPosition - thisNode.parent.transform.world_Position;

		SetWorldDirty();
	}

	vec3 world_Scale() const @property
	{
		if(thisNode.parent && thisNode.parent !is thisNode.scene) 
			return this.localScale + thisNode.parent.transform.world_Scale;
		else return this.localScale;
	}
	void world_Scale(vec3 scale) @property
	{
		this.worldScale = scale;
		this.localScale = this.worldScale - thisNode.parent.transform.world_Scale;

		SetWorldDirty();
	}

	mat4 worldTransformMatrix() @property 
	{
		CalcWorld();
		mat4 mS = mat4.identity();
		mat4 mP = mat4.identity();

		return mP.translation(worldPosition.x, worldPosition.y, worldPosition.z) * worldRotation.to_matrix!(4,4)
			* mS.scale(worldScale.x, worldScale.y, worldScale.z);
	}
}

class Tree(T)
{
	protected T parent;
	protected T[] children;
	protected int index = -1;

	/**
	* Add a child element.
	* Automatically detaches it from any other element's children.
	* Params:
	*     child = Node to add as a child of this element.
	* Returns: A reference to the child. */
	S addChild(S : T)(S child)
	{	
		assert(child);
		assert(child != this);

		if (child.parent is this)
			return child;

		// If child has an existing parent.
		if (child.parent)
		{	assert(child.parent.isChild(cast(S)child));
			remove(child.parent.children, child.index);
		}

		// Add as a child.
		child.parent = cast(T)this;
		children ~= cast(T)child;
		child.index = children.length-1;

		return child;	
	}

	/**
	* Remove a child element
	* Params:
	*     child = An element of type T or that inherits from type T.
	* Returns: The child element.  For convenience, the return type is templated to match the input type.
	*/
	S removeChild(S : T)(S child)
	{	
		assert(child);
		assert(isChild(child));
		assert(child.parent == this);

		if (child.index >= 0)
		{	
			remove(children, child.index);
			if (child.index < children.length) // update index of element that replaced child.
				children[child.index].index = child.index;
			child.index = -1; // so remove can't be called twice.
			child.parent = null;			
		}
		assert (!isChild(child));

		return child;
	}


	/// Get an array of this element's children.
	T[] getChildren()
	{	return children;
	}

	/**
	* Get / set the parent of this element (what it's attached to).
	* Setting a new parent removes it from its old parent's children and returns a self-reference. */
	T getParent()
	{	return parent;
	}

	/**
	* Is elem a child of this element?
	* This function will also return false if elem is null. */ 
	bool isChild(T elem)
	{	if (!elem || elem.index < 0 || elem.index >= children.length)
		return false;
		return cast(bool)(children[elem.index] == elem);		
	}
}