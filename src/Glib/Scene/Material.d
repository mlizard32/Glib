module Glib.Scene.Material;
import derelict.freeimage.freeimage;
import derelict.opengl3.gl3;

class Material
{
	Texture diffuse;
	Texture normal;
	Texture specular;

}
class Texture
{
	uint width;
	uint height;
	uint glID;

	this(string filePath)
	{
		filePath ~= '\0';
        auto imageData = FreeImage_ConvertTo32Bits( FreeImage_Load( FreeImage_GetFileType( filePath.ptr, 0 ), filePath.ptr, 0 ) );

		ubyte* buffer = cast(ubyte*)FreeImage_GetBits( imageData );
        width = FreeImage_GetWidth( imageData );
        height = FreeImage_GetHeight( imageData );

		

		glGenTextures( 1, &glID );
        glBindTexture( GL_TEXTURE_2D, glID );
        
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexImage2D( GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_BGRA, GL_UNSIGNED_BYTE, buffer );
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );

		FreeImage_Unload(imageData);
	}

}