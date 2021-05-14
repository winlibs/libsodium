param (
    [Parameter(Mandatory)] $architecture,
    [Parameter(Mandatory)] $vs
)

$ErrorActionPreference = "Stop"

if ($architecture -eq "x86") {
    $platform = "Win32"
} else {
    $platform = "x64"
}

if ($vs -eq "vc15") {
    $slndir = "vs2017"
    $toolset = "v141"
} else {
    $slndir = "vs2019"
    $toolset = "v142"
}

Set-Location "builds\msvc\$slndir"
msbuild "/t:Build" "/p:Configuration=StaticRelease" "/p:Platform=$platform" "libsodium.sln"
msbuild "/t:Build" "/p:Configuration=DynRelease" "/p:Platform=$platform" "libsodium.sln"
Set-Location "..\..\.."
New-Item "winlibs" -ItemType "directory"
xcopy "bin\$platform\Release\$toolset\dynamic\libsodium.dll" "winlibs\bin\*"
xcopy "bin\$platform\Release\$toolset\dynamic\libsodium.pdb" "winlibs\bin\*"
xcopy /e "src\libsodium\include\*.h" "winlibs\include\*"
Remove-Item "winlibs\include\sodium\private" -Recurse
xcopy "bin\$platform\Release\$toolset\dynamic\libsodium.lib" "winlibs\lib\*"
Copy-Item "bin\$platform\Release\$toolset\static\libsodium.lib" "winlibs\lib\libsodium_a.lib"
