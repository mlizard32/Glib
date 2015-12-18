set PATH=C:\D\dmd2\windows\\bin;C:\Program Files (x86)\Windows Kits\8.0\\\bin;%PATH%
set DMD_LIB=;"..\Libs"  "..\Glib\Debug"
dmd -g -debug -X -Xf"Debug\ConsoleApp1.json" -I"..\..\dub Derelict\Import" -I"..\src" -deps="Debug\ConsoleApp1.dep" -c -of"Debug\ConsoleApp1.obj" main.d
if errorlevel 1 goto reportError

set LIB="C:\D\dmd2\windows\bin\..\lib"
echo. > Debug\ConsoleApp1.build.lnkarg
echo "Debug\ConsoleApp1.obj","Debug\ConsoleApp1.exe_cv","Debug\ConsoleApp1.map",dlib.lib+ >> Debug\ConsoleApp1.build.lnkarg
echo DerelictFT.lib+ >> Debug\ConsoleApp1.build.lnkarg
echo DerelictASSIMP3.lib+ >> Debug\ConsoleApp1.build.lnkarg
echo DerelictImgui.lib+ >> Debug\ConsoleApp1.build.lnkarg
echo Glib.lib+ >> Debug\ConsoleApp1.build.lnkarg
echo imgui.lib+ >> Debug\ConsoleApp1.build.lnkarg
echo + >> Debug\ConsoleApp1.build.lnkarg
echo gtkd.lib+ >> Debug\ConsoleApp1.build.lnkarg
echo dlangui.lib+ >> Debug\ConsoleApp1.build.lnkarg
echo user32.lib+ >> Debug\ConsoleApp1.build.lnkarg
echo kernel32.lib+ >> Debug\ConsoleApp1.build.lnkarg
echo ..\Libs\+ >> Debug\ConsoleApp1.build.lnkarg
echo ..\Glib\Debug\/NOMAP/CO/NOI >> Debug\ConsoleApp1.build.lnkarg

"C:\Program Files (x86)\VisualD\pipedmd.exe" -deps Debug\ConsoleApp1.lnkdep C:\D\dmd2\windows\bin\link.exe @Debug\ConsoleApp1.build.lnkarg
if errorlevel 1 goto reportError
if not exist "Debug\ConsoleApp1.exe_cv" (echo "Debug\ConsoleApp1.exe_cv" not created! && goto reportError)
echo Converting debug information...
"C:\Program Files (x86)\VisualD\cv2pdb\cv2pdb.exe" "Debug\ConsoleApp1.exe_cv" "Debug\ConsoleApp1.exe"
if errorlevel 1 goto reportError
if not exist "Debug\ConsoleApp1.exe" (echo "Debug\ConsoleApp1.exe" not created! && goto reportError)

goto noError

:reportError
echo Building Debug\ConsoleApp1.exe failed!

:noError
