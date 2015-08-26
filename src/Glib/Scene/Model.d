module Glib.Scene.Model;

import Glib.System.Log;
import Glib.Scene.Mesh;
import Glib.Scene.Transform;
import Glib.Scene.Render;
import Glib.Scene.GObject;
import derelict.assimp3.assimp;

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

