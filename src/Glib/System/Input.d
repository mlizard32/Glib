module Glib.System.Input;

import derelict.sdl2.sdl;
import gl3n.linalg;
import Glib.System.Window;
import Glib.System.System;
import std.traits;
import std.algorithm;
import std.uuid;
import std.typecons;
import Glib.System.Log;

alias buttonEvent = void delegate(Button);
alias axisEvent = void delegate(Axis);

mixin template KeyList(T, string name, KeyCode)
{
	mixin(T.stringof ~ "[" ~ to!string(EnumMembers!(KeyCode).length) ~"] " ~name~ "=" ~ KeyListFiller!(T,KeyCode).FillKeyListMixinHelper());

}

template KeyListFiller(T, KeyCode)
{
	string FillKeyListMixinHelper()
	{
		string keyList = "[ ";
		foreach(k; __traits(allMembers, KeyCode))
		{ 
			keyList ~= T.stringof ~ "(" ~KeyCode.stringof~"." ~ k ~ "),";
		}

		keyList.length = keyList.length-1;
		keyList ~= "];";
		return keyList;
	}
}

struct Peripheral(T, InputEnum) if(__traits(compiles, T(10)))
{ 
	//creates Key array, example
	//Button[100] keys = [Button(Keyboard.Escape), ...];
	mixin KeyList!(T, "keys", InputEnum);
	
	ref T opIndex( uint keyCode ) 
    {
		return keys[countUntil(keys[0..$], keyCode)];
    }

	/*
	ref T opIndexAssign( T newVal, uint keyCode )
	{
		keys[ keyCode ] = newVal;

        return newVal;
	}
	*/
	
}

abstract class Input
{
	static:
	
	auto keyboard = Peripheral!(Button, KeyBoardKeyCodes)();
	auto mouseBtns = Peripheral!(Button, MouseButtonCodes)();
	auto mouseAxis = Peripheral!(Axis, MouseAxisCodes)();

	void pollInput()
	{
		SDL_Event event;
		while(SDL_PollEvent(&event))
		{
			switch (event.type)
			{
				case SDL_WINDOWEVENT:
					foreach(window w; System.windows)
					{
						w.UpdateWindow(event);
					}
					break;
				case SDL_KEYDOWN:
					keyboard[event.key.keysym.sym].setState(true);
					break;
				case SDL_KEYUP:
					keyboard[event.key.keysym.sym].setState(false);
					break;
				case SDL_MOUSEMOTION:
					mouseAxis[MouseAxisCodes.X].setState(event.motion.x);
					mouseAxis[MouseAxisCodes.Y].setState(event.motion.y);
					//this.mouse.Position.x = event.motion.x;
					//this.mouse.Position.y = event.motion.y;
					break;
				case SDL_MOUSEBUTTONDOWN:
					mouseBtns[event.button.button].setState(true);
					//this.mouse.leftButton = true;
					break;
				case SDL_MOUSEBUTTONUP:
					mouseBtns[event.button.button].setState(false);
					//this.mouse.leftButton = false;
					break;
				case SDL_MOUSEWHEEL:
					mouseAxis[MouseAxisCodes.Scroll].setState(event.wheel.y);
					//this.mouse.scroll += event.wheel.y;
					break;
				case SDL_QUIT:
					System.active = false;
					break;
				default:
					//unhandled event
					break;
			}

			SDL_Delay(1);
		}
	}
	public bool GetKeyDown(uint key)
	{
		return keyboard[key].getState;
	}

	public void addButtonEvent(uint key, buttonEvent event, EventType type)
	{
		auto id = randomUUID();
		keyboard[key].buttonEvents ~= tuple(id, event, type);
	}

	public vec2 GetMousePos()
	{
		return vec2(mouseAxis[MouseAxisCodes.X].getState, mouseAxis[MouseAxisCodes.Y].getState);
	}
}

struct Axis
{
	uint key;
	float _state = 0;
	float _prevState = 0;

	alias registeredEvent = Tuple!(UUID, axisEvent);
	registeredEvent[] axisEvents;

	this(uint inkey)
	{
		this.key = inkey;
	}

	// for l-values and r-values,
    // with converting both hand side implicitly to const
    bool opEquals()(auto ref const uint k) const 
	{
		if(k == key)
			return true;
		else
			return false;
	}

	float getState()
	{
		return _state;
	}

	void setState(float newState)
	{

		Log.info(to!string(cast(MouseAxisCodes)key) ~ " State: " ~ to!string(newState));
		_state = newState;

		//call events
		foreach(registeredEvent e; axisEvents)
		{
			e[1](this);
		}
	}
}

struct Button
{
	alias State = bool;
	uint key;
	private State _state = false;
	private State _prevState = false;

	alias registeredEvent = Tuple!(UUID, buttonEvent, EventType);
	registeredEvent[] buttonEvents;

	@disable this();

	this(uint inkey)
	{
		this.key = inkey;
	}

	// for l-values and r-values,
    // with converting both hand side implicitly to const
    bool opEquals()(auto ref const uint k) const 
	{
		if(k == key)
			return true;
		else
			return false;
	}

	State getState()
	{
		return _state;
	}
	
	void setState(State newState)
	{
		Log.info(to!string(cast(KeyBoardKeyCodes)key) ~ " State: " ~ to!string(newState));
		
		if(_state != newState)
		{
			if(_state)
			{
				foreach(registeredEvent e; buttonEvents)
				{
					if(e[2] == EventType.OnButtonDown)
						e[1](this);
				}
			}
			else
			{
				foreach(registeredEvent e; buttonEvents)
				{
					if(e[2] == EventType.OnButtonUp)
						e[1](this);
				}
			}
		}

		if(_state)
		{
			foreach(registeredEvent e; buttonEvents)
			{
				if(e[2] == EventType.ButtonDown)
					e[1](this);
			}
		}
		else
		{
			foreach(registeredEvent e; buttonEvents)
			{
				if(e[2] == EventType.ButtonUp)
					e[1](this);
			}
		}
		_prevState = _state;
		_state = newState;
	}
	
}
enum EventType
{
	OnButtonDown,
	ButtonDown,
	OnButtonUp,
	ButtonUp
}

enum MouseAxisCodes: uint
{
	X = 0,
	Y = 1,
	Scroll = 2
}
enum MouseButtonCodes: uint
{
	Left = SDL_BUTTON_LEFT,
    Middle = SDL_BUTTON_MIDDLE,
    Right = SDL_BUTTON_RIGHT,
    SecondaryOne = SDL_BUTTON_X1,
    SecondaryTwo = SDL_BUTTON_X2,
}
enum KeyBoardKeyCodes: uint
{
	Cancel      = SDLK_CANCEL, 
	Backspace   = SDLK_BACKSPACE, /// Backspace key
	Tab         = SDLK_TAB, /// Tab key
	Clear       = SDLK_CLEAR, /// Clear key
	Return      = SDLK_RETURN, /// Enter key
	Pause       = SDLK_PAUSE, /// Pause key
	CapsLock    = SDLK_CAPSLOCK,
	Escape      = SDLK_ESCAPE,
	Space       = SDLK_SPACE, /// Space bar
	PageUp      = SDLK_PAGEUP, /// Page Up/Prior key
	PageDown    = SDLK_PAGEDOWN, /// Page Down/Next key
	End         = SDLK_END, /// End key
	Home        = SDLK_HOME, /// Home key
	Left        = SDLK_LEFT, /// Left arrow key
	Up          = SDLK_UP, /// Up arrow key
	Right       = SDLK_RIGHT, /// Right arrow key
	Down        = SDLK_DOWN, /// Down arrow key
	Select      = SDLK_SELECT, /// Select key
	Print       = SDLK_PRINTSCREEN, /// Print key
	PrintScreen = SDLK_PRINTSCREEN, /// Print Screen/Snapshot key
	Execute     = SDLK_EXECUTE, /// Execute key
	Insert      = SDLK_INSERT, /// Insert key
	Delete      = SDLK_DELETE, /// Delete key
	Help        = SDLK_HELP, /// Help key
	Keyboard0   = SDLK_0, /// 0 key
	Keyboard1   = SDLK_1, /// 1 key
	Keyboard2   = SDLK_2, /// 2 key
	Keyboard3   = SDLK_3, /// 3 key
	Keyboard4   = SDLK_4, /// 4 key
	Keyboard5   = SDLK_5, /// 5 key
	Keyboard6   = SDLK_6, /// 6 key
	Keyboard7   = SDLK_7, /// 7 key
	Keyboard8   = SDLK_8, /// 8 key
	Keyboard9   = SDLK_9, /// 9 key
	A           = SDLK_a, /// A key
	B           = SDLK_b, /// B key
	C           = SDLK_c, /// C key
	D           = SDLK_d, /// D key
	E           = SDLK_e, /// E key
	F           = SDLK_f, /// F key
	G           = SDLK_g, /// G key
	H           = SDLK_h, /// H key
	I           = SDLK_i, /// I key
	J           = SDLK_j, /// J key
	K           = SDLK_k, /// K key
	L           = SDLK_l, /// L key
	M           = SDLK_m, /// M key
	N           = SDLK_n, /// N key
	O           = SDLK_o, /// O key
	P           = SDLK_p, /// P key
	Q           = SDLK_q, /// Q key
	R           = SDLK_r, /// R key
	S           = SDLK_s, /// S key
	T           = SDLK_t, /// T key
	U           = SDLK_u, /// U key
	V           = SDLK_v, /// V key
	W           = SDLK_w, /// W key
	X           = SDLK_x, /// X key
	Y           = SDLK_y, /// Y key
	Z           = SDLK_z, /// Z key
	GuiLeft     = SDLK_LGUI, /// Left GUI key
	GuiRight    = SDLK_RGUI, /// Right GUI key
	Apps        = SDLK_APPLICATION, /// Applications key
	Sleep       = SDLK_SLEEP, /// Sleep key
	Numpad0     = SDLK_KP_0, /// 0 key
	Numpad1     = SDLK_KP_1, /// 1 key
	Numpad2     = SDLK_KP_2, /// 2 key
	Numpad3     = SDLK_KP_3, /// 3 key
	Numpad4     = SDLK_KP_4, /// 4 key
	Numpad5     = SDLK_KP_5, /// 5 key
	Numpad6     = SDLK_KP_6, /// 6 key
	Numpad7     = SDLK_KP_7, /// 7 key
	Numpad8     = SDLK_KP_8, /// 8 key
	Numpad9     = SDLK_KP_9, /// 9 key
	F1          = SDLK_F1, /// Function 1 key
	F2          = SDLK_F2, /// Function 2 key
	F3          = SDLK_F3, /// Function 3 key
	F4          = SDLK_F4, /// Function 4 key
	F5          = SDLK_F5, /// Function 5 key
	F6          = SDLK_F6, /// Function 6 key
	F7          = SDLK_F7, /// Function 7 key
	F8          = SDLK_F8, /// Function 8 key
	F9          = SDLK_F9, /// Function 9 key
	F10         = SDLK_F10, /// Function 10 key
	F11         = SDLK_F11, /// Function 11 key
	F12         = SDLK_F12, /// Function 12 key
	F13         = SDLK_F13, /// Function 13 key
	F14         = SDLK_F14, /// Function 14 key
	F15         = SDLK_F15, /// Function 15 key
	F16         = SDLK_F16, /// Function 16 key
	F17         = SDLK_F17, /// Function 17 key
	F18         = SDLK_F18, /// Function 18 key
	F19         = SDLK_F19, /// Function 19 key
	F20         = SDLK_F20, /// Function 20 key
	F21         = SDLK_F21, /// Function 21 key
	F22         = SDLK_F22, /// Function 22 key
	F23         = SDLK_F23, /// Function 23 key
	F24         = SDLK_F24, /// Function 24 key
	NumLock     = SDLK_NUMLOCKCLEAR, /// Num Lock key
	ScrollLock  = SDLK_SCROLLLOCK, /// Scroll Lock key
	ShiftLeft   = SDLK_LSHIFT, /// Left shift key
	ShiftRight  = SDLK_LSHIFT, /// Right shift key
	ControlLeft = SDLK_LCTRL, /// Left control key
	ControlRight= SDLK_RCTRL, /// Right control key
	AltLeft     = SDLK_LALT, /// Left Alt key
	AltRight    = SDLK_RALT, /// Right Alt key
}