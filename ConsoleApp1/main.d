import dlangui;

import derelict.sdl2.sdl;
import derelict.opengl3.gl3;
import Glib.System.System;
import Glib.Scene;
import gl3n.linalg;

pragma(lib, "DerelictSDL2.lib");
pragma(lib, "DerelictFI.lib");
//pragma(lib, "DerelictALURE.lib");
pragma(lib, "DerelictUtil.lib");
pragma(lib, "DerelictASSIMP3.lib");
pragma(lib, "DerelictGL3.lib");

mixin APP_ENTRY_POINT;
	Render renderer;
	Scene s;
/// entry point for dlangui based application
extern (C) int UIAppMain(string[] args) {

	//DerelictSDL2.load("..//..//Libs//SDL2.dll");
	System.init();
	Window window = Platform.instance.createWindow("DlangUI example - HelloWorld", null, WindowFlag.Resizable, 720, 480);

	s = new Scene();

	PrimitiveObject sphere = new PrimitiveObject(PrimitiveObject.PrimitiveTypes.Sphere);
	RMObject gSphere = new RMObject();
	gSphere.AttachComponent(sphere);
	gSphere.transform.local_Position(vec3(2, 0, 0));
	gSphere.transform.local_Scale(vec3(.5f, .5f, .5f));
	//renderer.initialize(720,480);
    // create window
   
	auto vlayout = new VerticalLayout();
	vlayout.addChild(new TextWidget(null, "First text item"d));
	vlayout.addChild(new Test()).text("blah"d).margins(Rect(20,20,20,20));
	vlayout.addChild(new Button()).text("test"d).margins(Rect(20,20,20,20));
    // create some widget to show in window
    //window.mainWidget = (new Button()).text("Hello, world!"d).margins(Rect(20,20,20,20));
	window.mainWidget = vlayout;
    // show window
    window.show();
	
    // run message loop
    return Platform.instance.enterMessageLoop();
}

class Test:Widget
{
    protected UIString _text;
    override @property dstring text() { return _text; }
    override @property Widget text(dstring s) { _text = s; requestLayout(); return this; }
    override @property Widget text(UIString s) { _text = s; requestLayout(); return this; }
    @property Widget textResource(string s) { _text = s; requestLayout(); return this; }
    /// empty parameter list constructor - for usage by factory
    this() {
		super(null);
        init(UIString());
    }

    private void init(UIString label) {
        styleId = STYLE_BUTTON;
        _text = label;
		clickable = true;
        focusable = true;
        trackHover = true;
    }

    /// create with ID parameter
    this(string ID) {
		super(ID);
        init(UIString());
    }
    this(string ID, UIString label) {
		super(ID);
        init(label);
    }
    this(string ID, dstring label) {
		super(ID);
        init(UIString(label));
    }
    this(string ID, string labelResourceId) {
		super(ID);
        init(UIString(labelResourceId));
    }
    /// constructor from action
    this(const Action a) {
        this("button-action" ~ to!string(a.id), a.labelValue);
        action = a;
    }

    override void measure(int parentWidth, int parentHeight) { 
        FontRef font = font();
        Point sz = font.textSize(text);
        measuredContent(parentWidth, parentHeight, sz.x, sz.y);
    }

	override void onDraw(DrawBuf buf) {
        super.onDraw(buf);
        Rect rc = _pos;
        applyMargins(rc);
		int test = backgroundColor;
        buf.fillRect(_pos, 0xFF0000);
        applyPadding(rc);
		auto saver = ClipRectSaver(buf, rc, alpha);
		FontRef font = font();
        Point sz = font.textSize(text);
        applyAlign(rc, sz);
        font.drawText(buf, rc.left, rc.top, text, textColor, 4, 0, textFlags);
    }
}