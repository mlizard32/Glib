module Glib.GUI.controls;
import Glib.GUI.Font;
import Glib.GUI.Widget;
import gl3n.linalg;
import Glib.GUI.UITexture;

import derelict.opengl3.gl;

class Label:Widget
{

}

class TextBox:Widget
{

}

class CheckBox:Widget
{

}

class Button:Widget
{

}

class ScrollView:Widget
{

}

class Surface:Widget
{
	UITexture texture;
	GLuint vbo;
	GLuint ibo;
	GLuint attribute_coord;

	this(vec2i topLeftCorner, int width, int height, UITexture _texture, GLuint progID)
	{
		this.pos = Rect(topLeftCorner.x, topLeftCorner.y, topLeftCorner.x + width, topLeftCorner.y - height);
		texture = _texture;

		GLuint[] indices = new GLuint[6];
		indices[ 0 ] = 0;
		indices[ 1 ] = 1;
		indices[ 2 ] = 2;
		indices[ 3 ] = 2;
		indices[ 4 ] = 1;
		indices[ 5 ] = 3;

		//glActiveTexture(GL_TEXTURE0);
		//glBindTexture(GL_TEXTURE_2D, texture.texId);
		//glUniform1i(uniform_tex, 0);

		//glEnableVertexAttribArray(attribute_coord);
		//glBindBuffer(GL_ARRAY_BUFFER, vbo);
		//glVertexAttribPointer(attribute_coord, 4, GL_FLOAT, GL_FALSE, 0, cast(void*)0);

		//attribute_coord = glGetAttribLocation(progID, "coord");

		vec3[] coords = RectToPoints(this.pos);		
		glGenBuffers(1, &vbo);
		glBindBuffer(GL_ARRAY_BUFFER, vbo);
		glBufferData(GL_ARRAY_BUFFER, coords.length * vec3.sizeof, cast(void*)coords, GL_STATIC_DRAW);
		glBindBuffer(GL_ARRAY_BUFFER, 0);

		glGenBuffers(1, &ibo);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);
		glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.length * GLuint.sizeof, cast(void*)indices, GL_STATIC_DRAW);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
	}

	vec3[] RectToPoints(Rect r)
	{
		vec3[] coords = new vec3[4];
		/*
		coords[0] = vec2i(r.left, r.top);
		coords[1] = vec2i(r.left, r.top - r.height);
		coords[2] = vec2i(r.left + r.width, r.top);;
		coords[3] = vec2i(r.right, r.bottom);
		*/

		coords[0] = vec3(-1.0, -1.0, 0.0);
		coords[1] = vec3(1.0, -1.0, 0.0);
		coords[2] = vec3(1.0, 1.0, 0.0);;
		coords[3] = vec3(-1.0, 1.0, 0.0);
		//coords[4] = vec2i(r.right, r.bottom + height);
		//coords[5] = vec2i(r.right - width, r.bottom);

		return coords;
	}
	void Draw()
	{
		
		

		glEnableVertexAttribArray(0);
		glBindBuffer( GL_ARRAY_BUFFER, vbo );
        glVertexAttribPointer(
							  0,                  // attribute
							  3,                  // size
							  GL_FLOAT,           // type
							  GL_FALSE,           // normalized?
							  0,                  // stride
							  cast(void*)0        // array buffer offset
								  );

        //Draw quad using vertex data and index data
        glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, ibo );
        glDrawElements( GL_TRIANGLES, 6, GL_UNSIGNED_INT, null );
		
		//glDrawArrays(GL_TRIANGLES, 0, 3);

		glDisableVertexAttribArray(0);
	}
}
