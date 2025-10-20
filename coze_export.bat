@echo off
REM 在 Windows 电脑上下载并导出 Coze 所需的所有 Docker 镜像
chcp 65001 >nul
setlocal enabledelayedexpansion
 
set OUTPUT_DIR=coze_images
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"
 
echo =========================================
echo   Coze 镜像下载和导出工具 (Windows)
echo =========================================
echo.
 
REM 逐个处理每个镜像
call :process_image "mysql:8.4.5"
call :process_image "bitnami/redis:8.0"
call :process_image "bitnami/elasticsearch:8.18.0"
call :process_image "minio/minio:RELEASE.2025-06-13T11-33-47Z-cpuv1"
call :process_image "bitnami/etcd:3.5"
call :process_image "milvusdb/milvus:v2.5.10"
call :process_image "nsqio/nsq:v1.2.1"
call :process_image "cozedev/coze-studio-server:latest"
call :process_image "cozedev/coze-studio-web:latest"
 
echo.
echo =========================================
echo 导出完成！
echo 镜像文件位于: %OUTPUT_DIR%\
echo.
echo 文件列表:
dir /B "%OUTPUT_DIR%\*.tar" 2>nul
echo.
echo 请将 %OUTPUT_DIR% 目录复制到 Linux 服务器 /usr/local/ai/coze-studio/docker/ 目录下
echo 然后在 Linux 服务器上运行:
echo   sudo ./import_images.sh
echo =========================================
echo.
pause
goto :eof
 
:process_image
set IMAGE=%~1
echo ----------------------------------------
echo 处理: %IMAGE%
 
REM 检查镜像是否已存在
docker images --format "{{.Repository}}:{{.Tag}}" | findstr /C:"%IMAGE%" >nul 2>&1
if errorlevel 1 (
    echo   正在下载...
    docker pull %IMAGE%
    if errorlevel 1 (
        echo   下载失败，跳过
        goto :eof
    )
) else (
    echo   本地已存在
)
 
REM 导出镜像，生成文件名
set FILENAME=%IMAGE%
set FILENAME=%FILENAME::=_%
set FILENAME=%FILENAME:/=_%
echo   导出到: %OUTPUT_DIR%\%FILENAME%.tar
docker save -o "%OUTPUT_DIR%\%FILENAME%.tar" %IMAGE%
 
REM 显示文件大小
for %%F in ("%OUTPUT_DIR%\%FILENAME%.tar") do (
    set SIZE=%%~zF
    set /a SIZE_MB=!SIZE! / 1048576
    echo   文件大小: !SIZE_MB! MB
)
goto :eof