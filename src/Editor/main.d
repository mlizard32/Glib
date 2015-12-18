module Editor.main;

import std.stdio;
import Glib.System;
import Glib.Scene;
import derelict.opengl3.gl3;

import derelict.sdl2.image;
import derelict.sdl2.sdl;
//import imgui_sdl;
import derelict.imgui.imgui;
import gl3n.linalg;

import Editor.SceneGraph;
import Editor.RMObjDetails;

import gtk.MainWindow;
import gtk.Label;
import gtk.Main;
import gtk.GLArea;
import gdk.GLContext;
import gtk.Widget;
import glib.ErrorG;
import gtk.MenuBar;
import gtk.Menu;
import gtk.MenuItem;
import gtk.VBox;
import gtk.HBox;
import gtk.Paned;
import gtk.TreeView;
import gtk.TreeIter;
import gtk.TreePath;

import derelict.opengl3.wgl;

public  import gtkc.gdktypes;
private import gtkc.gtk;
public  import gtkc.gtktypes;

Render renderer;
Scene s;

int sW = 720;
int sH = 480;

class MyArea : GLArea {
	bool render (GLContext c, GLArea a)
	{
		makeCurrent();
		renderer.rScene(s, a);
		assert(getHasDepthBuffer());
		return true;
	}  

	void init(Widget w)
	{
		GLArea a = cast(GLArea)w;
		makeCurrent();
		if (gtk_gl_area_get_error (a.getGLAreaStruct()) !is null)
			 return;

		assert(wglGetCurrentContext() !is null);	

		DerelictGL3.reload();

		setHasDepthBuffer(true);

		renderer.initialize(sW, sH);

		//Model model = new Model("..\\..\\resources\\suzanne.obj");
	//	PrimitiveObject sphere = new PrimitiveObject(PrimitiveObject.PrimitiveTypes.Sphere);

	//	RMObject RMsphere = new RMObject();
		
	//	RMsphere.AttachComponent(sphere);

		

	}
}

class ExampleWindow : MainWindow
{      
	SceneGraphView sgv;
	Detail objDetails;
	this()
	{
		super("GtkD: Try");

		
		MenuBar menuBar = new MenuBar();
		Menu menu = menuBar.append("_File");
		MenuItem item = new MenuItem(&onMenuActivate, "_New","file.new", true, null, 'n');
		menu.append(item);
		MyArea glarea = new MyArea();
		glarea.addOnRender(&glarea.render);
		glarea.addOnRealize(&glarea.init);
		
		VBox mainBox = new VBox(false, 0);
		mainBox.packStart(menuBar, false , false, 0);
		//mainBox.packStart(glarea, true , true, 0);

		//HBox testBox = new HBox(false, 0);
		//testBox.packStart(glarea, true, true, 0);
		sgv = new SceneGraphView();
		sgv.treeView.addOnCursorChanged(&onSceneSelectionChanged);
		//testBox.packStart(sgv, true, true, 0);
		

		Paned testPane = new Paned(GtkOrientation.HORIZONTAL);
		testPane.pack1(glarea, true, true);
		Paned sceneGraphPane = new Paned(GtkOrientation.VERTICAL);
		sceneGraphPane.pack1(sgv, true, true);
		objDetails = new Detail();
		sceneGraphPane.add2(objDetails);
		testPane.add2(sceneGraphPane);

		mainBox.packStart(testPane, true, true, 0);
		//add(menuBar);
		//add(glarea);
		add(mainBox);
	
		
	}

	void onMenuActivate(MenuItem menuItem)
	{
	}

	void onSceneSelectionChanged(TreeView treeView)
	{
		TreeIter iter = treeView.getSelectedIter;
		if(iter is null)
			return;
		SceneGraphTreeModel model = cast(SceneGraphTreeModel)treeView.getModel;
		TreePath path = model.getPath(iter);
		RMObject obj = model.getObjectFromPath(path);
		objDetails.Load(obj);
	}
}


import std.array;
import std.stdio;

static MainWindow win;

int main(string[] argv)
{
	System.init();
	s = new Scene();
	

	Main.init(argv);

	//MainWindow win = new MainWindow("Hello World");
  //  win.setDefaultSize(200, 100);
  //  win.add(new Label("Hello World"));
  //  win.showAll();
	//MyArea test = new MyArea();
	win = new ExampleWindow();   
	
	win.setSizeRequest(720, 480);

	s.root.connect(&getSceneGraphModel.watch);
	
	RMObject test = new RMObject();
	test.name = "test1";

	test = new RMObject();
	test.name = "test2";

	test = new RMObject();
	test.name = "test3";

	RMObject testchild = new RMObject(test);
	testchild.name = "testchild";

	win.showAll();
	Main.run();

	
	//renderer.initialize(720,480);

	//window w = new window();
	//w.SetResolution(sW, sH);
	//string fontPath = "..\\..\\resources\\DroidSans.ttf";

	//igImplSDL2GL3_Init(w.sdlWindow, true);


/*

	//imguiInit(fontPath);
	Scene s = new Scene();

	Log.info("test");
	//"..\\..\\resources\\suzanne.obj"
	//Model model = new Model("..\\..\\resources\\suzanne.obj");
	PrimitiveObject sphere = new PrimitiveObject(PrimitiveObject.PrimitiveTypes.Sphere);

	//RMObject monkey = new RMObject();
	//monkey.components ~= model;
	//monkey.AttachComponent(model);


	RMObject gSphere = new RMObject();
	gSphere.AttachComponent(sphere);
	gSphere.transform.local_Position(vec3(2, 0, 0));
	gSphere.transform.local_Scale(vec3(.5f, .5f, .5f));

	//monkey.addChild(gSphere);

	Render renderer;

	const( char )* verstr = glGetString( GL_VERSION );
	char major = *verstr;
	char minor = *( verstr + 2 );

	renderer.initialize(w.size.x, w.size.y);

	Input.addButtonEvent(cast(uint)KeyBoardKeyCodes.A, (b){Log.info(to!string(b.key));}, EventType.ButtonDown);
float[3] clear_color = [0.3f, 0.4f, 0.8f];
	GLenum error = glGetError();
	if(error != GL_NO_ERROR)
		System.active = false;
	while(System.active)
	{
		Input.pollInput();
		//monkey.transform.local_Rotation(monkey.transform.local_Rotation_quat.rotatey(.05f));

			renderer.rScene(s, w);

		igImplSDLGL3_NewFrame();

		igBeginMainMenuBar();
		//igBeginMenu("test");
		//igMenuItem("blahblah", "z");
		//igEndMenu();
		igEndMainMenuBar();
		bool blah = false;
		igBegin("test", &blah, ImGuiWindowFlags_ShowBorders);
		igText("Hello World");
		igEnd();
		//igShowUserGuide();

		//igShowStyleEditor(igGetStyle());

		//glViewport(0, 0, cast(int)w.size.x, cast(int)w.size.y);
       //  glClearColor(clear_color[0], clear_color[1], clear_color[2], 0);
		//glClear(GL_COLOR_BUFFER_BIT);

		igRender();
		w.SwapWindow();

		error = glGetError();
		if(error != GL_NO_ERROR)
			System.active = false;
	}

	igImplSDLGL3_Shutdown();

	*/
	System.deInit();
	//	imguiDestroy();
    writeln("Hello D-World!");
    return 0;
}

static SceneGraphTreeModel getSceneGraphModel()
{
	if(win!is null)
	{
		ExampleWindow exWin = cast(ExampleWindow) win;
	
		return cast(SceneGraphTreeModel)exWin.sgv.treeView.getModel();
	}
	else return null;
}