module Glib.Scene.RMObject;

import Glib.Scene.Transform;
import gl3n.linalg;
import Glib.Scene.Node;
import Glib.System.System;

import std.uuid;
import std.signals;
import Editor.main;
import std.typecons;

import std.stdio;

class RMObject:Node
{
	UUID id;
	@("editorField")
	string name = "newObject";
	IComponent[] components;
	private Transform_Test _trans;
	
	this()
	{
		auto sceneGraph = getSceneGraphModel();
		if(sceneGraph !is null)
			this.connect(&sceneGraph.watch);
		
		super();
		id = randomUUID();		
		
		Transform_Test t = new Transform_Test(this);
		AttachComponent(t);
		_trans = t;
	}
	this(Node parent)
	{
		auto sceneGraph = getSceneGraphModel();
		if(sceneGraph !is null)
			this.connect(&sceneGraph.watch);

		super(parent);
		id = randomUUID();

		Transform_Test t = new Transform_Test(this);
		AttachComponent(t);
		_trans = t;
	}

	Transform_Test getTransform()
	{
		return _trans;
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
abstract class IComponent : EditorHelper
{
	RMObject owner;

	public override Tuple!(string, void*, void*, dataType)[] getEditorField()
	{
		return null;
	}
	//this(RMObject owner)
	//{
	//	this.owner = owner;
	//}
}

abstract class EditorHelper
{
	mixin Signal!(string, string);
	mixin Signal!(vec3, string);
	enum dataType
	{
		E_string,
		E_bool,
		E_vec3
	}
	//returns fieldname
	public Tuple!(string, void*, void*, dataType)[] getEditorField()
	{
		return null;
	}
}

mixin template EditorFields(T)
{
	public override Tuple!(string, void*, void*, dataType)[] getEditorField()
	{
		//fieldname, setter, getter, type
		Tuple!(string, void*, void*, dataType)[] editorVisibleProperties;
		dataType type;

		foreach(member; __traits(derivedMembers, T))
		{
			mixin("alias symbol = " ~ member ~ ";");
			foreach(attr; __traits(getAttributes, symbol))
				// identify them by type rather than value
				static if ( attr == "editorField") 
				{
					static if(is(typeof(symbol) == string))
					{
						void delegate(string) setterDg = &symbol;
						string delegate() getterDg = &symbol;
						type = dataType.E_string;
						editorVisibleProperties ~= tuple(member, cast(void*)setterDg.funcptr, cast(void*)getterDg.funcptr, type);
					}
					else if(is(typeof(symbol) == vec3))
					{
						void delegate(vec3) setterDg = &symbol;
						vec3 delegate() getterDg = &symbol;
						type = dataType.E_vec3;
						editorVisibleProperties ~= tuple(member, cast(void*)setterDg.funcptr, cast(void*)getterDg.funcptr, type);
					}
					else if(std.traits.isNumeric!(typeof(symbol)))
					{

					}
					else
					{
					}
					
				}

		}

		return editorVisibleProperties;
	}
}

mixin template PropertyField(T, string name, bool editorfield = false)
{
	mixin("private " ~ T.stringof ~ " _" ~ name ~ ";");

	static if(editorfield)
	{
		mixin("@(\"editorField\") \r\n public void " ~ name ~ "(" ~ T.stringof ~ " value) @property
			  {"
			  ~ "_" ~ name ~ " = value;" ~
				"emit(value, typeid(this).classinfo.name ~ \"." ~ name ~"\");" ~
			  "}");

		mixin("@(\"editorField\") \r\n public " ~ T.stringof ~  " " ~ name ~ "() @property
			  {"
			  ~ "return _" ~ name ~ ";" ~
			  "}");
	}
	else
	{
		mixin(" public void " ~ name ~ "(" ~ T.stringof ~ " value) @property
			  {"
					~ "_" ~ name ~ " = value;" ~
			  "}");

		mixin("public " ~ T.stringof ~  " " ~ name ~ "() @property
			  {"
			  ~ "return _" ~ name ~ ";" ~
			  "}");
	}
}

class Transform_Test : IComponent
{

/*
	private string _testField = "testme";

	@("editorField")
	public void testField(string input) @property
	{
		_testField = input;
		emit(input, typeid(this).classinfo.name ~ ".testField");
	}
	@("editorField")
	public string testField() @property
	{
		return _testField;
	}

	private string _testme = "testme";

	@("editorField")
	public void testme(string input)// @property
	{
		_testme = input;
		emit(input, typeid(this).classinfo.name ~ ".testme");
	}
	@("editorField")
	public string testme()// @property
	{
		return _testme;
	}
*/


	mixin PropertyField!(string, "omgLawl", true);
	mixin PropertyField!(string, "blah", true);
	mixin PropertyField!(vec3, "testVector", true);

	/*
	Tuple!(string, void*, void*, dataType)[2] editorVisibleProperties;
	void delegate(string)[] testHolder;
	string delegate()[] testHolderTwo;

	public override Tuple!(string, void*, void*, dataType)[] getEditorField()
	{
		//fieldname, setter, getter, type
		
		void* setter;
		void* getter;
		dataType type;
//		setter = cast(void*)&testField;
		
		void delegate(string) setterDg = &this.testField;
		testHolder ~= setterDg;
		string delegate() getterDg = &this.testField;
		testHolderTwo ~= getterDg;
		setter = &setterDg;
		getter = &getterDg;
		type = dataType.E_string;
		editorVisibleProperties[0] = tuple("testField", setterDg.funcptr, getterDg.funcptr, type);

		auto propertySet = *cast(void delegate(string)*)editorVisibleProperties[0][1];
		auto propertyGet = *cast(string delegate()*)editorVisibleProperties[0][2];

		void delegate(string) setterDgt = &this.testme;
		testHolder ~= setterDgt;
		string delegate() getterDgt = &this.testme;
		testHolderTwo ~= getterDgt;
		void* setterr;
		void* getterr;
		setterr = &setterDgt;
		getterr = &getterDgt;
		type = dataType.E_string;
		editorVisibleProperties[1] = tuple("testme", setterDgt.funcptr, getterDgt.funcptr, type);

		return editorVisibleProperties;
	}
*/

	mixin EditorFields!(typeof(this));
/*
	public override string getEditorField(out void* member, out dataType type)
	{
		
		member = cast(void*)&testField;
		type = dataType.E_string;
		return "testField";
	}

	public override string getEditorField(out void* setter, out void* getter, out dataType type)
	{
		void delegate(string) setterDg = &testField;
		string delegate() getterDg = &testField;
		setter = &setterDg;
		getter = &getterDg;
		type = dataType.E_string;
		return "testField";
	}
*/
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

	this(Node owner)
	{
		thisNode = owner;
		testVector = vec3(1.0f, 4.0f, 5.1f);
	}



	void SetWorldDirty()
	{
		this.worldDirty = true;
		foreach(child; thisNode.getChildren)
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
			if (thisNode.getParent && thisNode.getParent !is System.currentScene.root)
			{	
				thisNode.getParent.transform.CalcWorld();
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
			if( thisNode.getParent )
				matrix = thisNode.getParent.transform.worldTransformMatrix * matrix;

			this.worldDirty = false;
		}

	}
public:

	vec3 local_Rotation() @property
	{
		return vec3(RadToDeg(localRotation.roll), RadToDeg(localRotation.pitch), RadToDeg(localRotation.yaw));
	}
	void local_Rotation(vec3 rotation) @property 
	{
		localRotation = quat.euler_rotation(DegToRad(rotation.x), DegToRad(rotation.y), DegToRad(rotation.z));
		SetWorldDirty();
	}

	quat local_Rotation_quat() @property
	{
		return localRotation;
	} 

	void local_Rotation(quat rotation) @property 
	{
		localRotation = rotation;
		SetWorldDirty();
	}

	vec3 local_Position() @property 
	{
		return localPosition;
	}
	void local_Position(vec3 position) @property 
	{
		localPosition = position;
		SetWorldDirty();
	}
	vec3 local_Scale() @property 
	{
		return localScale;
	}
	void local_Scale(vec3 newScale) @property 
	{
		this.localScale = newScale;
		SetWorldDirty();
	}


	vec3 world_Rotation() @property
	{
		if(thisNode.getParent !is null) 
		{
			quat worldRot = thisNode.getParent.transform.world_Rotation_quat * localRotation;
			return vec3(RadToDeg(worldRot.yaw), RadToDeg(worldRot.pitch), RadToDeg(worldRot.roll));
		}
		else 
			return  vec3(localRotation.yaw, localRotation.pitch, localRotation.roll);
	}
	void world_Rotation(vec3 rotation) @property
	{
		quat worldRot = quat.euler_rotation(DegToRad(rotation.x), DegToRad(rotation.y), DegToRad(rotation.z));
		//set localrotation
		localRotation = worldRot * thisNode.getParent.transform.world_Rotation_quat;
		SetWorldDirty();
	}


	quat world_Rotation_quat()  @property
	{
		if(thisNode.getParent !is null) 
			return thisNode.getParent.transform.world_Rotation_quat * localRotation;
		else 
			return  localRotation;
	}
	void world_Rotation(quat rotation) @property
	{
		localRotation = rotation * thisNode.getParent.transform.world_Rotation_quat;
		SetWorldDirty();
	}

	vec3 world_Position()  @property
	{
		if(thisNode.getParent !is null) 
			return this.localPosition + thisNode.getParent.transform.world_Position;
		else return this.localPosition;
	}
	void world_Position(vec3 position) @property
	{
		this.localPosition = position - thisNode.getParent.transform.world_Position;

		SetWorldDirty();
	}

	vec3 world_Scale()  @property
	{
		if(thisNode.getParent !is null) 
			return this.localScale + thisNode.getParent.transform.world_Scale;
		else 
			return this.localScale;
	}
	void world_Scale(vec3 scale) @property
	{
		this.localScale = scale - thisNode.getParent.transform.world_Scale;

		SetWorldDirty();
	}

	mat4 worldTransformMatrix() @property 
	{
		CalcWorld();
		return matrix;
	}
}

