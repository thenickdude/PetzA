# Note that this is a Borland-format makefile, build me through the "RAD Studio Command Prompt"

HELPNDOC_PATH = C:\Program Files (x86)\IBE Software\HelpNDoc 6\hnd6.exe
MADCOLLECTION_PATH = C:\Program Files (x86)\madCollection
INNOSETUP_PATH = C:\Program Files (x86)\Inno Setup 5\ISCC.exe

all : petzasetup.exe

build\PetzA.toy : source\petzaunit.pas source\PetzA.dpr source\PetzA.dproj
	-@mkdir build
	msbuild /target:Build /p:config=Release source\PetzA.dproj
	"$(MADCOLLECTION_PATH)\madExcept\Tools\madExceptPatch.exe" build\PetzA.toy source\PetzA.mes

# http://www.jrsoftware.org/isdl.php - Use the Unicode version
petzasetup.exe : petzasetup.iss build\PetzAHelp.chm build\PetzA.toy build\verify.dll proficons\*
	"$(INNOSETUP_PATH)" petzasetup.iss /q

# https://www.helpndoc.com/download/
build\PetzAHelp.chm : helpndoc\PetzAHelp.hnd
	-mkdir build
	cd helpndoc
	echo "HelpNDoc's command line compiler appears to be broken in v5 and v6, please build it using their GUI instead"
	"$(HELPNDOC_PATH)" petzahelp.hnd build -only="Build CHM documentation"

# DLL used during the install process for identifying installed Petz versions
build\verify.dll : source\Verify.dpr
	-@mkdir build
	msbuild /target:Build /p:config=Release source\Verify.dproj

clean :
	-del build\*
