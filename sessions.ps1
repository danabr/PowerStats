# 
# Founds the start and end times of all "sessions" that the computer
# has been powered on, according to the system log, and outputs them
# in CSV-format.
#
# This script must be run as administrator
#
# This version of the script uses the events for "shutdown" "power on"
# "hibernate" and "sleep mode" in the system log.
#

# Setup
. ".\common.ps1"

$AWAKE_EVENT = 1
$AWAKE_CATEGORY = "Microsoft-Windows-Power-Troubleshooter"
$SLEEP_MODE_EVENT = 42
$START_EVENT = 12
$STOP_EVENT = 13

# Gather events
$evs = Get-EventLog system | where {
                                      $_.InstanceID -eq $AWAKE_EVENT -or
                                      $_.InstanceID -eq $SLEEP_MODE_EVENT -or
                                      $_.InstanceID -eq $START_EVENT -or
                                      $_.InstanceID -eq $STOP_EVENT
                             }| 
                             where {
                             $_.InstanceID -ne $AWAKE_EVENT -or
                             $_.Source -eq $AWAKE_CATEGORY
                           } | sort TimeGenerated

# Extract sessions
$sessions = @()
$currentSession = New-Session
$state = "find_start"
foreach($evt in $evs) {
  if ($state -eq "find_start") {
    if ($evt.InstanceID -eq $START_EVENT -or
        $evt.InstanceID -eq $AWAKE_EVENT) {
      $currentSession.Start = $evt.TimeGenerated
      $state = "find_end"
    }
  }
  elseif ($state -eq "find_end") {
    if ($evt.InstanceID -eq $STOP_EVENT -or
        $evt.InstanceID -eq $SLEEP_MODE_EVENT) {
      $currentSession.End = $evt.TimeGenerated
      $sessions += $currentSession
      $currentSession = New-Session
      $state = "find_start"
    }
  }
}
# Complete the last session
$currentSession.End = Get-Date
$sessions += $currentSession

# Output as CSV
echo "Start,End,Length"
foreach($session in $sessions) {
  $start = $session.Start
  $end = $session.End
  $length = ($end - $start).TotalHours
  echo "$start,$end,$length"
}