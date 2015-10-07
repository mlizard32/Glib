set PATH=C:\D\dmd2\windows\\bin;C:\Program Files (x86)\Windows Kits\8.0\\\bin;%PATH%
set DMD_LIB=;"..\Libs" 

echo ..\src\Glib\GUI\controls.d >Debug\Glib.build.rsp
echo ..\src\Glib\GUI\Font.d >>Debug\Glib.build.rsp
echo ..\src\Glib\GUI\package.d >>Debug\Glib.build.rsp
echo ..\src\Glib\GUI\UITexture.d >>Debug\Glib.build.rsp
echo ..\src\Glib\GUI\Widget.d >>Debug\Glib.build.rsp
echo ..\src\Glib\Scene\Camera.d >>Debug\Glib.build.rsp
echo ..\src\Glib\Scene\GObject.d >>Debug\Glib.build.rsp
echo ..\src\Glib\Scene\Light.d >>Debug\Glib.build.rsp
echo ..\src\Glib\Scene\Material.d >>Debug\Glib.build.rsp
echo ..\src\Glib\Scene\Mesh.d >>Debug\Glib.build.rsp
echo ..\src\Glib\Scene\Model.d >>Debug\Glib.build.rsp
echo ..\src\Glib\Scene\Node.d >>Debug\Glib.build.rsp
echo ..\src\Glib\Scene\package.d >>Debug\Glib.build.rsp
echo ..\src\Glib\Scene\Render.d >>Debug\Glib.build.rsp
echo ..\src\Glib\Scene\Scene.d >>Debug\Glib.build.rsp
echo ..\src\Glib\Scene\Shader.d >>Debug\Glib.build.rsp
echo ..\src\Glib\Scene\Transform.d >>Debug\Glib.build.rsp
echo ..\src\Glib\System\Input.d >>Debug\Glib.build.rsp
echo ..\src\Glib\System\Log.d >>Debug\Glib.build.rsp
echo ..\src\Glib\System\package.d >>Debug\Glib.build.rsp
echo ..\src\Glib\System\System.d >>Debug\Glib.build.rsp
echo ..\src\Glib\System\window.d >>Debug\Glib.build.rsp
echo ..\src\Glib\allDerelcit.d >>Debug\Glib.build.rsp
echo main.d >>Debug\Glib.build.rsp
echo ..\src\Glib\package.d >>Debug\Glib.build.rsp
echo C:\Users\qtg843\Documents\Test\Glib\gl3n\Debug\gl3n.lib >>Debug\Glib.build.rsp

dmd -g -debug -X -Xf"Debug\Glib.json" -I"..\..\dub Derelict\Import" -I"..\src" -deps="Debug\Glib.dep" -c -of"Debug\Glib.obj" @Debug\Glib.build.rsp
if errorlevel 1 goto reportError

set LIB="C:\D\dmd2\windows\bin\..\lib"
echo. > Debug\Glib.build.lnkarg
echo "Debug\Glib.obj","Debug\Glib.exe_cv","Debug\Glib.map",C:\Users\qtg843\Documents\Test\Glib\gl3n\Debug\gl3n.lib+ >> Debug\Glib.build.lnkarg
echo DerelictFT.lib+ >> Debug\Glib.build.lnkarg
echo DerelictASSIMP3.lib+ >> Debug\Glib.build.lnkarg
echo imgui.lib+ >> Debug\Glib.build.lnkarg
echo user32.lib+ >> Debug\Glib.build.lnkarg
echo kernel32.lib+ >> Debug\Glib.build.lnkarg
echo ..\Libs\/NOMAP/CO/NOI >> Debug\Glib.build.lnkarg

"C:\Program Files (x86)\VisualD\pipedmd.exe" -deps Debug\Glib.lnkdep C:\D\dmd2\windows\bin\link.exe @Debug\Glib.build.lnkarg
if errorlevel 1 goto reportError
if not exist "Debug\Glib.exe_cv" (echo "Debug\Glib.exe_cv" not created! && goto reportError)
echo Converting debug information...
"C:\Program Files (x86)\VisualD\cv2pdb\cv2pdb.exe" "Debug\Glib.exe_cv" "Debug\Glib.exe"
if errorlevel 1 goto reportError
if not exist "Debug\Glib.exe" (echo "Debug\Glib.exe" not created! && goto reportError)

goto noError

:reportError
echo Building Debug\Glib.exe failed!

:noError
