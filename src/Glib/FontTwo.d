module Glib.FontTwo;

import derelict.opengl3.gl3;
import derelict.freetype.ft;
import std.c.string;
import std.file;
import std.stdio;
import std.algorithm;

class atlas 
{
	GLuint texture;

	int width;
	int height;
	static const int MAXWIDTH = 512;

	characters[] chars = new characters[128];

	this(FT_Face face, int fontHeight, GLuint uniform_tex)
	{
		FT_Set_Pixel_Sizes(face, 0, fontHeight);
		FT_GlyphSlot g = face.glyph;

		int roww = 0;
		int rowh = 0;
		width = 0;
		height = 0;

		for(int j = 32; j < 128;j ++)
		{
			if (FT_Load_Char(face, j, FT_LOAD_RENDER))
			{
				continue;
			}
			if(roww + g.bitmap.width + 1 >= MAXWIDTH)
			{
				width = max(width, roww);
				height += rowh;
				rowh = 0;
				roww = 0;
			}
			roww +=g.bitmap.width + 1;
			rowh = max(rowh, g.bitmap.rows);
		}
		
		width = max(width, roww);
		height += rowh;

		glActiveTexture(GL_TEXTURE0);
		glGenTextures(1, &texture);
		glBindTexture(GL_TEXTURE_2D, texture);
		glUniform1i(uniform_tex, 0);

		glTexImage2D(GL_TEXTURE_2D, 0, GL_ALPHA, width, height, 0, GL_ALPHA, GL_UNSIGNED_BYTE, cast(void*)0);

		/* We require 1 byte alignment when uploading texture data */
		glPixelStorei(GL_UNPACK_ALIGNMENT, 1);

		/* Clamping to edges is important to prevent artifacts when scaling */
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

		/* Linear filtering usually looks best for text */
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

		/* Paste all glyph bitmaps into the texture, remembering the offset */
		int offsetX = 0;
		int offsetY = 0;

		rowh = 0;

		for(int i = 32; i < 128; i++)
		{
			if(FT_Load_Char(face, i, FT_LOAD_RENDER))
			{
				continue;
			}

			if(offsetX + g.bitmap.width + 1 >= MAXWIDTH)
			{
				offsetY += rowh;
				rowh = 0;
				offsetX = 0;
			}

			glTexSubImage2D(GL_TEXTURE_2D, 0, offsetX, offsetY, g.bitmap.width, g.bitmap.rows, GL_ALPHA,
							GL_UNSIGNED_BYTE, g.bitmap.buffer);
			chars[i].advanceX = g.advance.x >> 6;
			chars[i].advanceY = g.advance.y >> 6;

			chars[i].bitmapWidth = g.bitmap.width;
			chars[i].bitmapHeight = g.bitmap.rows;

			chars[i].bitmapLeft = g.bitmap_left;
			chars[i].bitmapTop = g.bitmap_top;

			chars[i].textureX = cast(float)offsetX / cast(float)width;
			chars[i].textureY = cast(float)offsetY / cast(float)height;
			
			rowh = max(rowh, g.bitmap.rows);
			offsetX += g.bitmap.width + 1;
		}
	}
	~this() {
		glDeleteTextures(1, &texture);
	}
}
struct characters 
{
	float advanceX;
	float advanceY;

	float bitmapWidth;
	float bitmapHeight;

	float bitmapLeft;
	float bitmapTop;

	float textureX;
	float textureY;
}
struct point {
	GLfloat x;
	GLfloat y;
	GLfloat s;
	GLfloat t;
}
class FontTwo
{
	FT_Face face;
	FT_Library library;
	GLuint vbo;

	GLint attribute_coord;
	GLint uniform_tex;
	GLint uniform_color;

	atlas fontAtlas;

	this(GLint progID, int fSize, string fontPath)
	{
		FT_Error error;

		error = FT_Init_FreeType(&library);
		if(error)
		{
			//throw error
		}
		if(FT_New_Face(library, std.string.toStringz(fontPath), 0, &face))
		{
			//throw error
		}
		glUseProgram(progID);
		//get attributes
		attribute_coord = glGetAttribLocation(progID, "coord");
		uniform_tex = glGetUniformLocation(progID, "tex");
		uniform_color = glGetUniformLocation(progID, "color");

		glGenBuffers(1, &vbo);
		
		fontAtlas = new atlas(face, 24, uniform_tex);

	}

	void render_text(string text, float x, float y, float sx, float sy)
	{
		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		glDisable(GL_CULL_FACE);

		GLfloat[4] black = [ 1, 1, 1, 1 ];
		glUniform4fv(uniform_color, 1, cast(float*)black);

		glActiveTexture(GL_TEXTURE0);
		glBindTexture(GL_TEXTURE_2D, fontAtlas.texture);
		glUniform1i(uniform_tex, 0);

		glEnableVertexAttribArray(attribute_coord);
		glBindBuffer(GL_ARRAY_BUFFER, vbo);
		glVertexAttribPointer(attribute_coord, 4, GL_FLOAT, GL_FALSE, 0, cast(void*)0);

		point[] coords = new point[6 * text.length];
		int c = 0;

		foreach(char letter; text)
		{
			float xTwo = x + fontAtlas.chars[letter].bitmapLeft * sx;
			float yTwo = -y - fontAtlas.chars[letter].bitmapTop * sy;
			float w = fontAtlas.chars[letter].bitmapWidth * sx;
			float h = fontAtlas.chars[letter].bitmapHeight * sy;

			x += fontAtlas.chars[letter].advanceX * sx;
			y += fontAtlas.chars[letter].advanceY * sy;

			if (!w || !h)
				continue;

			coords[c++] = point(xTwo, -yTwo, fontAtlas.chars[letter].textureX, fontAtlas.chars[letter].textureY);
			coords[c++] = point(xTwo + w, -yTwo, fontAtlas.chars[letter].textureX + fontAtlas.chars[letter].bitmapWidth /fontAtlas.width, fontAtlas.chars[letter].textureY);
			coords[c++] = point(xTwo, -yTwo - h, fontAtlas.chars[letter].textureX, fontAtlas.chars[letter].textureY + fontAtlas.chars[letter].bitmapHeight / fontAtlas.height);
			coords[c++] = point(xTwo + w, -yTwo, fontAtlas.chars[letter].textureX + fontAtlas.chars[letter].bitmapWidth /fontAtlas.width, fontAtlas.chars[letter].textureY);
			coords[c++] = point(xTwo, -yTwo - h, fontAtlas.chars[letter].textureX, fontAtlas.chars[letter].textureY + fontAtlas.chars[letter].bitmapHeight / fontAtlas.height);
			coords[c++] = point(xTwo + w, -yTwo - h, fontAtlas.chars[letter].textureX + fontAtlas.chars[letter].bitmapWidth /
				fontAtlas.width, fontAtlas.chars[letter].textureY + fontAtlas.chars[letter].bitmapHeight / fontAtlas.height);
		}

		glBufferData(GL_ARRAY_BUFFER, coords.length * point.sizeof, cast(void*)coords, GL_DYNAMIC_DRAW);
		glDrawArrays(GL_TRIANGLES, 0, c);

		glDisableVertexAttribArray(attribute_coord);

		glDisable(GL_BLEND);
		glEnable(GL_CULL_FACE);
	}
}