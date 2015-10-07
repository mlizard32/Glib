module Glib.Scene.Shader;

import derelict.opengl3.gl3;
import Glib.System.Log;
import Glib.Scene.Material;
import std.conv;

class Shader
{
	static const defaultVertShader = "C:\\Users\\qtg843\\Documents\\Visual Studio 2012\\Projects\\Glib\\resources\\StandardShading.vertexshader";
	static const defaultFragShader = "C:\\Users\\qtg843\\Documents\\Visual Studio 2012\\Projects\\Glib\\resources\\StandardShading.fragmentshader";
	string vertSource;
	string fragSource;

	GLuint programID;

	char[] cstr;
	char[] cfstr;
	this(string vertexSourcePath, string fragmentSourcePath)
	{
		auto f = std.stdio.File(vertexSourcePath, "r");
		char[] line;
		while(f.readln(line))
		{
			vertSource ~= "\n" ~ line;
		}

		// Read the fragment shader code form file
		f = std.stdio.File(fragmentSourcePath, "r");
		while(f.readln(line))
		{
			fragSource ~= "\n" ~ line;
		}
	}

	
	this()
	{
		auto f = std.stdio.File(defaultVertShader, "r");
		char[] line;
		while(f.readln(line))
		{
			vertSource ~= "\n" ~ line;
		}

		// Read the fragment shader code form file
		f = std.stdio.File(defaultFragShader, "r");
		while(f.readln(line))
		{
			fragSource ~= "\n" ~ line;
		}
	}
	~this()
	{
		glDeleteProgram(programID);
	}

	GLuint LoadShader()
	{
		GLuint vertexShaderID = glCreateShader(GL_VERTEX_SHADER);
		GLuint fragmentShaderID = glCreateShader(GL_FRAGMENT_SHADER);

		GLint result = GL_FALSE;
		GLint infoLogLength;

		cstr = vertSource.dup;
		const char* vertexSourcePointer = cstr.ptr;
		const int vSourceLength = vertSource.length;
		//compile vertex shader
		glShaderSource(vertexShaderID, 1, &vertexSourcePointer, &vSourceLength);
		glCompileShader(vertexShaderID);

		glGetShaderiv(vertexShaderID, GL_COMPILE_STATUS, &result);
		glGetShaderiv(vertexShaderID, GL_INFO_LOG_LENGTH, &infoLogLength);


		if(result == GL_FALSE)
		{
			char[] vertexShaderErrorMessage;
			vertexShaderErrorMessage.length = infoLogLength + 1;
			glGetShaderInfoLog(vertexShaderID, infoLogLength, null, vertexShaderErrorMessage.ptr);
			infoLogLength = 0;
			Log.error(to!string(&vertexShaderErrorMessage[0]));
		}


		//Compile Fragment Shader
		cfstr = fragSource.dup;
		const char* fragmentSourcePointer = cfstr.ptr;
		const int fSourceLength = fragSource.length;
		//compile vertex shader
		glShaderSource(fragmentShaderID, 1, &fragmentSourcePointer, &fSourceLength);
		glCompileShader(fragmentShaderID);

		glGetShaderiv(fragmentShaderID, GL_COMPILE_STATUS, &result);
		glGetShaderiv(fragmentShaderID, GL_INFO_LOG_LENGTH, &infoLogLength);

		if(result == GL_FALSE)
		{
			char[] fragmentShaderErrorMessage;
			fragmentShaderErrorMessage.length = infoLogLength + 1;
			glGetShaderInfoLog(fragmentShaderID, infoLogLength, null, &fragmentShaderErrorMessage[0]);
			Log.error(to!string(&fragmentShaderErrorMessage[0]));
			infoLogLength = 0;
		}
		//Link Program

		programID = glCreateProgram();
		glAttachShader(programID, vertexShaderID);
		glAttachShader(programID, fragmentShaderID);
		glLinkProgram(programID);

		glGetProgramiv(programID, GL_LINK_STATUS, &result);
		glGetProgramiv(programID, GL_INFO_LOG_LENGTH, &infoLogLength);
		if(result == GL_FALSE)
		{
			char[] programErrorMessage;
			programErrorMessage.length = infoLogLength + 1;
			glGetProgramInfoLog(programID, infoLogLength, null, &programErrorMessage[0]);
			Log.error(to!string(&programErrorMessage[0]));
			infoLogLength = 0;
		}

		glDeleteShader(vertexShaderID);
		glDeleteShader(fragmentShaderID);


		GLuint returnval = programID;
		return returnval;
	}

	void BindMaterial(Material material)
	{
		GLuint diffuseId  = glGetUniformLocation(programID, "diffuseTexture");
		glUniform1i(diffuseId, 0);
        glActiveTexture( GL_TEXTURE0 );
        glBindTexture( GL_TEXTURE_2D, material.diffuse.glID );

	
        glUniform1i( glGetUniformLocation(programID, "normalTexture"), 1 );
        glActiveTexture( GL_TEXTURE1 );
        glBindTexture( GL_TEXTURE_2D, material.normal.glID );

        glUniform1i( glGetUniformLocation(programID, "specularTexture"), 2 );
        glActiveTexture( GL_TEXTURE2 );
        glBindTexture( GL_TEXTURE_2D, material.specular.glID );
		
	}
}

enum glslVersion = "#version 400\n";
/// Takes in a clip-space quad and interpolates the UVs
immutable string ambientlightVS = glslVersion ~ q{
    layout(location = 0) in vec3 vPosition_s;
    layout(location = 1) in vec2 vUV;

    out vec4 fPosition_s;
    out vec2 fUV;

    void main( void )
    {
        fPosition_s = vec4( vPosition_s, 1.0f );
        gl_Position = fPosition_s;
        fUV = vUV;
    }
};

/// Outputs the color for the diffuse * the ambient light value
immutable string ambientlightFS = glslVersion ~ q{
    struct AmbientLight
    {
        vec3 color;
    };

    in vec4 fPosition;
    in vec2 fUV;

    // this diffuse should be set to the geometry output
    uniform sampler2D diffuseTexture;
    uniform AmbientLight light;

    // https://stackoverflow.com/questions/9222217/how-does-the-fragment-shader-know-what-variable-to-use-for-the-color-of-a-pixel
    out vec4 color;

    void main( void )
    {
        color = vec4( light.color * texture( diffuseTexture, fUV ).xyz, 1.0f );
    }
};


/// Standard mesh vertex shader, transforms position to screen space and normals/tangents to view space
immutable string geometryVS = glslVersion ~ q{
    layout(location = 0) in vec3 vPosition_m;
    layout(location = 1) in vec2 vUV;
    layout(location = 2) in vec3 vNormal_m;
    layout(location = 3) in vec3 vTangent_m;

    out vec4 fPosition_s;
    out vec3 fNormal_v;
    out vec2 fUV;
    out vec3 fTangent_v;
    flat out uint fObjectId;

    uniform mat4 worldView;
    uniform mat4 worldViewProj;
    uniform uint objectId;

    void main( void )
    {
        // gl_Position is like SV_Position
        fPosition_s = worldViewProj * vec4( vPosition_m, 1.0f );
        gl_Position = fPosition_s;
        fUV = vUV;

        fNormal_v = ( worldView * vec4( vNormal_m, 0.0f ) ).xyz;
        fTangent_v =  ( worldView * vec4( vTangent_m, 0.0f ) ).xyz;
        fObjectId = objectId;
    }
};

/// Saves diffuse, specular, mappedNormals (encoded to spheremapped XY), and object ID to appropriate FBO textures
immutable string geometryFS = glslVersion ~ q{
    in vec4 fPosition_s;
    in vec3 fNormal_v;
    in vec2 fUV;
    in vec3 fTangent_v;
    flat in uint fObjectId;

    layout( location = 0 ) out vec4 color;
    layout( location = 1 ) out vec4 normal_v;

    uniform sampler2D diffuseTexture;
    uniform sampler2D normalTexture;
    uniform sampler2D specularTexture;

    vec2 encode( vec3 normal )
    {
        float t = sqrt( 2 / ( 1 - normal.z ) );
        return normal.xy * t;
    }

    vec3 calculateMappedNormal()
    {
        vec3 normal = normalize( fNormal_v );
        vec3 tangent = normalize( fTangent_v );
        //Use Gramm-Schmidt process to orthogonalize the two
        tangent = normalize( tangent - dot( tangent, normal ) * normal );
        vec3 bitangent = -cross( tangent, normal );
        vec3 normalMap = ((texture( normalTexture, fUV ).xyz) * 2) - 1;
        mat3 TBN = mat3( tangent, bitangent, normal );
        return normalize( TBN * normalMap );
    }

    void main( void )
    {
        color = texture( diffuseTexture, fUV );
        // specular intensity
        vec3 specularSample = texture( specularTexture, fUV ).xyz;
        color.w = ( specularSample.x + specularSample.y + specularSample.z ) / 3;
        normal_v = vec4( calculateMappedNormal(), float(fObjectId) );
    }
};


/// Takes in a clip-space quad and creates a ray from camera to each vertex, which is interpolated during pass-through
immutable string directionallightVS = glslVersion ~ q{
    layout(location = 0) in vec3 vPosition_s;
    layout(location = 1) in vec2 vUV;

    uniform mat4 invProj;

    out vec4 fPosition_s;
    out vec2 fUV;
    out vec3 fViewRay;

    void main( void )
    {
        fPosition_s = vec4( vPosition_s, 1.0f );
        gl_Position = fPosition_s;

        vec3 position_v = ( invProj * vec4( vPosition_s, 1.0f ) ).xyz;
        // This is the ray clamped to depth 1, and it'll just be moved & interpolated in the XY
        fViewRay = vec3( position_v.xy / position_v.z, 1.0f );
        fUV = vUV;
    }
};

/// Calculates diffuse and specular lights from the full-screen directional light, 
/// using the view ray to reconstruct pixel position
immutable string directionallightFS = glslVersion ~ q{
    struct DirectionalLight
    {
        vec3 color;
        vec3 direction;
        float shadowless;
    };

    in vec4 fPosition_s;
    in vec2 fUV;
    in vec3 fViewRay;

    // g-buffer outputs
    uniform sampler2D diffuseTexture;
    uniform sampler2D normalTexture;
    uniform sampler2D depthTexture;

    // shadow map values
    uniform sampler2D shadowMap;
    uniform mat4 lightProjView;
    uniform mat4 cameraView;

    uniform DirectionalLight light;

    // A pair of constants for reconstructing the linear Z
    // [ (-Far * Near ) / ( Far - Near ),  Far / ( Far - Near )  ]
    uniform vec2 projectionConstants;

    // https://stackoverflow.com/questions/9222217/how-does-the-fragment-shader-know-what-variable-to-use-for-the-color-of-a-pixel
    layout( location = 0 ) out vec4 color;

    // Function for decoding normals
    vec3 decode( vec2 enc )
    {
        float t = ( ( enc.x * enc.x ) + ( enc.y * enc.y ) ) / 4;
        float ti = sqrt( 1 - t );
        return vec3( ti * enc.x, ti * enc.y, -1 + t * 2 );
    }

    float shadowValue(vec3 pos)
    {
        mat4 toShadowMap_s = lightProjView * inverse(cameraView);
        vec4 lightSpacePos = toShadowMap_s * vec4( pos, 1 );
        lightSpacePos = lightSpacePos / lightSpacePos.w;

        vec2 shadowCoords = (lightSpacePos.xy * 0.5) + vec2( 0.5, 0.5 );

        float depthValue = texture( shadowMap, shadowCoords ).x -  0.0001;

        return float( (lightSpacePos.z * .5 + .5 ) < depthValue );
    }

    void main( void )
    {
        vec3 textureColor = texture( diffuseTexture, fUV ).xyz;
        float specularIntensity = texture( diffuseTexture, fUV ).w;
        vec3 normal_v = texture( normalTexture, fUV ).xyz;
        vec3 lightDir_v = -normalize( light.direction );

        // Reconstruct position from Depth
        float depth = texture( depthTexture, fUV ).x;
        float linearDepth = projectionConstants.x / ( projectionConstants.y - depth );
        vec3 position_v = fViewRay * linearDepth;


        // Diffuse lighting calculations
        float diffuseScale = clamp( dot( normal_v, lightDir_v ), 0, 1 );

        // Specular lighting calculations
        // Usually in these you see an "eyeDirection" variable, but in view space that is our position
        float specularScale = clamp( dot( normalize( position_v ), reflect( lightDir_v, normal_v ) ), 0, 1 );

        vec3 diffuse = ( diffuseScale * light.color ) * textureColor;
        // "8" is the reflectiveness
        // textureColor.w is the shininess
        // specularIntensity is the light's contribution
        vec3 specular = ( pow( specularScale, 8 ) * light.color * specularIntensity);

        color = vec4( ( diffuse + specular ), 1.0f );
    }
};


/// Takes a mesh representing the possible area of the light and creates a ray to each vertex
immutable string pointlightVS = glslVersion ~ q{
    layout(location = 0) in vec3 vPosition_m;
    layout(location = 1) in vec2 vUV;
    layout(location = 2) in vec3 vNormal_m;
    layout(location = 3) in vec3 vTangent_m;

    out vec4 fPosition_s;
    out vec3 fViewRay;

    //uniform mat4 world;
    uniform mat4 worldView;
    uniform mat4 worldViewProj;

    void main( void )
    {
        // gl_Position is like SV_Position
        fPosition_s = worldViewProj * vec4( vPosition_m, 1.0f );
        gl_Position = fPosition_s;

        fViewRay = ( worldView * vec4( vPosition_m, 1.0 ) ).xyz;

    }
};

/// Outputs diffuse and specular color from the light, using the view ray to reconstruct position and a falloff rate to attenuate
immutable string pointlightFS = glslVersion ~ q{
    struct PointLight{
        vec3 pos_v;
        vec3 color;
        float radius;
        float falloffRate;
    };

    in vec4 fPosition_s;
    in vec3 fViewRay;

    out vec4 color;

    uniform sampler2D diffuseTexture;
    uniform sampler2D normalTexture;
    uniform sampler2D depthTexture;
    uniform PointLight light;
    // A pair of constants for reconstructing the linear Z
    // [ (-Far * Near ) / ( Far - Near ),  Far / ( Far - Near )  ]
    uniform vec2 projectionConstants;

    // Function for decoding normals
    vec3 decode( vec2 enc )
    {
        float t = ( ( enc.x * enc.x ) + ( enc.y * enc.y ) ) / 4;
        float ti = sqrt( 1 - t );
        return vec3( ti * enc.x, ti * enc.y, -1 + t * 2 );
    }

    void main( void )
    {
        // The viewray should have interpolated across the pixels covered by the light, so we should just be able to clamp it's depth to 1
        vec3 viewRay = vec3( fViewRay.xy / fViewRay.z, 1.0f );
        vec2 UV = ( ( fPosition_s.xy / fPosition_s.w ) + 1 ) / 2;
        vec3 textureColor = texture( diffuseTexture, UV ).xyz;
        float specularIntensity = texture( diffuseTexture, UV ).w;
        vec3 normal_v = texture( normalTexture, UV ).xyz;

        // Reconstruct position from depth
        float depth = texture( depthTexture, UV ).x;
        float linearDepth = projectionConstants.x / ( projectionConstants.y - depth );
        vec3 position_v = viewRay * linearDepth;

        // calculate normalized light direction, and distance
        vec3 lightDir_v = light.pos_v - position_v;
        float distance = sqrt( dot(lightDir_v,lightDir_v) );
        lightDir_v = normalize( lightDir_v );

        // calculate exponential attenuation
        float attenuation = pow( max( 1-distance/light.radius, 0), light.falloffRate + 1.0f );

        // Diffuse lighting calculations
        float diffuseScale = clamp( dot( normal_v, lightDir_v ), 0, 1 );

        // Specular lighting calculations
        // Usually in these you see an "eyeDirection" variable, but in view space that is our position
        float specularScale = clamp( dot( normalize( position_v ), reflect( lightDir_v, normal_v ) ), 0, 1 );

        vec3 diffuse = ( diffuseScale * light.color ) * textureColor ;
        // "8" is the reflectiveness
        // textureColor.w is the shininess
        // specularIntensity is the light's contribution
        vec3 specular = ( pow( specularScale, 8 ) * light.color * specularIntensity);

        color = vec4((diffuse + specular ) * attenuation, 1.0f ) ;
        //color = vec4( vec3(1,0,0), 1.0f );

    }
};