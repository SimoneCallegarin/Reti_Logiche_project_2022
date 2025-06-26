@echo off
set xv_path=C:\\Xilinx\\Vivado\\2016.4\\bin
call %xv_path%/xelab  -wto 4a6f5b890fa745ae975a76035fe26724 -m64 --debug typical --relax --mt 2 -L xil_defaultlib -L secureip --snapshot project_tb_behav xil_defaultlib.project_tb -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
