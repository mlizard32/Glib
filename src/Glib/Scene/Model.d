module Glib.Scene.Model;

import Glib.System.Log;
import Glib.Scene.Mesh;
import Glib.Scene.Transform;
import Glib.Scene.Render;
import Glib.Scene.GObject;
import derelict.assimp3.assimp;

import std.algorithm;
import std.math;
import std.conv;

import gl3n.linalg;

class Model:IDrawable, IComponent
{
	Mesh[] meshes;
	//toDo:
	//animations
	//shaders

	this(string path)
	{
		
		const char* pathC = std.string.toStringz(path);

		const aiScene* loadScene = aiImportFile(pathC, aiProcess_CalcTangentSpace | aiProcess_Triangulate | aiProcess_JoinIdenticalVertices);

		if(loadScene == null)
		{
			Log.error("unable to import model: " ~ path);
		}
		else
		{
		
			for(int i = 0; i < loadScene.mNumMeshes; i++)
			{

				const aiMesh* mesh = loadScene.mMeshes[i];
				meshes ~= new Mesh(mesh);

			}
		}

		aiReleaseImport(loadScene);
	}

	void Draw()
	{
		foreach(Mesh m; meshes)
		{
			m.Draw();
		}
	}
	
}


class PrimitiveObject:IDrawable, IComponent
{
	Mesh mesh;
	PrimitiveTypes type;
	public enum PrimitiveTypes
	{
		Sphere,
			Cube,
			Plane
	}
	this(PrimitiveTypes type)
	{
		this.type = type;

		switch(type)
		{
			case(PrimitiveTypes.Sphere):
				CreateSphere();
				break;
			default:
				break;
		}

	}
	void Draw()
	{
		mesh.Draw();
	}

	void CreateSphere()
	{
		const int detailLevel = 1;
		Icosahedron icosahedron;
		vec3[] verts;
		uint[] indices;
		vec3[] normals;
		vec2[] uvs;
		vec3[] tangents;
		vec3[] bitTangents;
		
		indices = icosahedron.indices;
		verts = icosahedron.vertices;

		for(int i = 0; i < detailLevel; i++)
		{
			Subdivide(verts, indices, true);
		}

		for(int i = 0; i < verts.length; i++)
		{
			verts[i].normalize();
			normals ~= verts[i];

			vec2 CalcUVs(vec3 v)
			{
				vec2 uv;

				uv.x = atan2(v.x, v.z) / (2 * PI) + 0.5f;
				uv.y = asin(v.y) / PI + 0.5f;

				return uv;
			}
			uvs ~= CalcUVs(verts[i]);
		}

		vec3[] tan1;
		vec3[] tan2;
		tan1.length = verts.length;
		tan2.length = verts.length;
		for (int i=0; i<indices.length; i+=3)
		{
			uint i1 = indices[i+0];
			uint i2 = indices[i+1];
			uint i3 = indices[i+2];

			vec3 v1 = verts[i1];
			vec3 v2 = verts[i2];
			vec3 v3 = verts[i3];

			vec2 w1 = uvs[i1];
			vec2 w2 = uvs[i2];
			vec2 w3 = uvs[i3];

			float x1 = v2.x - v1.x;
			float x2 = v3.x - v1.x;
			float y1 = v2.y - v1.y;
			float y2 = v3.y - v1.y;
			float z1 = v2.z - v1.z;
			float z2 = v3.z - v1.z;

			float s1 = w2.x - w1.x;
			float s2 = w3.x - w1.x;
			float t1 = w2.y - w1.y;
			float t2 = w3.y - w1.y;

			float r = 1.0F / (s1 * t2 - s2 * t1);
			vec3 sdir = vec3((t2 * x1 - t1 * x2) * r, (t2 * y1 - t1 * y2) * r,
							(t2 * z1 - t1 * z2) * r);
			vec3 tdir = vec3((s1 * x2 - s2 * x1) * r, (s1 * y2 - s2 * y1) * r,
							(s1 * z2 - s2 * z1) * r);

			tan1[i1] += sdir;
			tan1[i2] += sdir;
			tan1[i3] += sdir;

			tan2[i1] += tdir;
			tan2[i2] += tdir;
			tan2[i3] += tdir;
		}
		
		tangents.length = verts.length;
		bitTangents.length = verts.length;
		for (int a = 0; a < verts.length; a++)
		{
			vec3 n = normals[a];
			vec3 t = tan1[a];

			// Gram-Schmidt orthogonalize
			tangents[a] = (t - n * dot!vec3(n, t)).normalized();

			float w = (dot!vec3(cross!vec3(n, t), tan2[a]) < 0.0F) ? -1.0F : 1.0F;

			bitTangents[a] = cross!vec3(n,t) * w;
		}

		mesh = new Mesh(verts, indices, uvs, normals, tangents, bitTangents);

		/*
		for ( int i=0; i<verts.length; i+=3)
		{
			// Shortcuts for vertices
			vec3 v0 = verts[i+0];
			vec3 v1 = verts[i+1];
			vec3 v2 = verts[i+2];

			// Shortcuts for UVs
			vec2 uv0 = uvs[i+0];
			vec2 uv1 = uvs[i+1];
			vec2 uv2 = uvs[i+2];

			// Edges of the triangle : postion delta
			vec3 deltaPos1 = v1-v0;
			vec3 deltaPos2 = v2-v0;

			// UV delta
			vec2 deltaUV1 = uv1-uv0;
			vec2 deltaUV2 = uv2-uv0;
		
			float r = 1.0f / (deltaUV1.x * deltaUV2.y - deltaUV1.y * deltaUV2.x);
			vec3 tangent = (deltaPos1 * deltaUV2.y   - deltaPos2 * deltaUV1.y)*r;
			vec3 bitangent = (deltaPos2 * deltaUV1.x   - deltaPos1 * deltaUV2.x)*r;
		}
		*/
	}


	private static uint GetMidpointIndex(ref uint[string] midpointIndices, ref vec3[] vertices, int i0, int i1)
	{

		string edgeKey = to!string(fmin(i0, i1)) ~ "_" ~ to!string(fmax(i0, i1));

		uint* pMidpointIndex = (edgeKey in midpointIndices);
		uint midpointIndex;
		if (pMidpointIndex == null)
		{
			vec3 v0 = vertices[i0];
			vec3 v1 = vertices[i1];

			auto midpoint = (v0 + v1) / 2f;

			if (any!(a => a == midpoint)(vertices))
				midpointIndex = vertices.countUntil(midpoint);
			else
			{
				midpointIndex = vertices.length;
				vertices ~= midpoint;
			}

			midpointIndices[edgeKey] = midpointIndex;
		}
		else
			midpointIndex = *pMidpointIndex;


		return midpointIndex;

	}

	/// <remarks>
	///      i0
	///     /  \
	///    m02-m01
	///   /  \ /  \
	/// i2---m12---i1
	/// </remarks>
	/// <param name="vectors"></param>
	/// <param name="indices"></param>
	public static void Subdivide(ref vec3[] vectors, ref uint[] indices, bool removeSourceTriangles)
	{
		uint[string] midpointIndices;

		uint[] newIndices;// = int[(indices.length * 4)];

		if (!removeSourceTriangles)
			newIndices ~= indices;

		for (int i = 0; i < indices.length - 2; i += 3)
		{
			uint i0 = indices[i];
			uint i1 = indices[i + 1];
			uint i2 = indices[i + 2];

			uint m01 = GetMidpointIndex(midpointIndices, vectors, i0, i1);
			uint m12 = GetMidpointIndex(midpointIndices, vectors, i1, i2);
			uint m02 = GetMidpointIndex(midpointIndices, vectors, i2, i0);

			newIndices ~= [ i0,m01,m02,
			i1,m12,m01,
			i2,m02,m12,
			m02,m01,m12 ];

		}

		indices = newIndices;
	}


	struct Icosahedron
	{
		uint[] indices = 
		[	0,4,1,
		0,9,4,
		9,5,4,
		4,5,8,
		4,8,1,
		8,10,1,
		8,3,10,
		5,3,8,
		5,2,3,
		2,7,3,
		7,10,3,
		7,6,10,
		7,11,6,
		11,0,6,
		0,1,6,
		6,1,10,
		9,0,11,
		9,11,2,
		9,2,5,
		7,2,11 ];

		static const float X = 0.525731112119133606f;
		static const float Z = 0.850650808352039932f;

		vec3[] vertices = 
		[	vec3(-X, 0f, Z),
		vec3(X, 0f, Z),
		vec3(-X, 0f, -Z),
		vec3(X, 0f, -Z),
		vec3(0f, Z, X),
		vec3(0f, Z, -X),
		vec3(0f, -Z, X),
		vec3(0f, -Z, -X),
		vec3(Z, X, 0f),
		vec3(-Z, X, 0f),
		vec3(Z, -X, 0f),
		vec3(-Z, -X, 0f) ];
	}

}
