::
:: build.bat
::
:: Builds and runs the game in the test environment

::
:: Change this number to test with more or fewer players
::
set SDK=c:\whirled\sdk

set CP=%SDK%\dist\lib\ant-launcher.jar;%SDK%\dist\lib\ant.jar;.
set CLASS=org.apache.tools.ant.launch.Launcher
java -classpath %CP% %CLASS% -Dos.name=Windows -Dplayers=2 test-debug
