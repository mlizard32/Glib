module Glib.GUI.UITexture;

import derelict.opengl3.gl3;
import derelict.freeimage.freeimage;

class UITexture
{
	GLuint texId;
	uint width;
	uint height;
	ubyte depth;

	Format format;

	enum Format {
		None = 0,							/// Take this if you want to declare that you give no Format.
		RGB = GL_RGB,						/// Alias for GL_RGB
		RGBA = GL_RGBA,						/// Alias for GL_RGBA
		BGR = GL_BGR,						/// Alias for GL_BGR
		BGRA = GL_BGRA,						/// Alias for GL_BGRA
		RGBA16 = GL_RGBA16,					/// 16 Bit RGBA Format
		RGBA8 = GL_RGBA8,					/// 8 Bit RGBA Format
		Alpha = GL_ALPHA,					/// Alias for GL_ALPHA
		//Luminance = GL_LUMINANCE,			/// Alias for GL_LUMINANCE
		//LuminanceAlpha = GL_LUMINANCE_ALPHA,/// Alias for GL_LUMINANCE_ALPHA
		CompressedRGB = GL_COMPRESSED_RGB,	/// Compressed RGB
		CompressedRGBA = GL_COMPRESSED_RGBA /// Compressed RGBA
	}

	this(string filePath)
	{
		FREE_IMAGE_FORMAT fif = FIF_UNKNOWN;
		fif = FreeImage_GetFileType( std.string.toStringz(filePath), 0);
		if(fif ==  FIF_UNKNOWN)
		{

		}

		FIBITMAP* bitmap = FreeImage_Load(fif, std.string.toStringz(filePath));
		BYTE* imageBits = cast(ubyte*)0;

		width = FreeImage_GetWidth(bitmap);
		height = FreeImage_GetHeight(bitmap);
		imageBits = FreeImage_GetBits(bitmap);

		format = Format.RGB;

		glGenTextures(1, &texId);
		glBindTexture(GL_TEXTURE_2D, texId);
		glTexImage2D(GL_TEXTURE_2D, 0, format, width, height, 0, format, GL_UNSIGNED_BYTE, imageBits);

		if(bitmap)
			FreeImage_Unload(bitmap);

	}

	~this() {
		glDeleteTextures(1, &texId);
	}

}