
@Echo Off&SetLocal ENABLEDELAYEDEXPANSION 　　
FOR %%a in (*.txt) do (
set "name=%%a"
set "name=!name:[DES][csv]=!"
ren "%%a" "!name!"
)

