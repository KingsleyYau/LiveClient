@echo off

:: ---- enter folder
%~d0
cd %~dp0

:: ---- define folder path
set common_fodler=..\..\common
set common_c_library_folder=..\..\common-c-library
set livemessage_folder=..\..\livemessage

:: ---- load config file
for /f "delims=" %%i in (deps_config.txt) do set %%i

:: ---- handle
if "trunk"=="%common_c_library_ver%" (
  call :handle %common_c_library_folder% svn://192.168.8.177:8034/client/livecommon/common-c-library
) else (
  call :handle %common_c_library_folder% svn://192.168.8.177:8034/client/tag/livecommon/common-c-library/common-c-library_v%common_c_library_ver%/common-c-library
)

if "trunk"=="%common_ver%" (
  call :handle %common_fodler% svn://192.168.8.177:8034/client/livecommon/common
) else (
  call :handle %common_fodler% svn://192.168.8.177:8034/client/tag/livecommon/common/common_v%common_ver%/common
)

if "trunk"=="%livemessage_ver%" (
  call :handle %livemessage_folder% svn://192.168.8.177:8034/client/livecommon/livemessage
) else (
  call :handle %livemessage_folder% svn://192.168.8.177:8034/client/tag/livecommon/livemessage/livemessage_v%livemessage_ver%/livemessage
)

goto :end

:: ---- handle check svn code
:handle
set module_folder=%1
set module_svn=%2
set svn_info=
svn info %module_folder%|findstr "URL:"|findstr "svn:" > temp
set /p svn_info=<temp
del temp
set "svn_url=%svn_info:URL: =%"
if exist "%module_folder%" (
  if "%svn_url%"=="%module_svn%" (
    svn update %module_folder%
  ) else (
    echo.
    echo. ------===== ERROR =====------
    echo. %module_folder% folder's svn path is not match, please remove and retry.
    echo. current svn path: %svn_url%
    echo. target svn path: %module_svn%
    echo.
    pause
    exit 0
  )
) else (
  svn checkout %module_svn% %module_folder%
)
goto :eof

:: ---- print finish info
:end
echo.
echo.
echo. ------===== FINISH =====------
echo. common-c-library: %common_c_library_ver%
echo. common: %common_ver%
echo. livemessage: %livemessage_ver%
echo.
pause
exit 0

