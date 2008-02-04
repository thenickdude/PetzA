madcollection = D:\Program Files\MadCollection

radprojects = D:\Documents and Settings\Nicholas Sherlock\My Documents\RAD Studio\Projects

delphi5projects = C:\Program Files\Borland\Delphi5\Projects

delphi5paths = $(delphi5projects)\stubby;$(delphi5projects)\cipher\Dec\Source;$(delphi5projects)\dimime\Source;$(delphi5projects)\versioninfo;$(delphi5projects)\sherlocksoftware

sourcepath = $(delphi5paths);$(madcollection)\madExcept\dexter;$(madcollection)\madBasic\dexter;$(madcollection)\madDisAsm\dexter;$(madcollection)\madKernel\dexter;$(radprojects)\graphics32;$(radprojects)\g32interface;$(radprojects)\gif;$(radprojects)\pngobject;$(radprojects)\XML Parser

build : petzasetup.iss build/PetzAHelp.chm build/PetzA.toy build/verify.dll proficons/*
	ISCC petzasetup.iss /q

build/PetzAHelp.chm : helpndoc/PetzAHelp.hnd
	helpndoc "$(realpath helpndoc\PetzAHelp.hnd)" /c /sxc /oxc="$@"

build/verify.dll : source/Verify.dpr
	cd source && dcc32 -Q -E../build -B Verify.dpr

build/PetzA.toy : source/petzaunit.pas source/petza.dpr source/petza.dproj
	cd source && dcc32 -Q -E../build -B -U"$(sourcepath)" -I"$(sourcepath)" PetzA.dpr
	/cygdrive/d/Program\ Files/madCollection/madExcept/Tools/madExceptPatch.exe build/petza.toy source/petza.mes

clean :
	rm build/*