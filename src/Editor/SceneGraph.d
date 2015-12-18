module Editor.SceneGraph;

private import gtk.ScrolledWindow;
private import gtk.TreeView;
private import gtk.TreePath;
private import gtk.TreeViewColumn;
private import gtk.TreeIter;
private import gtk.TreeStore;
//private import gtk.TreeModel;
private import Editor.TreeModelDragable;
private import gtk.TreeDragDestIF;
private import gtk.TreeDragDestT;
private import gtk.TreeDragSourceIF;
private import gtk.TreeDragSourceT;
private import gtk.SelectionData;
private import gtk.TreeModelIF;
import gtk.ListStore;
private import gtk.TreeSelection;
private import gtk.CellRendererText;
private import gtk.Image;
private import gtk.TreeNode;
private import gdk.Event;
private import gtk.Menu;
private import gtk.MenuItem;

import glib.Timeout;
import cairo.Context;
import cairo.Surface;
import gtk.Widget;
private import gobject.ObjectG;
private import gobject.Value;
import glib.RandG;

import std.stdio;
import std.algorithm;
import std.conv;
import std.uuid;
import std.signals;

import Glib.Scene.RMObject;
import Glib.System.System;
import Glib.Scene.Node;


class SceneGraphView : ScrolledWindow
{
	RMObject testObject;
	RMObject testObjectTwo;
	Timeout m_timeout;
	public TreeView treeView;
	Menu menuPopup;

	this()
	{
		super(null,null);

		treeView = setup();
		addWithViewport(treeView);

		treeView.addOnRowActivated(&rowActivatedCallback);
		treeView.addOnMoveCursor(&moveCursorCallBack);
		treeView.addOnButtonPress(&buttonPressCallBack);
		treeView.addOnCursorChanged(&curserTest);
		treeView.setReorderable(true);
		//treeView.addOnDraw(&drawCallBack);
		
		if ( m_timeout is null )
		{
			//Create a new timeout that will ask the window to be drawn once every second.
			m_timeout = new Timeout( 10000, &onSecondElapsed, false );
		}

		treeView.setShowExpanders(true);

		menuPopup = new Menu();
		
		MenuItem menuItem = new MenuItem(&popupItemRemove, "_Remove","remove", true, null, 'n');
		menuPopup.append(menuItem);
		menuPopup.attachToWidget(treeView, null);
		menuPopup.showAll();
	}

	void curserTest(TreeView treeView)
	{
		writeln("selected something");
		

		
	}
	void popupItemRemove(MenuItem menuItem)
	{
		TreeIter iter = treeView.getSelectedIter;
		SceneGraphTreeModel model = cast(SceneGraphTreeModel)treeView.getModel;
		TreePath path = model.getPath(iter);
		RMObject obj = model.getObjectFromPath(path);
		obj.getParent.removeChild(obj);
	}
	bool buttonPressCallBack(Event buttonEvent, Widget widget)
	{
		bool returnvalue = false;
		returnvalue = widget.onButtonPressEvent(cast(GdkEventButton*)buttonEvent.getEventStruct);
		uint button = 0;
		buttonEvent.getButton(button);
		if(button == 3)
		{
			writeln("create context");
			menuPopup.popup(button, buttonEvent.getTime());
		}
		return returnvalue;
	}
	void rowActivatedCallback(TreePath path, TreeViewColumn column, TreeView treeView)
	{
		writeln("rowActivateCallback for %X",treeView);
		writeln("rowActivateCallback for path %s",path.toString());
	}

	bool moveCursorCallBack(GtkMovementStep step, int direction, TreeView treeView)
	{
		writeln("moveCursorCallBack for %X",treeView);
		writeln("moveCursorCallBack row = %d",direction);
		return false;
	}

	bool drawCallBack(Scoped!Context cr, Widget widget)
	{

		return true;
	}

	bool onSecondElapsed()
	{
		if(testObject is null)
		{
			testObject = new RMObject();
			testObject.name = "testObject";
			testObjectTwo = new RMObject(testObject);
			testObjectTwo.name = "testObjectTwo";
		}
		else
		{
			if(testObjectTwo.getParent != testObject.getParent)
				System.currentScene.root.addChild(testObjectTwo);
			else
				testObject.addChild(testObjectTwo);
		}
		
	
		return true;

	}

	

	TreeView setup()
	{
		
		treeView = new TreeView();
		SceneGraphTreeModel testTreeModel = new SceneGraphTreeModel();


		TreeIter iter = null;
	
		/*
		foreach(Node gChild; System.currentScene.root.getChildren())
		{
			TraverseScene(cast(RMObject) gChild, testTreeModel);
			//TraverseScene(cast(RMObject)gChild, testTreeStore, iter);
		}
	*/
		treeView.setModel(testTreeModel);

		treeView.setRulesHint(true);
		TreeSelection ts = treeView.getSelection();
		ts.setMode(SelectionMode.MULTIPLE);

		TreeViewColumn column = new TreeViewColumn("Name",new CellRendererText(),"text", 1);
		treeView.appendColumn(column);
		
		return treeView;

	}
	/*
	void TraverseScene(RMObject g, CustomList testTreeModel)
	{
		RMObject parent = null;
		if(g.getParent != System.currentScene.root)
			parent = cast(RMObject)g.getParent;
		testTreeModel.appendObj(cast(RMObject) g, parent);

		//Draw Children
		foreach(Node gChild; g.getChildren())
		{
			TraverseScene(cast(RMObject)gChild, testTreeModel);
		}
	}
	*/
}




enum SceneGraphColumn
{
	RMObj = 0,
	Name,
	Type,
	NColumns,
}

class SceneGraphTreeModel : TreeModelDragable
{
	uint numRows;
	int nColumns;
	int stamp;
	GType[3] columnTypes;
	//RMObject[] rows;

	void watch(string msg, Node node)
	{
		RMObject obj = cast(RMObject)node;
		writeln("message: " ~ msg ~ "- for obj:" ~ obj.name);
		switch(msg)
		{
			case "addChild":
				appendObj(obj);
				break;
			case "addChildInPlace":
				appendObj(obj);
				break;
			case "beforeRemoveChild":
				removeObj(obj);
				break;
			case "afterRemoveChild":
				if(obj.getChildren.length == 0)
				{
					TreeIter iter;
					TreePath path;

					path = getPathFromObject(cast(RMObject)obj);
					iter = new TreeIter(this, path);
					getIter(iter, path);

					rowHasChildToggled(path, iter);
				}
				
				break;
			default: 
				break;
		}

	}


	/** the main Gtk struct as a void* */
	protected override void* getStruct()
	{
		return cast(void*)gtkTreeModel;
	}

	public this()
	{
		nColumns = columnTypes.length;
		columnTypes[0] = GType.POINTER; //RMObject
		columnTypes[1] = GType.STRING; //Name
		columnTypes[2] = GType.STRING; //Type

		stamp = RandG.randomInt();
	}


	/*
	* tells the rest of the world whether our tree model
	* has any special characteristics. In our case,
	* we have a list model (instead of a tree), and each
	* tree iter is valid as long as the row in question
	* exists, as it only contains a pointer to our struct.
	*/
	override GtkTreeModelFlags getFlags()
	{
		return (GtkTreeModelFlags.ITERS_PERSIST);
	}


	/*
	* tells the rest of the world how many data
	* columns we export via the tree model interface
	*/

	override int getNColumns()
	{
		return nColumns;
	}

	/*
	* tells the rest of the world which type of
	* data an exported model column contains
	*/
	override GType getColumnType(int index)
	{
		if ( index >= nColumns || index < 0 )
			return GType.INVALID;

		return columnTypes[index];
	}

	/*
	* converts a tree path (physical position) into a
	* tree iter structure (the content of the iter
	* fields will only be used internally by our model).
	* We simply store a pointer to our CustomRecord
	* structure that represents that row in the tree iter.
	*/
	override int getIter(TreeIter iter, TreePath path)
	{
		RMObject rmobj;
		int[]         indices;
		int           n, depth;

		indices = path.getIndices();
		depth   = path.getDepth();

		n = indices[0]; /* the n-th top level row */

		rmobj = getObjectFromPath(path);

		if ( rmobj is null )
			return false;
			//throw new Exception("Not Exsisting record requested");

		/* We simply store a pointer to our custom record in the iter */
		iter.stamp     = stamp;
		iter.userData  = cast(void*)rmobj;

		return true;
	}


	/*
	* converts a tree iter into a tree path (ie. the
	* physical position of that row in the list).
	*/
	override TreePath getPath(TreeIter iter)
	{
		TreePath path;
		RMObject rmObj;
		
		if ( iter is null || iter.userData is null || iter.stamp != stamp )
		{			
			return null;
		}

		rmObj = cast(RMObject) iter.userData;

		
		path = getPathFromObject(rmObj);

		return path;
	}


	/*
	* Returns a row's exported data columns
	* (_get_value is what gtk_tree_model_get uses)
	*/

	override Value getValue(TreeIter iter, int column, Value value = null)
	{
		RMObject rmObj;

		if ( value is null )
			value = new Value();
		assert(iter !is null);
		//if ( iter is null || column >= nColumns || iter.stamp != stamp )
		//	return null;

		value.init(columnTypes[column]);

		rmObj = cast(RMObject) iter.userData;

		if ( rmObj is null )
			return null;

		switch(column)
		{
			case SceneGraphColumn.RMObj:
				value.setPointer(cast(void*)rmObj);
				break;

			case SceneGraphColumn.Name:
				value.setString(rmObj.name);
				break;

			case SceneGraphColumn.Type:
				value.setString("type");
				break;

			default:
				
				break;
		}

		return value;
	}


	/*
	* Takes an iter structure and sets it to point
	* to the next row.
	*/
	override bool iterNext(TreeIter iter)
	{
		RMObject rmObj, nextObj;

		if ( iter is null || iter.userData is null || iter.stamp != stamp )
			return false;

		rmObj = cast(RMObject) iter.userData;
		auto row = rmObj.getParent.getChildren;
		for(int i = 0; i < row.length; i ++)
		{
			if(row[i] == rmObj)
			{
				if((i+1) < row.length)
				{
					nextObj = cast(RMObject)row[i+1];
					break;
				}
			}
		}
		/* Is this the last record in the list? */
		if ( nextObj is null)
				return false;

		iter.stamp     = stamp;
		iter.userData  = cast(void*)nextObj;

		return true;
	}

	/*
	* Takes an iter structure and sets it to point
	* to the next row.
	*/
	override bool iterPrevious(TreeIter iter)
	{
		RMObject rmObj, nextObj;

		if ( iter is null || iter.userData is null || iter.stamp != stamp )
			return false;

		rmObj = cast(RMObject) iter.userData;
		auto row = rmObj.getParent.getChildren;
		for(int i = 0; i < row.length; i ++)
		{
			if(row[i] == rmObj)
			{
				if((i-1) > 0)
				{
					nextObj = cast(RMObject)row[i+1];
					break;
				}
			}
		}
		/* Is this the last record in the list? */
		if ( nextObj is null)
			return false;

		iter.stamp     = stamp;
		iter.userData  = cast(void*)nextObj;

		return true;
	}


	/*
	* Returns TRUE or FALSE depending on whether
	* the row specified by 'parent' has any children.
	* If it has children, then 'iter' is set to
	* point to the first child. Special case: if
	* 'parent' is NULL, then the first top-level
	* row should be returned if it exists.
	*/

	override bool iterChildren(TreeIter iter, TreeIter parent)
	{
		RMObject rmObj;
		RMObject parentObj;
		/* this is a list, nodes have no children */
		if ( parent is null )
		{
			rmObj = cast(RMObject)System.currentScene.root.getChildren[0];
		}
		else
		{
			parentObj = cast(RMObject)parent.userData;

			auto children = parentObj.getChildren;
		
			if(children.length == 0)
				return false;
		
			rmObj = cast(RMObject) children[0];
		}
		/* Set iter to first item in list */
		//iter = new TreeIter();
		iter.stamp     = stamp;
		iter.userData  = cast(void*)rmObj;

		return true;
	}


	/*
	* Returns TRUE or FALSE depending on whether
	* the row specified by 'iter' has any children.
	* We only have a list and thus no children.
	*/
	override bool iterHasChild(TreeIter iter)
	{
		RMObject rmObj;
		rmObj = cast(RMObject)iter.userData;
		if(rmObj is null)
		{
			return false;
		}
		auto children = rmObj.getChildren;
		if(children.length == 0)
			return false;
		else 
			return true;
	}


	/*
	* Returns the number of children the row
	* specified by 'iter' has. This is usually 0,
	* as we only have a list and thus do not have
	* any children to any rows. A special case is
	* when 'iter' is NULL, in which case we need
	* to return the number of top-level nodes,
	* ie. the number of rows in our list.
	*/
	override int iterNChildren(TreeIter iter)
	{
		RMObject rmObj;
		
		if(iter is null)
		{
			return System.currentScene.root.getChildren.length;
		}
		rmObj = cast(RMObject)iter.userData;
		auto children = rmObj.getChildren;
		return children.length;
	}


	/*
	* If the row specified by 'parent' has any
	* children, set 'iter' to the n-th child and
	* return TRUE if it exists, otherwise FALSE.
	* A special case is when 'parent' is NULL, in
	* which case we need to set 'iter' to the n-th
	* row if it exists.
	*/
	override bool iterNthChild(TreeIter iter, TreeIter parent, int n)
	{
		RMObject rmObj;
		
		if ( parent is null )
		{
			rmObj = getObjectFromPath(new TreePath(n));

			//iter = new TreeIter();
			iter.stamp     = stamp;
			iter.userData  = cast(void*)rmObj;

			return true;
		}


		rmObj = cast(RMObject)parent.userData;

		auto children = rmObj.getChildren;

		if(children.length < n)
			return false;


		/* Set iter to first item in list */
		//iter = new TreeIter();
		iter.stamp     = stamp;
		iter.userData  = cast(void*)children[n];
		return true;
	}


	/*
	* Point 'iter' to the parent node of 'child'.
	*/
	override bool iterParent(TreeIter iter, TreeIter child)
	{
		RMObject rmObj;
		
		assert(child.userData !is null);
		rmObj = cast(RMObject)child.userData;
		if(rmObj is null)
			return false;
		auto parent = rmObj.getParent;
		if(parent == System.currentScene.root)
			return false;
		
		//iter = new TreeIter();
		iter.stamp     = stamp;
		iter.userData  = cast(void*)parent;

		return true;
	}

	/*
	* Empty lists are boring. This function can
	* be used in your own code to add rows to the
	* list. Note how we emit the "row-inserted"
	* signal after we have appended the row
	* internally, so the tree view and other
	* interested objects know about the new row.
	
	void appendRecord(string name, uint yearBorn)
	{
		TreeIter      iter;
		TreePath      path;
		CustomRecord* newrecord;
		uint          pos;

		if ( name is null )
			return;

		pos = numRows;
		numRows++;

		newrecord = new CustomRecord;

		newrecord.name = name;
		newrecord.yearBorn = yearBorn;

		rows ~= newrecord;
		newrecord.pos = pos;

		

		path = new TreePath(pos);

		iter = new TreeIter();
		getIter(iter, path);

		rowInserted(path, iter);
	}
*/

	void appendObj(RMObject obj)
	{
		TreeIter iter;
		TreePath path;

		path = getPathFromObject(obj);
		assert(path !is null);
		iter = new TreeIter();
		getIter(iter, path);

		rowInserted(path, iter);

		if(obj.getChildren.length != 0)
			rowHasChildToggled(path, iter);
		
		if(obj.getParent != System.currentScene.root)
		{
			path = getPathFromObject(cast(RMObject)obj.getParent);
			iter = new TreeIter(this, path);
			getIter(iter, path);
			
			rowHasChildToggled(path, iter);
		}
		
	}

	void removeObj(RMObject obj)
	{
		TreePath temp = getPathFromObject(cast(RMObject)obj);
		rowDeleted(temp);

		
	}
	void prepend(RMObject obj, RMObject dest)
	{
		System.currentScene.prepend(obj, dest);

		TreeIter iter;
		TreePath path = getPathFromObject(obj);
		assert(path !is null);
		writeln(path.getIndices);
		//--//iter = new TreeIter();
		//--//getIter(iter, path);

		//--//rowInserted(path, iter);
		//--//rowHasChildToggled(path, iter);

		path.up();
		if(path.getIndices.length != 0)
		{
			writeln(path.getIndices);
			//--//iter = new TreeIter(this, path);
			//--//getIter(iter, path);
			//--//rowHasChildToggled(path, iter);
		}
	}

	RMObject getObjectFromPath(TreePath path)
	{
		int[]         indices;
		int           n, depth;

		indices = path.getIndices();
		depth   = path.getDepth();

		RMObject g = System.currentScene.root;
		
		
		foreach(int i; indices)
		{
			if(i >= g.getChildren.length)
				return null;
			else
				g = cast(RMObject)g.getChildren[i];
		}
		return g;
	}
	TreePath getPathFromObject(RMObject obj)
	{
		int[] indices;
		TraverseScene(System.currentScene.root, obj, indices);
		reverse(indices);
		if(indices.length == 0)
			return null;
		TreePath path = new TreePath(indices[0]);
		if(indices.length > 1)
		{
			for(int i = 1; i < indices.length; i ++)
			{
				path.appendIndex(indices[i]);
			}
		}
		return path;
	}
	void TraverseScene(RMObject g, RMObject searchObj, ref int[]indices)
	{
		auto children = g.getChildren();
		//search Children
		for(int i = 0; i < children.length; i++ )
		{
			if(children[i] == searchObj)
			{
				indices ~= i;
				return;
			}
			TraverseScene(cast(RMObject)children[i], searchObj, indices);
			if(indices.length != 0)
			{
				indices ~= i;
				return;
			}
		}

	}

	void updatePath(RMObject obj)//, TreePath oldPath)
	{
		TreePath path = getPathFromObject(obj);
		//auto indices = path.getIndices;
		//oldPath.appendIndex(path.getIndices[$-1]);
		assert(path !is null);
		TreeIter iter =  new TreeIter();
		getIter(iter, path);

		rowInserted(path, iter);
	}

//Destination Drag

	/**
	* Asks the #GtkTreeDragDest to insert a row before the path @dest,
	* deriving the contents of the row from @selection_data. If @dest is
	* outside the tree so that inserting before it is impossible, %FALSE
	* will be returned. Also, %FALSE may be returned if the new row is
	* not created for some model-specific reason.  Should robustly handle
	* a @dest no longer found in the model!
	*
	* Params:
	*     dest = row to drop in front of
	*     selectionData = data to drop
	*
	* Return: whether a new row was created before position @dest
	*/
	override public bool dragDataReceived(TreePath dest, SelectionData selectionData)
	{
		string uuidString = to!string(selectionData.getData);
		auto id = parseUUID(uuidString); 
		auto objSource = System.currentScene.findObjByID(id);
		foreach(child; objSource.getChildren)
		{
			TreePath temp = getPathFromObject(cast(RMObject)child);
			rowDeleted(temp);
		}
		auto sourceParent = cast(RMObject)objSource.getParent;
		auto oldPath = getPathFromObject(objSource);
		if(objSource is null)
			return false;
		RMObject objDest = getObjectFromPath(dest);
		if(objDest !is null)
		{
			prepend(objSource, objDest);


		}
		else
		{
			auto indices = dest.getIndices();
			auto index = indices[$-1];
			TreePath parentPath = dest.copy();
			parentPath.up();
			auto parent = getObjectFromPath(parentPath);
		
			if(parent == cast(RMObject)objSource.getParent)
			{
				index --;
				//parentPath.appendIndex(index);
				//dest = parentPath.copy;
			}
			objSource.getParent.removeChild(objSource);
			parent.addChildInPlace(objSource, index);

			//--//TreeIter iter = new TreeIter();
			//--//getIter(iter, dest);
			//--//rowInserted(dest, iter);
			//--//rowHasChildToggled(dest, iter);
		}

		if(sourceParent != System.currentScene.root)
		{
			//--//TreePath sourcePath = getPathFromObject(sourceParent);
			//--//writeln(sourcePath.getIndices);
			//--//TreeIter iter = new TreeIter(this, sourcePath);
			//--//rowHasChildToggled(sourcePath, iter);
		}
		//if(oldPath.up)
		//{
			foreach(child; objSource.getChildren)
			{
				//--//updatePath(cast(RMObject)child);
			}

		//}

		return true;
	}

	/**
	* Determines whether a drop is possible before the given @dest_path,
	* at the same depth as @dest_path. i.e., can we drop the data in
	* @selection_data at that location. @dest_path does not have to
	* exist; the return value will almost certainly be %FALSE if the
	* parent of @dest_path doesn’t exist, though.
	*
	* Params:
	*     destPath = destination row
	*     selectionData = the data being dragged
	*
	* Return: %TRUE if a drop is possible before @dest_path
	*/
	override public bool rowDropPossible(TreePath destPath, SelectionData selectionData)
	{
		return true;
	}


//SourceDrag

	/**
	* Asks the #GtkTreeDragSource to delete the row at @path, because
	* it was moved somewhere else via drag-and-drop. Returns %FALSE
	* if the deletion fails because @path no longer exists, or for
	* some model-specific reason. Should robustly handle a @path no
	* longer found in the model!
	*
	* Params:
	*     path = row that was being dragged
	*
	* Return: %TRUE if the row was successfully deleted
	*/
	override public bool dragDataDelete(TreePath path)
	{

		//Take care of that in other places
		//rowDeleted(path);
		return true;
	}

	/**
	* Asks the #GtkTreeDragSource to fill in @selection_data with a
	* representation of the row at @path. @selection_data->target gives
	* the required type of the data.  Should robustly handle a @path no
	* longer found in the model!
	*
	* Params:
	*     path = row that was dragged
	*     selectionData = a #GtkSelectionData to fill with data
	*         from the dragged row
	*
	* Return: %TRUE if data of the required type was provided
	*/
	override public bool dragDataGet(TreePath path, SelectionData selectionData)
	{
		RMObject rmObj = getObjectFromPath(path);
		string test = rmObj.id.toString();
		selectionData.set(cast(GdkAtom)test, test.sizeof, test.dup);
		return true;
	}

	/**
	* Asks the #GtkTreeDragSource whether a particular row can be used as
	* the source of a DND operation. If the source doesn’t implement
	* this interface, the row is assumed draggable.
	*
	* Params:
	*     path = row on which user is initiating a drag
	*
	* Return: %TRUE if the row can be dragged
	*/
	override public bool rowDraggable(TreePath path)
	{	
		return true;
	}


}