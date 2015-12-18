module Glib.Scene.Render;

import derelict.opengl3.gl3;
import derelict.sdl2.sdl;
import gl3n.linalg;
import Glib.Scene.Scene;
import Glib.Scene.RMObject;
import Glib.Scene.Node;
import Glib.Scene.Shader;
import Glib.Scene.Mesh;
import Glib.System.Window;
import Glib.System.Log;
import imgui;

import derelict.assimp3.assimp;
import std.string;

import gtk.GLArea;

struct Render
{
	uint _deferredFrameBuffer;
    uint _diffuseRenderTexture; 
    uint _normalRenderTexture; 
    uint _depthRenderTexture;

	//unit square object
	Mesh mesh;

	void Complete()
	{
		//swap buffers
		//SDL_GL_SwapWindow
	}

	void initialize(uint width, uint height)
	{
		
		enum aiImportOptions = aiProcess_CalcTangentSpace | aiProcess_Triangulate | aiProcess_JoinIdenticalVertices | aiProcess_SortByPType;
		mesh = new Mesh(aiImportFileFromMemory(unitSquareMesh.toStringz(), unitSquareMesh.length, aiImportOptions, "obj").mMeshes[0]);

		initializeFrameBuffer(width, height);
	}
	void initializeFrameBuffer(uint width, uint height)
	{
		//Create the frame buffer, which will contain the textures to render to
        _deferredFrameBuffer = 0;
        glGenFramebuffers( 1, &_deferredFrameBuffer );
        glBindFramebuffer( GL_FRAMEBUFFER, _deferredFrameBuffer );

        //Generate our 3 textures
        glGenTextures( 1, &_diffuseRenderTexture );
        glGenTextures( 1, &_normalRenderTexture );
        glGenTextures( 1, &_depthRenderTexture );

        // Initialize render textures
        resizeDefferedRenderBuffer(width, height);

        //And finally set all of these to our frameBuffer
        glFramebufferTexture2D( GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _diffuseRenderTexture, 0 );
        glFramebufferTexture2D( GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT1, GL_TEXTURE_2D, _normalRenderTexture, 0 );
        glFramebufferTexture2D( GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, _depthRenderTexture, 0 );

        GLenum[ 2 ] DrawBuffers = [ GL_COLOR_ATTACHMENT0, GL_COLOR_ATTACHMENT1 ];
        glDrawBuffers( 2, DrawBuffers.ptr );

        auto status = glCheckFramebufferStatus( GL_FRAMEBUFFER );
        if( status != GL_FRAMEBUFFER_COMPLETE )
        {
			Log.error("error creating framebuffer");
//			throw new Exception();
		}
	}

	final void resizeDefferedRenderBuffer(uint width, uint height)
    {
        //For each texture, we bind it to our active texture, and set the format and filtering
        glBindTexture( GL_TEXTURE_2D, _diffuseRenderTexture );
        glTexImage2D( GL_TEXTURE_2D, 0, GL_RGBA8, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, null );
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );

        glBindTexture( GL_TEXTURE_2D, _normalRenderTexture );
        glTexImage2D( GL_TEXTURE_2D, 0, GL_RGBA16F, width, height, 0, GL_RGBA, GL_FLOAT, null );
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );

        glBindTexture( GL_TEXTURE_2D, _depthRenderTexture );
        glTexImage2D( GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT32, width, height, 0, GL_DEPTH_COMPONENT, GL_FLOAT, null );
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );
    }


	void rScene(Scene scene, window w)
	{
		if(!scene)
			Log.error("no active scene to render");
		if(!scene.mainCamera)
			Log.error("no camera set in scene");
		
		//need to make a check to see if obj is even visible


		//render geometry 
		glBindFramebuffer(GL_FRAMEBUFFER, _deferredFrameBuffer);
		glDepthMask(GL_TRUE);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		glEnable(GL_DEPTH_TEST);
		glDisable(GL_BLEND);
		
		//glClearColor(0.1f, 0.1f, 0.1f, 1.0f);
		TraverseDraw(scene.root);
		void geometryPass()
		{
			
		}
		glViewport(0,0, cast(GLsizei)w.size.x, cast(GLsizei)w.size.y);
		//render shadow pass

		GLenum error = glGetError();
		if(error != GL_NO_ERROR)
			Log.error("glError");
		// settings for light pass
        glDepthMask( GL_FALSE );
        glDisable( GL_DEPTH_TEST );
        glEnable( GL_BLEND );
        glBlendFunc( GL_ONE, GL_ONE );

		error = glGetError();
		if(error != GL_NO_ERROR)
			Log.error("glError");

        //This line switches back to the default framebuffer
        glBindFramebuffer( GL_FRAMEBUFFER, 0 );
        glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
		//render light pass
		void bindGeometryOutputs(uint programId)
		{
			// diffuse

			glUniform1i( glGetUniformLocation(programId, "diffuseTexture"), 0 );
			glActiveTexture( GL_TEXTURE0 );
			glBindTexture( GL_TEXTURE_2D, _diffuseRenderTexture );

			// normal
			glUniform1i( glGetUniformLocation(programId, "normalTexture"), 1 );
			glActiveTexture( GL_TEXTURE1 );
			glBindTexture( GL_TEXTURE_2D, _normalRenderTexture );

			// depth
			glUniform1i( glGetUniformLocation(programId, "depthTexture") , 2 );
			glActiveTexture( GL_TEXTURE2 );
			glBindTexture( GL_TEXTURE_2D, _depthRenderTexture );
		}
		Shader shader;
		


		
		error = glGetError();
		if(error != GL_NO_ERROR)
			Log.error("glError");

		//Ambient Light
		shader = new Shader();
		shader.vertSource = ambientlightVS;
		shader.fragSource = ambientlightFS;
		shader.LoadShader();
		glUseProgram( shader.programID );

		bindGeometryOutputs(shader.programID);

		error = glGetError();
		if(error != GL_NO_ERROR)
			Log.error("glError");

		glUniform3f(glGetUniformLocation(shader.programID, "light.color"), .3f, .3f, .3f);
		
		// bind the window mesh for ambient lights

		glBindVertexArray( mesh.VertexArrayID );
		glDrawElements( GL_TRIANGLES, mesh.indices.length, GL_UNSIGNED_INT, null );;

		error = glGetError();
		if(error != GL_NO_ERROR)
			Log.error("glError");


		//Directional light
		shader = new Shader();
		shader.vertSource = directionallightVS;
		shader.fragSource = directionallightFS;
		shader.LoadShader();
		glUseProgram( shader.programID );
	
		bindGeometryOutputs(shader.programID);
		mat4 invProj = scene.mainCamera.getInversePerspectiveMatrix();
		float near = 0.1f;
		float far = 100.0f;
		vec2 projectionConstants = vec2( ( -far * near ) / ( far - near ), far / ( far - near ) );

		GLuint test = glGetUniformLocation(shader.programID, "invProj");
	
		glUniformMatrix4fv( test,  1, GL_TRUE, invProj.value_ptr);

		glUniform2f( glGetUniformLocation(shader.programID, "projectionConstants"), projectionConstants.x, projectionConstants.y );
	
		//shader.bindUniformMatrix4fv( shader.LightProjectionView, light.projView );
		glUniformMatrix4fv( glGetUniformLocation(shader.programID, "cameraView"), 1, GL_TRUE, scene.mainCamera.getViewMatrix().value_ptr);

		vec3 origin = vec3(0f);
		vec3 lightPos = vec3(4,4, 4);

		vec3 dir = (lightPos - origin);
		
		glUniform3f( glGetUniformLocation(shader.programID, "light.direction"), dir.x, dir.y, dir.z);
		glUniform3f( glGetUniformLocation(shader.programID, "light.color"), 1f, 1f, 1f );
		
		glBindVertexArray( mesh.VertexArrayID );
		glDrawElements( GL_TRIANGLES, mesh.indices.length, GL_UNSIGNED_INT, null );
		

		glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );

		//render UI

		/*
		const scrollAreaWidth = w.size.x / 4;
        const scrollAreaHeight =  w.size.y - 20;
		int scrollArea2 = 0;

		imguiBeginScrollArea("Scroll area 2", 20 + (1 * scrollAreaWidth), 10, scrollAreaWidth, scrollAreaHeight, &scrollArea2);
        imguiSeparatorLine();
        imguiSeparator();

        foreach (i; 0 .. 100)
            imguiLabel("A wall of text");

        imguiEndScrollArea();

		imguiDrawText(0, 0, TextAlign.left, "Free text", RGBA(32, 192, 32, 192));
		imguiRender( w.size.x, w.size.y);
*/

		glBindVertexArray(0);
        glUseProgram(0);
		
	}

	void rScene(Scene scene, GLArea area)
	{
		if(!scene)
			Log.error("no active scene to render");
		if(!scene.mainCamera)
			Log.error("no camera set in scene");

		//need to make a check to see if obj is even visible


		//render geometry 
		glBindFramebuffer(GL_FRAMEBUFFER, _deferredFrameBuffer);
		glDepthMask(GL_TRUE);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		glEnable(GL_DEPTH_TEST);
		glDisable(GL_BLEND);

		//glClearColor(0.1f, 0.1f, 0.1f, 1.0f);
		TraverseDraw(scene.root);
		void geometryPass()
		{

		}
		glViewport(0,0, cast(GLsizei)720, cast(GLsizei)480);
		//render shadow pass

		GLenum error = glGetError();
		if(error != GL_NO_ERROR)
			Log.error("glError");
		// settings for light pass
        glDepthMask( GL_FALSE );
        glDisable( GL_DEPTH_TEST );
        glEnable( GL_BLEND );
        glBlendFunc( GL_ONE, GL_ONE );

		error = glGetError();
		if(error != GL_NO_ERROR)
			Log.error("glError");

        //This line switches back to the default framebuffer
       // glBindFramebuffer( GL_FRAMEBUFFER, 0 );
		area.attachBuffers();
        glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
		//render light pass
		void bindGeometryOutputs(uint programId)
		{
			// diffuse

			glUniform1i( glGetUniformLocation(programId, "diffuseTexture"), 0 );
			glActiveTexture( GL_TEXTURE0 );
			glBindTexture( GL_TEXTURE_2D, _diffuseRenderTexture );

			// normal
			glUniform1i( glGetUniformLocation(programId, "normalTexture"), 1 );
			glActiveTexture( GL_TEXTURE1 );
			glBindTexture( GL_TEXTURE_2D, _normalRenderTexture );

			// depth
			glUniform1i( glGetUniformLocation(programId, "depthTexture") , 2 );
			glActiveTexture( GL_TEXTURE2 );
			glBindTexture( GL_TEXTURE_2D, _depthRenderTexture );
		}
		Shader shader;




		error = glGetError();
		if(error != GL_NO_ERROR)
			Log.error("glError");

		//Ambient Light
		shader = new Shader();
		shader.vertSource = ambientlightVS;
		shader.fragSource = ambientlightFS;
		shader.LoadShader();
		glUseProgram( shader.programID );

		bindGeometryOutputs(shader.programID);

		error = glGetError();
		if(error != GL_NO_ERROR)
			Log.error("glError");

		glUniform3f(glGetUniformLocation(shader.programID, "light.color"), .3f, .3f, .3f);

		// bind the window mesh for ambient lights

		glBindVertexArray( mesh.VertexArrayID );
		glDrawElements( GL_TRIANGLES, mesh.indices.length, GL_UNSIGNED_INT, null );;

		error = glGetError();
		if(error != GL_NO_ERROR)
			Log.error("glError");


		//Directional light
		shader = new Shader();
		shader.vertSource = directionallightVS;
		shader.fragSource = directionallightFS;
		shader.LoadShader();
		glUseProgram( shader.programID );

		bindGeometryOutputs(shader.programID);
		mat4 invProj = scene.mainCamera.getInversePerspectiveMatrix();
		float near = 0.1f;
		float far = 100.0f;
		vec2 projectionConstants = vec2( ( -far * near ) / ( far - near ), far / ( far - near ) );

		GLuint test = glGetUniformLocation(shader.programID, "invProj");

		glUniformMatrix4fv( test,  1, GL_TRUE, invProj.value_ptr);

		glUniform2f( glGetUniformLocation(shader.programID, "projectionConstants"), projectionConstants.x, projectionConstants.y );

		//shader.bindUniformMatrix4fv( shader.LightProjectionView, light.projView );
		glUniformMatrix4fv( glGetUniformLocation(shader.programID, "cameraView"), 1, GL_TRUE, scene.mainCamera.getViewMatrix().value_ptr);

		vec3 origin = vec3(0f);
		vec3 lightPos = vec3(4,4, 4);

		vec3 dir = (lightPos - origin);

		glUniform3f( glGetUniformLocation(shader.programID, "light.direction"), dir.x, dir.y, dir.z);
		glUniform3f( glGetUniformLocation(shader.programID, "light.color"), 1f, 1f, 1f );

		glBindVertexArray( mesh.VertexArrayID );
		glDrawElements( GL_TRIANGLES, mesh.indices.length, GL_UNSIGNED_INT, null );


		glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );

		//render UI

		/*
		const scrollAreaWidth = w.size.x / 4;
        const scrollAreaHeight =  w.size.y - 20;
		int scrollArea2 = 0;

		imguiBeginScrollArea("Scroll area 2", 20 + (1 * scrollAreaWidth), 10, scrollAreaWidth, scrollAreaHeight, &scrollArea2);
        imguiSeparatorLine();
        imguiSeparator();

        foreach (i; 0 .. 100)
		imguiLabel("A wall of text");

        imguiEndScrollArea();

		imguiDrawText(0, 0, TextAlign.left, "Free text", RGBA(32, 192, 32, 192));
		imguiRender( w.size.x, w.size.y);
		*/

		glBindVertexArray(0);
        glUseProgram(0);

	}

	
	void TraverseDraw(RMObject g)
	{
		//Draw This object
		foreach(IComponent component; g.components)
		{
			IDrawable draw = cast(IDrawable) component;
			if(draw !is null)
				draw.Draw();
		}
		
		//Draw Children
		foreach(Node gChild; g.getChildren())
		{
			
			TraverseDraw(cast(RMObject)gChild);
		}
	}
}

interface IDrawable
{
	void Draw();
}

