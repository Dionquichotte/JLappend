;********************************************************************************************************************
; JL Append v011, december 2015
;
; Sanquin CAP Laboratorium, Dion Methorst november 2015
;
; Script to fill up Tecan EVOware joblists with dummy PBS Samples until $MaxSamples is reached.
; JLappend.ini file in the script directory has a default entry of maximum 9 samples per joblist
; JLappend.ini file can be changed after initial run of JLappend
; Changes will apply until JLappend.ini is deleted, a new default JLappend.ini will be made upon restarting
;
; prerequisites:
;
; joblistfiles placed in folder inside FileLocation read from JLappend.ini
; maximum amount of samples per assay set in JLappend.ini file
;
; joblist format:
;
; 					header							H; time and date
;					any subsequent sample 			P; SampleId
;													O;[LIMSID];1;[dilution protocol];1;1.0
;					end of file						L;
;
;********************************************************************************************************************
#include <AutoItConstants.au3>
#include <MsgBoxConstants.au3>
#include <Array.au3>
#include <File.au3>

If not FileExists(@Scriptdir & "\Jlappend.ini") then
	Local $Settings = "MaxSamples=9" & @CRLF & "FileLocation=C:\apps\EVO\job\"
	IniWriteSection(@Scriptdir & "\Jlappend.ini", "Settings", $Settings)
	Endif

$aSettings = IniReadSection(@Scriptdir & "\Jlappend.ini", "Settings")
	;_ArrayDisplay($aSettings)

$FileLocation = $aSettings[2][1]
$MaxSamples = int($aSettings[1][1])
$MaxLines = ($MaxSamples * 2) + 2

		if  $MaxSamples < 1 Then
			msgbox(0,"Error", "Something's wrong" & @CRLF & @CRLF & _
			"MaxSamples in JLappend.ini file smaller than 1",20)
			exit
		Endif


 $aFileList = _FileListToArray($FileLocation, "*")							;full path
 $aFileList2 = _FileListToArray($FileLocation, Default, Default, True)		;listed folders only
	;_arraydisplay($aFilelist2, "ELx folders2")
	;_arraydisplay($aFilelist, "ELx folders")

; loop through EL folders
For $i = 1 to Ubound($aFileList2)-1

	$ELJobList = _FileListToArray($FileLocation & $aFileList[$i] & "\" , "*.twl")
	;_arraysort($aELJoblist)
	;_arraydisplay($ELJobList, "joblists")

	;loop through joblists
	for $j = 1 to Ubound($ELJobList)-1

		$aJL = FileReadToArray($aFileList2[$i] & "\" & $ELjoblist[$j])
		if stringleft($aJL[2],2) <> "O;" Then
			msgbox(0,"Error", "Something's wrong" & @CRLF & @CRLF & _
			"Check joblist: " & @CRLF & $aFileList2[$i] & "\" & $ELjoblist[$j] ,20)
		Endif

		; number of lines iin the joblist
		; $number is the amount of PBS dummies to be added
		$CountLines = Ubound($aJL)
		$Number = ($Maxlines - $CountLines)/2
		if  $Number >= 1 then
			;msgbox(0,"", $CountLines & " /2= " & $number)
			; _arraydisplay($aJL, "joblist lines")

			;add to $aJL (joblst read to array) the $Number of PBS dummy entries until MaxSamples (default = 9) is reached
			For	$q = 1 to $number
			$CountLines2 = Ubound($aJL)-1
			_ArrayInsert ( $aJL, $CountLines2, "P;PBS" & $q)
			_ArrayInsert ( $aJL, $CountLines2 +1, $aJL[2])
			;_arraydisplay($aJL, "joblist lines")
			next

			; open joblist file and write array to file, original is overwritten!
			$Joblist = $aFileList2[$i] & "\" & $ELjoblist[$j]
			$OpenJL = fileopen($Joblist, 2)
			_FileWriteFromArray($Joblist, $aJL, 0)
			Fileclose($Joblist)
		EndIf
	next
Next