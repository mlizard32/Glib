set PATH=C:\D\dmd2\windows\\bin;C:\Program Files (x86)\Windows Kits\8.0\\\bin;%PATH%

echo ..\src\gl3n\ext\hsv.d >Debug\gl3n.build.rsp
echo ..\src\gl3n\ext\matrixstack.d >>Debug\gl3n.build.rsp
echo ..\src\gl3n\aabb.d >>Debug\gl3n.build.rsp
echo ..\src\gl3n\frustum.d >>Debug\gl3n.build.rsp
echo ..\src\gl3n\interpolate.d >>Debug\gl3n.build.rsp
echo ..\src\gl3n\linalg.d >>Debug\gl3n.build.rsp
echo ..\src\gl3n\math.d >>Debug\gl3n.build.rsp
echo ..\src\gl3n\plane.d >>Debug\gl3n.build.rsp
echo ..\src\gl3n\util.d >>Debug\gl3n.build.rsp

"C:\Program Files (x86)\VisualD\pipedmd.exe" dmd -lib -g -debug -X -Xf"Debug\gl3n.json" -deps="Debug\gl3n.dep" -of"Debug\gl3n.lib" -map "Debug\gl3n.map" -L/NOMAP @Debug\gl3n.build.rsp
if errorlevel 1 goto reportError
if not exist "Debug\gl3n.lib" (echo "Debug\gl3n.lib" not created! && goto reportError)

goto noError

:reportError
echo Building Debug\gl3n.lib failed!

:noError
