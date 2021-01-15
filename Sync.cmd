::Ŀ¼ͬ���ű�
::@author FB
::@version 1.02

@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION
CD /D "%~dp0"
SET "BIN=BeyondCompare\BComp.exe"
ECHO. >BeyondCompare\BCState.xml
SET "RETURN=0"

::���������в���
::  Sync.CMD [�����ļ���[.cfg]]
IF "%~1" == "" (
  SET "CFG_FILE=%~dpn0.cfg"
) ELSE (
  IF /I "%~x1" == ".cfg" (
    SET "CFG_FILE=%~f1"
  ) ELSE (
    SET "CFG_FILE=%~f1.cfg"
  )
)
::������
IF NOT EXIST "%CFG_FILE%" (
  ECHO.
  ECHO �����ļ�������!
  SET "RETURN=1"
  GOTO :END
)
::��ȡ�����ļ�
FOR %%I IN ("RUN_MODE","LEFT_PATH","RIGHT_PATH","COPY_SUBDIR","COPY_OPTION","SYNC_MODE","SYNC_OPTION") DO SET "%%I="
FOR /F "eol=# tokens=1,* delims== usebackq" %%I IN ("%CFG_FILE%") DO (
  CALL :TRIM "%%I" "VARNAME"
  CALL :TRIM "%%J" "VARDATA"
  SET "!VARNAME!=!VARDATA!"
)
SET "VARNAME="
SET "VARDATA="
::����ִ�в���
CALL :GET_FILENAME "%CFG_FILE%" "CFG_NAME"
CALL :GET_DATE "NOW_DATE"
SET "SNAPSHOT_FILE=%CFG_NAME%.BCSS"
SET "LOG_FILE=LOG\%CFG_NAME%_%NOW_DATE%.LOG"
SET "NOW_DATE="
SET "CFG_NAME="
FOR /F "tokens=*" %%I IN ('%COPY_SUBDIR%') DO SET "COPY_SUBDIR=%%I"
SET "SYNC_OPTION=%SYNC_OPTION:-=->%"
::��ʼͬ��
IF "_%RUN_MODE%" == "_SYNC" (
  :: ͬ���ļ�
  "%BIN%" /silent @BCScript\Mirror.BCScript
  IF NOT "%ERRORLEVEL%" == "0" SET "RETURN=%ERRORLEVEL%"
) ELSE (
  :: �ж��Ƿ���ڿ���
  IF NOT EXIST "%SNAPSHOT_FILE%" (
    COPY /Y "BCScript\Empty.BCSS" "%SNAPSHOT_FILE%" 1>NUL 2>NUL
  )
  :: ���Ʋ����ļ���Ŀ��Ŀ¼
  "%BIN%" /silent @BCScript\Copyfile.BCScript
  IF NOT "%ERRORLEVEL%" == "0" SET "RETURN=%ERRORLEVEL%"
  :: ���¿���
  "%BIN%" /silent @BCScript\Snapshot.BCScript
  IF NOT "%ERRORLEVEL%" == "0" SET "RETURN=%ERRORLEVEL%"
)
GOTO :END


::ͳһ���ڸ�ʽ�ַ���
::  ����1: ���������(�����������Ļ)
:GET_DATE
FOR /F "tokens=1,2,3,* delims=/.-\ " %%A IN ("%DATE%") DO (
  IF "_%~1" == "_" (
    ECHO %%A-%%B-%%C
  ) ELSE (
    SET "%~1=%%A-%%B-%%C"
  )
)
GOTO :EOF

::ȥ�ո�
::  ����1: Ŀ���ַ���
::  ����2: �����������(��ѡ,ֱ���������Ļ)
:TRIM
CALL :TRIM_TO_VAR %~1
IF "_%~2" == "_" (
  ECHO %TRIMED_STRING%
) ELSE (
  SET "%~2=%TRIMED_STRING%"
)
SET "TRIMED_STRING="
GOTO :EOF

::ȥ�ո񵽹̶�����TRIMED_STRING
::  ����: Ŀ���ַ���
:TRIM_TO_VAR
SET "TRIMED_STRING=%*"
GOTO :EOF

::��ȡ�ļ���(������չ����·��)
::  ����1: �ļ�·��
::  ����2: �����������(��ѡ,ֱ���������Ļ)
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
