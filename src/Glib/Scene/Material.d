module Glib.Scene.Material;
import derelict.freeimage.freeimage;
import derelict.opengl3.gl3;
import gl3n.linalg;
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

	this(vec4i color)
	{
		auto imageData = singleColorTexture(color);
		ubyte* buffer =  cast(ubyte*)&imageData[0];

		glGenTextures( 1, &glID );
        glBindTexture( GL_TEXTURE_2D, glID );

        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexImage2D( GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_BGRA, GL_UNSIGNED_BYTE, buffer );
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
	}

	auto  singleColorTexture( vec4i color)
	{
		ubyte[32] singleColorTex;

		for(int i = 0; i < 32; i)
		{
			singleColorTex[i++] = cast(ubyte)color.x;
			singleColorTex[i++] = cast(ubyte)color.y;
			singleColorTex[i++] = cast(ubyte)color.z;
			singleColorTex[i++] = cast(ubyte)color.w;
		}
		return singleColorTex;
	}
	
}

