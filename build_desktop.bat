@echo off

set OUT_DIR=build\desktop

if not exist %OUT_DIR% mkdir %OUT_DIR%

odin build main_desktop -out:%OUT_DIR%\game_desktop.exe