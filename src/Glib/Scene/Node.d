module Glib.Scene.Node;

import std.algorithm;
import gl3n.linalg;
import Glib.Scene.Scene;
import Glib.System.System;
import std.math;
import std.array;
import std.stdio;
import std.signals;

class Node:Tree!(Node)
{
	@("editorField")
	Transform transform;
	//Scene scene;

	invariant()
	{	assert(parent !is this);
	}
	this()
	{
		transform.thisNode = this;
		if(System.currentScene !is null)
		{
			if(System.currentScene.root !is null)
				System.currentScene.root.addChild(this);
		}
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

	//vec3 worldScale = vec3(1,1,1);	
	//vec3 worldPosition = vec3(0,0,0);
	//quat worldRotation = quat.identity;

	mat4 matrix = mat4.identity;

	Node thisNode;



	public void SetWorldDirty()
	{
		this.worldDirty = true;
		foreach(child; thisNode.children)
		{
			child.transform.SetWorldDirty();
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

		if (this.worldDirty)
		{		
			if (thisNode.parent && thisNode.parent !is System.currentScene.root)
			{	
				thisNode.parent.transform.CalcWorld();
			}
			matrix = mat4.identity;
			// Scale
			matrix[ 0 ][ 0 ] = localScale.x;
			matrix[ 1 ][ 1 ] = localScale.y;
			matrix[ 2 ][ 2 ] = localScale.z;

			// Rotate
			matrix = matrix * localRotation.to_matrix!(4,4);

			// Translate
			matrix[ 0 ][ 3 ] = localPosition.x;
			matrix[ 1 ][ 3 ] = localPosition.y;
			matrix[ 2 ][ 3 ] = localPosition.z;

			// include parent objects' transforms
			if( thisNode.parent )
				matrix = thisNode.parent.transform.worldTransformMatrix * matrix;
			
			this.worldDirty = false;
		}

	}
public:
	vec3 local_Rotation() const @property
	{
		return vec3(RadToDeg(localRotation.roll), RadToDeg(localRotation.pitch), RadToDeg(localRotation.yaw));
	}
	void local_Rotation(vec3 rotation) @property 
	{
		localRotation = quat.euler_rotation(DegToRad(rotation.x), DegToRad(rotation.y), DegToRad(rotation.z));
		SetWorldDirty();
	}

	quat local_Rotation_quat() const @property
	{
		return localRotation;
	} 

	void local_Rotation(quat rotation) @property 
	{
		localRotation = rotation;
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
		if(thisNode.parent !is null) 
		{
			quat worldRot = thisNode.parent.transform.world_Rotation_quat * localRotation;
			return vec3(RadToDeg(worldRot.yaw), RadToDeg(worldRot.pitch), RadToDeg(worldRot.roll));
		}
		else 
			return  vec3(localRotation.yaw, localRotation.pitch, localRotation.roll);
	}
	void world_Rotation(vec3 rotation) @property
	{
		quat worldRot = quat.euler_rotation(DegToRad(rotation.x), DegToRad(rotation.y), DegToRad(rotation.z));
		//set localrotation
		localRotation = worldRot * thisNode.parent.transform.world_Rotation_quat;
		SetWorldDirty();
	}
	

	quat world_Rotation_quat() const @property
	{
		if(thisNode.parent !is null) 
			return thisNode.parent.transform.world_Rotation_quat * localRotation;
		else 
			return  localRotation;
	}
	void world_Rotation(quat rotation) @property
	{
		localRotation = rotation * thisNode.parent.transform.world_Rotation_quat;
		SetWorldDirty();
	}

	vec3 world_Position() const @property
	{
		if(thisNode.parent !is null) 
			return this.localPosition + thisNode.parent.transform.world_Position;
		else return this.localPosition;
	}
	void world_Position(vec3 position) @property
	{
		this.localPosition = position - thisNode.parent.transform.world_Position;

		SetWorldDirty();
	}

	vec3 world_Scale() const @property
	{
		if(thisNode.parent !is null) 
			return this.localScale + thisNode.parent.transform.world_Scale;
		else 
			return this.localScale;
	}
	void world_Scale(vec3 scale) @property
	{
		this.localScale = scale - thisNode.parent.transform.world_Scale;

		SetWorldDirty();
	}

	mat4 worldTransformMatrix() @property 
	{
		CalcWorld();
		return matrix;
	}
}



class Tree(T)
{
	protected T parent;
	protected T[] children;
	protected int index = -1;

	mixin Signal!(string, T);
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
			child.parent.removeChild(child);// = remove(child.parent.children, child.index);
		}

		// Add as a child.
		child.parent = cast(T)this;
		children ~= cast(T)child;
		child.index = children.length-1;

		emit("addChild", child);
		return child;	
	}

	S addChildInPlace(S : T)(S child, int idx)
	{	
		assert(child);
		assert(child != this);

		if (child.parent is this)
			return child;

		// If child has an existing parent.
		if (child.parent)
		{	assert(child.parent.isChild(cast(S)child));
			child.parent.removeChild(child);// = remove(child.parent.children, child.index);
		}


		// Add as a child.
		child.parent = cast(T)this;
		children.insertInPlace(idx, cast(T)child);
		for(int i = idx ; i < children.length; i++)
		{
			children[i].index = i;
		}
		emit("addChildInPlace", child);
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
			//have to emit before removal so we can get its location in the tree
			emit("beforeRemoveChild", child);
			children = children.remove(child.index);
			for(int i = child.index ; i < children.length; i++)
			{
				children[i].index = i;
			}
			child.index = -1; // so remove can't be called twice.
			child.parent = null;		
		}
		assert (!isChild(child));

		emit("afterRemoveChild", cast(S)this);
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
	{	
		writeln(elem.index);
		
		if (!elem || elem.index < 0 || elem.index >= children.length)
		return false;
		return cast(bool)(children[elem.index] == elem);		
	}
}