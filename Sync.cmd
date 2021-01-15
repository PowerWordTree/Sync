::目录同步脚本
::@author FB
::@version 1.02

@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION
CD /D "%~dp0"
SET "BIN=BeyondCompare\BComp.exe"
ECHO. >BeyondCompare\BCState.xml
SET "RETURN=0"

::处理命令行参数
::  Sync.CMD [配置文件名[.cfg]]
IF "%~1" == "" (
  SET "CFG_FILE=%~dpn0.cfg"
) ELSE (
  IF /I "%~x1" == ".cfg" (
    SET "CFG_FILE=%~f1"
  ) ELSE (
    SET "CFG_FILE=%~f1.cfg"
  )
)
::检查参数
IF NOT EXIST "%CFG_FILE%" (
  ECHO.
  ECHO 配置文件不存在!
  SET "RETURN=1"
  GOTO :END
)
::读取配置文件
FOR %%I IN ("RUN_MODE","LEFT_PATH","RIGHT_PATH","COPY_SUBDIR","COPY_OPTION","SYNC_MODE","SYNC_OPTION") DO SET "%%I="
FOR /F "eol=# tokens=1,* delims== usebackq" %%I IN ("%CFG_FILE%") DO (
  CALL :TRIM "%%I" "VARNAME"
  CALL :TRIM "%%J" "VARDATA"
  SET "!VARNAME!=!VARDATA!"
)
SET "VARNAME="
SET "VARDATA="
::配置执行参数
CALL :GET_FILENAME "%CFG_FILE%" "CFG_NAME"
CALL :GET_DATE "NOW_DATE"
SET "SNAPSHOT_FILE=%CFG_NAME%.BCSS"
SET "LOG_FILE=LOG\%CFG_NAME%_%NOW_DATE%.LOG"
SET "NOW_DATE="
SET "CFG_NAME="
FOR /F "tokens=*" %%I IN ('%COPY_SUBDIR%') DO SET "COPY_SUBDIR=%%I"
SET "SYNC_OPTION=%SYNC_OPTION:-=->%"
::开始同步
IF "_%RUN_MODE%" == "_SYNC" (
  :: 同步文件
  "%BIN%" /silent @BCScript\Mirror.BCScript
  IF NOT "%ERRORLEVEL%" == "0" SET "RETURN=%ERRORLEVEL%"
) ELSE (
  :: 判断是否存在快照
  IF NOT EXIST "%SNAPSHOT_FILE%" (
    COPY /Y "BCScript\Empty.BCSS" "%SNAPSHOT_FILE%" 1>NUL 2>NUL
  )
  :: 复制差异文件到目标目录
  "%BIN%" /silent @BCScript\Copyfile.BCScript
  IF NOT "%ERRORLEVEL%" == "0" SET "RETURN=%ERRORLEVEL%"
  :: 更新快照
  "%BIN%" /silent @BCScript\Snapshot.BCScript
  IF NOT "%ERRORLEVEL%" == "0" SET "RETURN=%ERRORLEVEL%"
)
GOTO :END


::统一日期格式字符串
::  参数1: 输出到变量(否则输出到屏幕)
:GET_DATE
FOR /F "tokens=1,2,3,* delims=/.-\ " %%A IN ("%DATE%") DO (
  IF "_%~1" == "_" (
    ECHO %%A-%%B-%%C
  ) ELSE (
    SET "%~1=%%A-%%B-%%C"
  )
)
GOTO :EOF

::去空格
::  参数1: 目标字符串
::  参数2: 输出到变量名(可选,直接输出到屏幕)
:TRIM
CALL :TRIM_TO_VAR %~1
IF "_%~2" == "_" (
  ECHO %TRIMED_STRING%
) ELSE (
  SET "%~2=%TRIMED_STRING%"
)
SET "TRIMED_STRING="
GOTO :EOF

::去空格到固定变量TRIMED_STRING
::  参数: 目标字符串
:TRIM_TO_VAR
SET "TRIMED_STRING=%*"
GOTO :EOF

::获取文件名(不含扩展名和路径)
::  参数1: 文件路径
::  参数2: 输出到变量名(可选,直接输出到屏幕)
:GET_FILENAME
IF "_%~2" == "_" (
  ECHO %~n1
) ELSE (
  SET "%~2=%~n1"
)
GOTO :EOF

:END
FOR %%I IN ("SRC_DIR","DST_DIR","RUN_MODE","COPY_SUBDIR","COPY_OPTION","SYNC_MODE","SYNC_OPTION","CFG_FILE","SNAPSHOT_FILE","LOG_FILE") DO SET "%%I="
EXIT /B %RETURN%
