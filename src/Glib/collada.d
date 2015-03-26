module Glib.collada;
/*
import std.xml;
import std.file;
import Glib.Mesh;

class Collada
{
	DocumentParser xml;
	string originalXML;
	Mesh[] meshes;

	this(string filename)
	{
		originalXML = cast(string)std.file.read(filename);
		//check(s);
		xml = new DocumentParser(originalXML);

		getGeometry();
	}

	void getGeometry()
	{
		if(meshes.length > 0)
		{
			meshes.clear();
			meshes.shrinkTo(0);
		}
		//loop through scenes
		
		//get geometry id
		getGeometryID();
		//get controller info (skin and animation controller)

		//get model from geometry ID
		
	}
	void getGeometryID()
	{
		
		xml.onStartTag["library_visual_scenes"] = &getURL;
		xml.parse();

	}
	void getURL(ElementParser parser)
	{
		string ID;
		parser.onStartTag["instance_geometry"] = (ElementParser parser)
		{
			ID = parser.tag.attr["url"];
			if(ID.length)
			{
				getGeometryByID(ID);
			}

		};
		parser.parse();
		
	}
	void getGeometryByID(string id)
	{
		struct Input
		{
			float[] data;
			ushort components = 3;
			ushort offset;
			string name;
		}
		Input[] inputs;
		auto pXML = new DocumentParser(originalXML);
		void getMesh(ElementParser parser)
		{
			string[] types = ["polylist", "triangles", "polygons"];
			
			parser.onStartTag["triangles"] = &getInput;
			parser.parse();
			
		}
		void getInput(ElementParser parser)
		{
			Input iPut;
			int[] indicies;
			string indiceText;

			parser.OnEndTag["p"] = (in Element e) {indiceText = e.text();};
			
			iPut.name = parser.tag.attr["semantic"];
			if(iPut.name == "VERTICIES")
			{
				
			}
			string source = parser.tag.attr["source"];
			iPut.offset = parser.tag.attr["offset"];
			iPut.data = getDataFromSource(source, iPut.components);
			
			parser.parse();
			indicies = parseNumberList!(int)(indiceText);

			int c = iPut.components;
			int indiciesPerVertex = 0;
			if(iPut.offset > indiciesPerVertex)
				indiciesPerVertex = iPut.offset;
			indiciesPerVertex++;

			float[] data = new float[indicies.length * c / indiciesPerVertex];
			
			for (int i=0; i<indices.length; i+=indicesPerVertex)
			{	int index = indices[i + input.offset]*c; // This creates duplicate vertices on shared triangle edges; Geometry.optimize takes care of it later
				int j = i/indicesPerVertex*c;
				data[j..j+c] = input.data[index..index+c];
			}

			Mesh m = new Mesh;
			m.SetTriangles(iPut.data);
			meshes ~= m;
		}
		
		if (id[0]=='#' && id.length>1) // id's are sometimes prefixed with #
			id = id[1..$];
		pXML.onStartTag["geometry"] = (ElementParser pXML)
		{
			if(pXML.tag.attr["id"] == id)
			{
				pXML.onStartTag["mesh"] = &getMesh;
				pXML.parse();
			}
		};
		pXML.parse();
	}
	float[] getDataFromSource(string sourceID, out ushort components)
	{
		auto pXML = new DocumentParser(originalXML);
		pXML.onStartTag["source"] = (ElementParser pXML)
		{
			if(pXML.tag.attr["id"] = sourceID)
			{
				string floatArrayS;
				pXML.onEndTag["float_array"] = (in Element e) {floatArrayS = e.text();};
				return parseNumberList!(float)(floatArrayS);
			}
		};
		pXML.parse();
	}
	T[] parseNumberList(T)(string list)
	{
		string[] pieces = split(list);
		T[] result = new T[pieces.length];
		int i = 0;

		foreach(piece; pieces)
		{
			if(piece.length)
			{
				result[i] = to!(T)(piece);
				i++;
			}
		}
		return result[0..i];
	}

}
*/