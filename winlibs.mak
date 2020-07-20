!IFNDEF VERSION
VERSION=unknown
!ENDIF

!IF "$(PHP_SDK_ARCH)" == "x64"
PLATFORM=x64
!ELSE
PLATFORM=Win32
!ENDIF

!IF "$(PHP_SDK_VS)" == "vs16"
SLNDIR=vs2019
TOOLSET=v142
!ELSEIF "$(PHP_SDK_VS)" == "vc15"
SLNDIR=vs2017
TOOLSET=v141
!ENDIF

OUTPUT=$(MAKEDIR)\..\libsodium-$(VERSION)-$(PHP_SDK_VS)-$(PHP_SDK_ARCH)
ARCHIVE=$(OUTPUT).zip

all:
	git checkout -- .
	git clean -fdx

	cd  builds\msvc\$(SLNDIR)
	msbuild /t:Rebuild /p:Configuration=StaticRelease /p:Platform=$(PLATFORM) libsodium.sln
	msbuild /t:Rebuild /p:Configuration=DynRelease /p:Platform=$(PLATFORM) libsodium.sln

	-rmdir /s /q $(OUTPUT)
	cd ..\..\..
	xcopy bin\$(PLATFORM)\Release\$(TOOLSET)\dynamic\libsodium.dll $(OUTPUT)\bin\*
	xcopy bin\$(PLATFORM)\Release\$(TOOLSET)\dynamic\libsodium.pdb $(OUTPUT)\bin\*
	xcopy /e src\libsodium\include\*.h $(OUTPUT)\include\*
	rmdir /s /q $(OUTPUT)\include\sodium\private
	del $(OUTPUT)\include\sodium\randombytes_nativeclient.h
	xcopy bin\$(PLATFORM)\Release\$(TOOLSET)\dynamic\libsodium.lib $(OUTPUT)\lib\*
	copy bin\$(PLATFORM)\Release\$(TOOLSET)\static\libsodium.lib $(OUTPUT)\lib\libsodium_a.lib

	del $(ARCHIVE)
	7za a $(ARCHIVE) $(OUTPUT)\*
