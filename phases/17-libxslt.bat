
set PROJECT=libxslt
set REPO=https://github.com/GNOME/libxslt.git
set TAG=v1.1.34

call "%~dp0\common.bat" prepare_project || exit /b 1

cd "%SRCROOT%\%PROJECT%\win32" || exit /b 1

echo.
echo ### Apply patches
:: this commit are required for v1.1.34 to build on Windows
:: (can be removed when updating to the next release)
git cherry-pick --no-commit e2584eed1c84c18f16e42188c30d2c3d8e3e8853 || exit /b 1

echo.
echo ### Running configure
set CONFIGURE_OPTS=
if "%BUILD_TYPE%" == "Debug" (
  set "CONFIGURE_OPTS=cruntime=/MDd debug=yes"
)
cscript configure.js ^
  compiler=msvc ^
  crypto=no xslt_debug=no ^
  %CONFIGURE_OPTS% ^
  "prefix=%INSTALL_PREFIX%" ^
  "include=%INSTALL_PREFIX%\include" ^
  "lib=%INSTALL_PREFIX%\lib" ^
  "sodir=%INSTALL_PREFIX%\lib" ^
  || exit /b 1

echo.
echo ### Building
:: we only build the static libraries
nmake /f Makefile.msvc libxslta libexslta || exit /b 1

echo.
echo ### Installing
:: rename libxslt_a.lib to xslt.lib to allow linking using -lxslt
:: (the wildcard suffix is required to suppress the "file or directory" prompt)
xcopy /Y /F "bin.msvc\libxslt_a.lib" "%INSTALL_PREFIX%\lib\xslt.lib*" || exit /b 1
xcopy /Y /F "bin.msvc\libexslt_a.lib" "%INSTALL_PREFIX%\lib\exslt.lib*" || exit /b 1
xcopy /Y /F /S "%SRCROOT%\%PROJECT%\libxslt\*.h" "%INSTALL_PREFIX%\include\libxslt\" || exit /b 1
xcopy /Y /F /S "%SRCROOT%\%PROJECT%\libexslt\*.h" "%INSTALL_PREFIX%\include\libexslt\" || exit /b 1
