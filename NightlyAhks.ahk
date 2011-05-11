#include FcnLib.ahk

;{{{script

;;run the compiled version, no matter what
;if NOT A_IsCompiled
;{
   ;FileGetTime, timestampAhk, NightlyAhks.ahk
   ;FileGetTime, timestampExe, NightlyAhks.exe
   ;if (timestampAhk > timestampExe)
      ;RunWait, Ahk2exe.exe /in "%A_ScriptFullPath%"
   ;Sleep, 500
   ;Run, NightlyAhks.exe, , UseErrorLevel
   ;ExitApp
;}

debug("log grey line", "starting nightly scripts")

;delete the entire section of the ini for unfinished scripts
ini=gitExempt/%A_ComputerName%.ini
IniDelete(ini, "RunAhkAndBabysit.ahk")

if (A_ComputerName = LeadComputer())
   DeleteTraceFile()

if NOT IsVM()
{
   RunThisNightlyAhk(1, "CopyVimSettings.ahk")
   hypercam()
   RunThisNightlyAhk(7, "UpdateAdobeAcrobatReader.ahk")
}

RunThisNightlyAhk(2, "MintTouch.ahk")
;RunThisNightlyAhk(1, "MorningStatus-GatherData.ahk")
RunThisNightlyAhk(1, "MorningStatus.ahk", "GatherData")
RunThisNightlyAhk(1, "RestartDropbox.ahk")
RunThisNightlyAhk(1, "InfiniteLoop.ahk")
RunThisNightlyAhk(5, "REFPunitTests.ahk", "completedFeaturesOnly")
RunThisNightlyAhk(15, "UnitTests.ahk")

if (A_ComputerName="BAUSTIAN-09PC")
{
   hypercam()
   RunThisNightlyAhk(7, "SaveChromeBookmarks.ahk")
   RunThisNightlyAhk(10, "CreateDropboxBackup.ahk")
   RunThisNightlyAhk(3, "PushToGit.ahk")
}

if (A_ComputerName = LeadComputer())
{
   ;tasks that should be performed on phosphorus
   ;unless if the screen is not accessible
   ;  (last logged in via VPN and Windows logged physCompy out)
   ;  we can tell this if a screenshot saved is only half size
   ;  or possibly just check A_ScreenWidth

   hypercam()
   RunThisNightlyAhk(7, "GetSentryBalances.ahk")
   hypercam()
   RunThisNightlyAhk(7, "MintGetAccountCsvs.ahk")
   hypercam()
   RunThisNightlyAhk(7, "UsaaGetAccountBalances.ahk")
   RunThisNightlyAhk(2, "ProcessMintExport.ahk")

   RunThisNightlyAhk(1, "UsaaCheckingBalanceProjection.ahk")
   RunThisNightlyAhk(1, "AddAhkTask.ahk", "copyTasksToFcnLib")
   ;RunAhkAndBabysit("CreateFinancialPieChart.ahk")
   ;SleepMinutes(15)
}

if (A_ComputerName="PHOSPHORUS")
{
   RunThisNightlyAhk(1, "UpdatePerlPackages.ahk")
   ;looks like FF4 doesn't need a nightly restart (no longer a RAM hog)
   ;RunAhkAndBabysit("RestartFirefox.ahk")
   ;SleepMinutes(1)
   RunThisNightlyAhk(1, "UpdatePidginImStatus.ahk")
}

if (A_ComputerName="PHOSPHORUSVM")
{
   RunThisNightlyAhk(5, "DeleteDropboxCruft.ahk")
}

RunThisNightlyAhk(1, "StartIdleAhks.ahk")

;only run these on the work pc to start things back up again
if (A_ComputerName="PHOSPHORUS")
{
   ;this needs a little bit of click-around time
   RunThisNightlyAhk(1, "LaunchPidgin.ahk")
}

;RunThisNightlyAhk(2, "MoveMouseAcrossEntireScreen.ahk")
RunWait, MoveMouseAcrossEntireScreen.ahk

;make a list of all the ahks that didn't end gracefully
Loop, C:\My Dropbox\AHKs\*.ahk
{
   time:=IniRead(ini, "RunAhkAndBabysit.ahk", A_LoopFileName)
   if (time <> "ERROR")
   {
      MorningStatusAppend(A_LoopFileName, time)
      IniDelete(ini, "RunAhkAndBabysit.ahk", A_LoopFileName)
   }
}

debug("log grey line", "finished nightly scripts")
ExitApp
;}}}

;{{{ functions
RunThisNightlyAhk(waitTimeInMinutes, ahkToRun, params="")
{
   ;TODO put this in a separate script, do not compile (2 new ahks total)
   ;TODO write to ini, runwait, delete from ini
   ;TODO morning status sender will check to see if any ini records remain
   ;TODO another ahk will sit there to babysit, or perhaps we can put that in persistent

   ;quote="
   ;ahkToRun := EnsureStartsWith(ahkToRun, quote)
   ;ahkToRun := EnsureEndsWith(ahkToRun, quote)
   ;params := EnsureStartsWith(params, quote)
   ;params := EnsureEndsWith(params, quote)

   command=AutoHotkey.exe RunAhkAndBabysit.ahk "%ahkToRun%" "%params%" "wait"
   ;if InStr(options, "wait")
      ;RunWait %command%
   ;else
      Run %command%

   SleepMinutes(waitTimeInMinutes)

   ;CloseAllAhks("NightlyAhks")
   CloseAllAhks(A_ScriptName)
   ;ForceReloadAll()
}

hypercam()
{
   if (A_ComputerName="BAUSTIAN-09PC")
   {
      RunAhk("HyperCamRecord.ahk")
      SleepSeconds(10)
   }
}

MorningStatusAppend(ahk, time)
{
   text=AHK failed to end gracefully on %A_ComputerName%: %ahk% (Started at %time%)
   file=gitExempt\morning_status\graceful-%A_ComputerName%.txt
   FileAppendLine(text, file)
}
;}}}

