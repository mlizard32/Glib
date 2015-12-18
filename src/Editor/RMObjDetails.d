module Editor.RMObjDetails;

private import gtk.Label;
private import gtk.ScrolledWindow;
private import gtk.Table;
private import gtk.Entry;
private import gtk.EditableIF;
private import gtk.VBox;
private import gtk.Expander;

import Glib.Scene.RMObject;

import std.traits;
import std.stdio;
import std.typecons;
import std.string;
import core.memory;
import gl3n.linalg;

class Detail : ScrolledWindow
{
	Entry[string] inputBoxes;

	DetailEntry[] activeEntries;

	class DetailEntry
	{
		string name;
		Entry entry;
		void delegate(string) propertySet;
		string delegate() propertyGet;

		IComponent component;

		this()
		{

		}

		void propCallBack(EditableIF a)
		{
			propertySet(a.getChars(0, -1));
		}
	}

	this()
	{
		super(null,null);

		
	}

	void watcher(string value, string memberName)
	{
		inputBoxes[memberName].setText(value);
	}

	public void Load(RMObject obj)
	{
		removeAll();
		
		Label label = new Label("Details");
		label.setAlignment(0, 0);
		label.setPadding(10, 10);
		
		VBox vbox = new VBox(false, 0);
		vbox.packStart(label, false, false, 0);
		vbox.add(CreateDetailTableForObj(obj));


		foreach(comp; obj.components)
		{

			int row = 1;

			Table compTable = new Table(row,6,false);
			compTable.setColSpacings(1);
			compTable.setHalign(GtkAlign.START);
			compTable.setValign(GtkAlign.START);
			compTable.setHomogeneous(false);
			compTable.setMarginTop(10);
			compTable.setMarginLeft(10);
			comp.connect(&watcher);
			auto memberlist = comp.getEditorField();
			foreach(member; memberlist)
			{
				string fieldName = member[0];
				void* setter = member[1];
				void* getter = member[2];
				IComponent.dataType type = member[3];

				switch (type)
				{
					case EditorHelper.dataType.E_string:
						//auto propertySet = *cast(void delegate(string)*)setter;
						//auto propertyGet = *cast(string delegate()*)getter;
						void delegate(string) propertySet;
						string delegate() propertyGet;
						propertySet.funcptr = cast(void function(string))setter;
						propertySet.ptr = cast(void*)comp;
						propertyGet.funcptr =  cast(string function())getter;
						propertyGet.ptr = cast(void*)comp;
						Label newLabel = new Label(fieldName.capitalize ~ ": ");
						string teststring = propertyGet();
						Entry newEntry = new Entry();
					
						void propCallBack(EditableIF a)
						{
							propertySet(a.getChars(0, -1));

							writeln((cast(Transform_Test)comp).omgLawl);
						}
						DetailEntry detEntry = new DetailEntry();
						detEntry.name = fieldName;
						detEntry.entry = newEntry;
						detEntry.component = comp;
						detEntry.propertyGet.funcptr = propertyGet.funcptr;
						detEntry.propertyGet.ptr = cast(void*)detEntry.component;
						detEntry.propertySet.funcptr = propertySet.funcptr;
						detEntry.propertySet.ptr = cast(void*)detEntry.component;
						activeEntries ~= detEntry;
						detEntry.entry.addOnChanged(&detEntry.propCallBack);
						
						compTable.resize(row++, 2);
						compTable.attach(detEntry.entry,3,6, row -1, row, AttachOptions.EXPAND,AttachOptions.EXPAND,0,0);
						compTable.attach(newLabel,0,3, row -1, row,AttachOptions.SHRINK,AttachOptions.SHRINK,4,4);

						auto componentType = typeid(comp);
						inputBoxes[componentType.classinfo.name ~ "." ~ fieldName] = detEntry.entry;

						break;
					case EditorHelper.dataType.E_vec3:
						void delegate(vec3) propertySet;
						vec3 delegate() propertyGet;
						propertySet.funcptr = cast(void function(vec3))setter;
						propertySet.ptr = cast(void*)comp;
						propertyGet.funcptr =  cast(vec3 function())getter;
						propertyGet.ptr = cast(void*)comp;
						
						vec3 currentVec = propertyGet();
						
						Label xLabel = new Label(fieldName.capitalize ~ "- x:");
						Label yLabel = new Label(" y:");
						Label zLabel = new Label(" z:");

						Entry xEntry = new Entry(to!string(currentVec.x));
						Entry yEntry = new Entry(to!string(currentVec.y));
						Entry zEntry = new Entry(to!string(currentVec.z));

						void X_vecPropCallBack(EditableIF a)
						{
							string blah = a.getChars(0, -1);
							if(std.string.isNumeric(blah))
							{
								vec3 newVec = vec3(to!float(blah), propertyGet().y, propertyGet().z);
								propertySet(newVec);
								writeln((cast(Transform_Test)comp).testVector.toString());
							}
						}
						void Y_vecPropCallBack(EditableIF a)
						{
							string blah = a.getChars(0, -1);
							if(std.string.isNumeric(blah))
							{
								vec3 newVec = vec3(propertyGet().x, to!float(blah), propertyGet().z);
								propertySet(newVec);
								writeln((cast(Transform_Test)comp).testVector.toString());
							}
						}
						void Z_vecPropCallBack(EditableIF a)
						{
							string blah = a.getChars(0, -1);
							if(std.string.isNumeric(blah))
							{
								vec3 newVec = vec3(propertyGet().x, propertyGet().y, to!float(blah));
								propertySet(newVec);
								writeln((cast(Transform_Test)comp).testVector.toString());
							}
						}
						xEntry.addOnChanged(&X_vecPropCallBack);
						yEntry.addOnChanged(&Y_vecPropCallBack);
						zEntry.addOnChanged(&Z_vecPropCallBack);


						compTable.resize(row++, 2);
						
						compTable.attach(xLabel,0,1, row -1, row,AttachOptions.SHRINK,AttachOptions.SHRINK,4,4);
						compTable.attach(xEntry,1,2, row -1, row, AttachOptions.SHRINK,AttachOptions.SHRINK,0,0);
						compTable.attach(yLabel,2,3, row -1, row,AttachOptions.SHRINK,AttachOptions.SHRINK,4,4);
						compTable.attach(yEntry,3,4, row -1, row, AttachOptions.SHRINK,AttachOptions.SHRINK,0,0);
						compTable.attach(zLabel,4,5, row -1, row,AttachOptions.SHRINK,AttachOptions.SHRINK,4,4);
						compTable.attach(zEntry,5,6, row -1, row, AttachOptions.SHRINK,AttachOptions.SHRINK,0,0);

						auto componentType = typeid(comp);
						//inputBoxes[componentType.classinfo.name ~ "." ~ fieldName] = newEntry;
						break;
					default:
						break;

				}
			}


			auto componentType = typeid(comp);
			string compTemp = componentType.classinfo.name;

			string componentLabel = compTemp[lastIndexOf(compTemp, '.') + 1.. $];
			Expander expandTest = new Expander(componentLabel);
			expandTest.add(compTable);
			vbox.add(expandTest);
		}
		addWithViewport(vbox);
		showAll();
	}

	mixin EditableFields!(RMObject);
}

/*
class DetailTable : Table
{
	Entry nameEntry;
	RMObject _rmObject;
	this(RMObject obj)
	{
		super(3,2,false);
		_rmObject = obj;
		
		//nameEntry = createEditorFields("blah", _rmObject, this);//new Entry(obj.name);
		attach(new Label("Name:"),0,1,0,1,AttachOptions.SHRINK,AttachOptions.SHRINK,4,4);
		maybeReturn(_rmObject);
		//attach(nameEntry,1,2,0,1,AttachOptions.EXPAND,AttachOptions.EXPAND,0,0);

		void nameChangedCallBack(EditableIF entry)
		{
			_rmObject.name = entry.getChars(0, -1);

		}
		//nameEntry.addOnChanged(&nameChangedCallBack);
	}

	

	
}
*/





template EditableFields(T)
{
	void write()
	{
		foreach(I, TYPE; typeof(T.tupleof))
		{
			writeln(__traits(identifier, T.tupleof[I]));
			foreach(attr; __traits(getAttributes, T.tupleof[I]))
				// identify them by type rather than value
				static if ( attr == "editorField") {
					writeln(__traits(identifier, T.tupleof[I]));
				}

		}
	}

	void fillTable(T obj, Table table, int row)
	{
		foreach(I, TYPE; typeof(T.tupleof))
		{
			foreach(attr; __traits(getAttributes, T.tupleof[I]))
			{
				// identify them by type rather than value
				static if ( attr == "editorField") 
				{
					mixin("void " ~ T.stringof ~ "_" ~ __traits(identifier, T.tupleof[I]) ~ "_OnChangedCallBack(EditableIF entry) { obj." ~ __traits(identifier, T.tupleof[I]) ~ " = entry.getChars(0,-1); }");
					static if(!is(typeof(__traits(getMember, T, __traits(identifier, T.tupleof[I]))) == vec3))
					{
						table.attach(new Label((__traits(identifier, T.tupleof[I])~": ").capitalize),0,1, row, row + 1,AttachOptions.SHRINK,AttachOptions.SHRINK,4,4);
						Entry newEntry = null;
						newEntry = new Entry(__traits(getMember, obj, __traits(identifier, T.tupleof[I])));
						newEntry.addOnChanged(mixin("&" ~ T.stringof ~ "_" ~ __traits(identifier, T.tupleof[I]) ~ "_OnChangedCallBack"));
						table.attach(newEntry,1,2, row, row + 1, AttachOptions.EXPAND,AttachOptions.EXPAND,0,0);
					}
					row++;
				}
			}
		}
	}

	Table CreateDetailTableForObj(T obj)
	{
		Table returnTable = new Table(2,1,false);
		returnTable.setColSpacings(1);
		returnTable.setHalign(GtkAlign.START);
		returnTable.setValign(GtkAlign.START);
		returnTable.setHomogeneous(false);
		returnTable.setMarginTop(10);
		returnTable.setMarginLeft(10);
		fillTable(obj, returnTable, 0);
		return returnTable;
	}

	
}
