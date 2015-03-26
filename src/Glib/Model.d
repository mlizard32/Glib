module Glib.Model;

import Glib.Log;
import Glib.Mesh;
import Glib.Transform;
import derelict.assimp3.assimp;

class Model
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
}

