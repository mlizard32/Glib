set PATH=C:\D\dmd2\windows\\bin;C:\Program Files (x86)\Windows Kits\8.0\\\bin;%PATH%
set DMD_LIB=;"..\Libs"  "..\Glib\Debug"

echo ..\src\Editor\EditorEvents.d >Debug\Editor.build.rsp
echo ..\src\Editor\GUITest.d >>Debug\Editor.build.rsp
echo ..\src\Editor\imgui_sdl.d >>Debug\Editor.build.rsp
echo ..\src\Editor\main.d >>Debug\Editor.build.rsp
echo ..\src\Editor\RMObjDetails.d >>Debug\Editor.build.rsp
echo ..\src\Editor\SceneGraph.d >>Debug\Editor.build.rsp
echo ..\src\Editor\TreeModelDragable.d >>Debug\Editor.build.rsp
echo C:\Users\qtg843\Documents\Test\Glib\Glib\Debug\Glib.lib >>Debug\Editor.build.rsp
echo C:\Users\qtg843\Documents\Test\Glib\gl3n\Debug\gl3n.lib >>Debug\Editor.build.rsp

dmd -g -debug -X -Xf"Debug\Editor.json" -I"..\..\dub Derelict\Import" -I"..\src" -deps="Debug\Editor.dep" -c -of"Debug\Editor.obj" @Debug\Editor.build.rsp
if errorlevel 1 goto reportError

set LIB="C:\D\dmd2\windows\bin\..\lib"
echo. > Debug\Editor.build.lnkarg
echo "Debug\Editor.obj","Debug\Editor.exe_cv","Debug\Editor.map",C:\Users\qtg843\Documents\Test\Glib\Glib\Debug\Glib.lib+ >> Debug\Editor.build.lnkarg
echo C:\Users\qtg843\Documents\Test\Glib\gl3n\Debug\gl3n.lib+ >> Debug\Editor.build.lnkarg
echo DerelictFT.lib+ >> Debug\Editor.build.lnkarg
echo DerelictASSIMP3.lib+ >> Debug\Editor.build.lnkarg
echo DerelictImgui.lib+ >> Debug\Editor.build.lnkarg
echo Glib.lib+ >> Debug\Editor.build.lnkarg
echo imgui.lib+ >> Debug\Editor.build.lnkarg
echo + >> Debug\Editor.build.lnkarg
echo gtkd.lib+ >> Debug\Editor.build.lnkarg
echo user32.lib+ >> Debug\Editor.build.lnkarg
echo kernel32.lib+ >> Debug\Editor.build.lnkarg
echo ..\Libs\+ >> Debug\Editor.build.lnkarg
echo ..\Glib\Debug\/NOMAP/CO/NOI >> Debug\Editor.build.lnkarg

"C:\Program Files (x86)\VisualD\pipedmd.exe" -deps Debug\Editor.lnkdep C:\D\dmd2\windows\bin\link.exe @Debug\Editor.build.lnkarg
if errorlevel 1 goto reportError
if not exist "Debug\Editor.exe_cv" (echo "Debug\Editor.exe_cv" not created! && goto reportError)
echo Converting debug information...
"C:\Program Files (x86)\VisualD\cv2pdb\cv2pdb.exe" "Debug\Editor.exe_cv" "Debug\Editor.exe"
if errorlevel 1 goto reportError
if not exist "Debug\Editor.exe" (echo "Debug\Editor.exe" not created! && goto reportError)

goto noError

:reportError
echo Building Debug\Editor.exe failed!

:noError
