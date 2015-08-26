module Glib.Scene.Mesh;

import derelict.assimp3.assimp;
import derelict.opengl3.gl3;
import gl3n.linalg;
import Glib.Scene.Shader;
import Glib.Scene.Material;

import Glib.System.System;

class Mesh
{
	vec3[] verts;
	uint[] indices;
	vec2[] uvs;
	vec3[] normals;

	GLuint vbo;
	GLuint uvbo;
	GLuint nbo;
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

		//temporary
		Texture tex = new Texture("..\\..\\resources\\Gray.png");
		material = new Material();
		material.diffuse = tex;

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
		glBindBuffer(GL_ARRAY_BUFFER, 0);

		glGenBuffers(1, &uvbo);
		glBindBuffer(GL_ARRAY_BUFFER, uvbo);
		glBufferData(GL_ARRAY_BUFFER, uvs.length * vec2.sizeof, cast(void*)uvs.ptr, GL_STATIC_DRAW);
		glBindBuffer(GL_ARRAY_BUFFER, 0);

		glGenBuffers(1, &nbo);
		glBindBuffer(GL_ARRAY_BUFFER, nbo);
		glBufferData(GL_ARRAY_BUFFER, normals.length * vec3.sizeof, cast(void*)normals.ptr, GL_STATIC_DRAW);
		glBindBuffer(GL_ARRAY_BUFFER, 0);

		glGenBuffers(1, &elementbo);
		glBindBuffer(GL_ARRAY_BUFFER, elementbo);
		glBufferData(GL_ARRAY_BUFFER, indices.length * uint.sizeof, cast(void*)indices.ptr, GL_STATIC_DRAW);
		glBindBuffer(GL_ARRAY_BUFFER, 0);

		GLenum error = glGetError();
		if(error != GL_NO_ERROR)
			return false;
		else
			return true;
	}

	void Draw()
	{
		glUseProgram(shader.programID);

		this.shader.BindMaterial(material);

		GLuint lightID = glGetUniformLocation(shader.programID, "LightPosition_worldspace");
		vec3 lightPos = vec3(4,4,4);
		glUniform3f(lightID, lightPos.x, lightPos.y, lightPos.z);

		GLuint MatrixID = glGetUniformLocation(shader.programID, "MVP");
		GLuint ViewMatrixID = glGetUniformLocation(shader.programID, "V");
		GLuint ModelMatrixID = glGetUniformLocation(shader.programID, "M");

		mat4 projection = System.currentScene.mainCamera.getPerspeciveMatrix();

		mat4 view = System.currentScene.mainCamera.getViewMatrix();

		mat4 model = mat4.identity();

		mat4 MVP = projection * view * model;

		glUniformMatrix4fv(MatrixID, 1, GL_TRUE, MVP.value_ptr);
		glUniformMatrix4fv(ModelMatrixID, 1, GL_TRUE, model.value_ptr);
		glUniformMatrix4fv(ViewMatrixID, 1, GL_TRUE, view.value_ptr);

		// 1rst attribute buffer : vertices
		glEnableVertexAttribArray(0);
		glBindBuffer(GL_ARRAY_BUFFER, vbo);
		glVertexAttribPointer(
							  0,                  // attribute
							  3,                  // size
							  GL_FLOAT,           // type
							  GL_FALSE,           // normalized?
							  0,                  // stride
							  cast(void*)0        // array buffer offset
								  );

		// 2nd attribute buffer : UVs
		glEnableVertexAttribArray(1);
		glBindBuffer(GL_ARRAY_BUFFER, uvbo);
		glVertexAttribPointer(
							  1,                                // attribute
							  2,                                // size
							  GL_FLOAT,                         // type
							  GL_FALSE,                         // normalized?
							  0,                                // stride
							   cast(void*)0                     // array buffer offset
							  );

		// 3rd attribute buffer : normals
		
		glEnableVertexAttribArray(2);
		glBindBuffer(GL_ARRAY_BUFFER, nbo);
		glVertexAttribPointer(
							  2,                                // attribute
							  3,                                // size
							  GL_FLOAT,                         // type
							  GL_FALSE,                         // normalized?
							  0,                                // stride
							  cast(void*)0                      // array buffer offset
							  );

		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, elementbo);


		// Draw the triangles !
		glDrawElements(
					   GL_TRIANGLES,      // mode
					   indices.length,    // count
					   GL_UNSIGNED_INT,   // type
					   null           // element array buffer offset
					   );
		
		//glDrawArrays(GL_TRIANGLES, 0, verts.length );
		//glDrawArrays(GL_TRIANGLES, 0, 12*3 );

		glDisableVertexAttribArray(0);
		glDisableVertexAttribArray(1);
		glDisableVertexAttribArray(2);

	}
}
