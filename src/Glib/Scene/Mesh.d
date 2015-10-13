module Glib.Scene.Mesh;

import derelict.assimp3.assimp;
import derelict.opengl3.gl3;
import gl3n.linalg;
import Glib.Scene.Shader;
import Glib.Scene.Material;
import Glib.Scene.Model;
import Glib.Scene.Node;
import Glib.System.System;
import Glib.Scene.GObject;


class Mesh
{
	vec3[] verts;
	uint[] indices;
	vec2[] uvs;
	vec3[] normals;
	vec3[] tangents;
	vec3[] bitTangents;

	GLuint vbo;
	GLuint uvbo;
	GLuint nbo;
	GLuint tanbo;
	GLuint bitTanbo;
	GLuint elementbo;
	GLuint VertexArrayID;

	Shader shader;
	Material material;

	this(const aiMesh* mesh)
	{
		for(int i = 0; i < mesh.mNumVertices; i++)
		{
			aiVector3D vert = mesh.mVertices[i];
			verts ~= vec3(vert.x, vert.y, vert.z);

			aiVector3D uvw = mesh.mTextureCoords[0][i];
			uvs ~= vec2(uvw.x, uvw.y);
		
			aiVector3D n = mesh.mNormals[i];
			normals ~= vec3(n.x, n.y, n.z);

			aiVector3D t = mesh.mTangents[i];
			tangents ~= vec3(t.x, t.y, t.z);

			aiVector3D bt = mesh.mBitangents[i];
			bitTangents ~= vec3(bt.x, bt.y, bt.z);
			

		}

		
		for(int i = 0; i < mesh.mNumFaces; i++)
		{
			const aiFace face = mesh.mFaces[i];
			uint t = face.mNumIndices;
			if(face.mNumIndices == 3)
			{
				indices ~= face.mIndices[0];
				indices ~= face.mIndices[1];
				indices ~= face.mIndices[2];
			}
			else
				continue;
		}
		
		
		shader = new Shader();
		shader.vertSource = geometryVS;
		shader.fragSource = geometryFS;

		//temporary
		material = new Material();
		material.diffuse = new Texture("..\\..\\resources\\Gray.png");;
		material.normal = new Texture( vec4i(128, 128, 128, 255));
		material.specular = new Texture( vec4i(0, 0, 0, 255));

		BindMesh();
	}

	this(vec3[] _verts,
		 uint[] _indices,
		 vec2[] _uvs,
		 vec3[] _normals,
		 vec3[] _tangents,
		 vec3[] _bitTangents,)
	{
		this.verts = _verts;
		this.verts = _verts;
		this.indices = _indices;
		this.uvs = _uvs;
		this.normals = _normals;
		this.tangents = _tangents;
		this.bitTangents = _bitTangents;


		shader = new Shader();
		shader.vertSource = geometryVS;
		shader.fragSource = geometryFS;

		//temporary
		material = new Material();
		material.diffuse = new Texture("..\\..\\resources\\Gray.png");;
		material.normal = new Texture( vec4i(128, 128, 128, 255));
		material.specular = new Texture( vec4i(0, 0, 0, 255));

		BindMesh();
	}
	~this()
	{
		if(vbo != 0)
			glDeleteBuffers(1, &vbo);
		if(uvbo != 0)
			glDeleteBuffers(1, &uvbo);
		if(nbo != 0)
			glDeleteBuffers(1, &nbo);
		if(VertexArrayID != 0)
			glDeleteVertexArrays(1, &VertexArrayID);
	}

	bool BindMesh()
	{
		shader.LoadShader();

		glGenVertexArrays(1, &VertexArrayID);
		glBindVertexArray(VertexArrayID);

		glGenBuffers(1, &vbo);
		glBindBuffer(GL_ARRAY_BUFFER, vbo);
		glBufferData(GL_ARRAY_BUFFER, verts.length * vec3.sizeof, cast(void*)verts.ptr, GL_STATIC_DRAW);
		glVertexAttribPointer(
							  0,                  // attribute
							  3,                  // size
							  GL_FLOAT,           // type
							  GL_FALSE,           // normalized?
							  0,                  // stride
							  cast(void*)0        // array buffer offset
								  );
		glEnableVertexAttribArray(0);


		glGenBuffers(1, &uvbo);
		glBindBuffer(GL_ARRAY_BUFFER, uvbo);
		glBufferData(GL_ARRAY_BUFFER, uvs.length * vec2.sizeof, cast(void*)uvs.ptr, GL_STATIC_DRAW);
		glVertexAttribPointer(
							  1,                                // attribute
							  2,                                // size
							  GL_FLOAT,                         // type
							  GL_FALSE,                         // normalized?
							  0,                                // stride
							  cast(void*)0                     // array buffer offset
								  );
		glEnableVertexAttribArray(1);


		glGenBuffers(1, &nbo);
		glBindBuffer(GL_ARRAY_BUFFER, nbo);
		glBufferData(GL_ARRAY_BUFFER, normals.length * vec3.sizeof, cast(void*)normals.ptr, GL_STATIC_DRAW);
		glVertexAttribPointer(
							  2,                                // attribute
							  3,                                // size
							  GL_FLOAT,                         // type
							  GL_FALSE,                         // normalized?
							  0,                                // stride
							  cast(void*)0                      // array buffer offset
								  );
		glEnableVertexAttribArray(2);

		glGenBuffers(1, &tanbo);
		glBindBuffer(GL_ARRAY_BUFFER, tanbo);
		glBufferData(GL_ARRAY_BUFFER, tangents.length * vec3.sizeof, cast(void*)tangents.ptr, GL_STATIC_DRAW);
		glVertexAttribPointer(
							  3,                                // attribute
							  3,                                // size
							  GL_FLOAT,                         // type
							  GL_FALSE,                         // normalized?
							  0,                                // stride
							  cast(void*)0                      // array buffer offset
								  );
		glEnableVertexAttribArray(3);

		glGenBuffers(1, &bitTanbo);
		glBindBuffer(GL_ARRAY_BUFFER, bitTanbo);
		glBufferData(GL_ARRAY_BUFFER, bitTangents.length * vec3.sizeof, cast(void*)bitTangents.ptr, GL_STATIC_DRAW);
		glVertexAttribPointer(
							  4,                                // attribute
							  3,                                // size
							  GL_FLOAT,                         // type
							  GL_FALSE,                         // normalized?
							  0,                                // stride
							  cast(void*)0                      // array buffer offset
								  );
		glEnableVertexAttribArray(4);

		glGenBuffers(1, &elementbo);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, elementbo);
		glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.length * uint.sizeof, cast(void*)indices.ptr, GL_STATIC_DRAW);


		glBindVertexArray(0);
		GLenum error = glGetError();
		if(error != GL_NO_ERROR)
			return false;
		else
			return true;
	}


	void Draw(Transform transform)
	{
		glUseProgram(shader.programID);
		glBindVertexArray(VertexArrayID);
		

		//GLuint lightID = glGetUniformLocation(shader.programID, "LightPosition_worldspace");
		//vec3 lightPos = vec3(4,4,4);
		//glUniform3f(lightID, lightPos.x, lightPos.y, lightPos.z);

		/*
		GLuint MatrixID = glGetUniformLocation(shader.programID, "MVP");
		GLuint ViewMatrixID = glGetUniformLocation(shader.programID, "V");
		GLuint ModelMatrixID = glGetUniformLocation(shader.programID, "M");

		mat4 projection = System.currentScene.mainCamera.getPerspeciveMatrix();

		mat4 view = System.currentScene.mainCamera.getViewMatrix();

		mat4 model = mat4.identity();

		mat4 MVP = projection * view * model;
*/

		GLuint ViewMatrixID = glGetUniformLocation(shader.programID, "worldView");
		GLuint ProjMatrixID = glGetUniformLocation(shader.programID, "worldViewProj");
		GLuint objID = glGetUniformLocation(shader.programID, "objectId");

		mat4 model = transform.worldTransformMatrix;

		mat4 worldView = System.currentScene.mainCamera.getViewMatrix() * model;//mat4.identity();
		mat4 projection = System.currentScene.mainCamera.getPerspeciveMatrix();
		mat4 worldviewProj = projection * worldView;

		glUniformMatrix4fv(ViewMatrixID, 1, GL_TRUE, worldView.value_ptr);
		glUniformMatrix4fv(ProjMatrixID, 1, GL_TRUE, worldviewProj.value_ptr);
		glUniform1ui(objID, 1);

		this.shader.BindMaterial(material);

		glDrawElements(GL_TRIANGLES, indices.length, GL_UNSIGNED_INT, null);
		GLenum error = glGetError();
		if(error != GL_NO_ERROR)
			string test = "error";
		
		glBindVertexArray(0);

	}

}

/// Obj for a 1x1 square billboard mesh
immutable string unitSquareMesh = q{
	v -1.0 1.0 0.0
		v -1.0 -1.0 0.0
		v 1.0 1.0 0.0
		v 1.0 -1.0 0.0

		vt 0.0 0.0
		vt 0.0 1.0
		vt 1.0 0.0
		vt 1.0 1.0

		vn 0.0 0.0 1.0

		f 4/3/1 3/4/1 1/2/1
		f 2/1/1 4/3/1 1/2/1
};



