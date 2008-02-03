build : petzasetup.iss build/PetzAHelp.chm build/PetzA.toy build/verify.dll proficons/* "d:\program files\sherlock software\innotools\downloader\it_download.iss" "d:\program files\sherlock software\innotools\downloader\itdownload.dll"
	ISCC petzasetup.iss /q

build/PetzAHelp.chm : helpndoc/PetzaHelp.hnd
	helpndoc "c:\sherlocksoftware\petz\petza\helpndoc\petzahelp.hnd" /c /sxc /oxc="c:\sherlocksoftware\petz\petza\build\PetzAHelp.chm"