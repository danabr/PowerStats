# Utility functions

# Canonicalizes sessions, so that no session spans multiple dates.
function CanonicalizeSessions($sessions)
{
  $canonicalized = @()
  foreach($session in $sessions) {
    while ($session.Start.Date -ne $session.End.Date) {
      $newSession = New-Session
      $newSession.Start = $session.Start
      $newSession.End = $session.Start.Date.AddDays(1)
      $canonicalized += $newSession
      $session.Start = $newSession.End
    }
    $canonicalized += $session
  }
  return $canonicalized
}

# Takes a CSV formated string and creates a new session
function LineToSession($line)
{
  $session = New-Session
  $parts = $line.Split(',')
  $session.Start = Get-Date $parts[0]
  $session.End = Get-Date $parts[1]
  return $session
}

# Creates a new session object
function New-Session()
{
  $sessionObject = New-Object PSObject
  $sessionObject | Add-Member -type NoteProperty -name Start -value 0
  $sessionObject | Add-Member -type NoteProperty -name End -value 0
  return $sessionObject
}

# Extracts all lines from the given input and turns them into session objects
function SessionsFromCSV($lines)
{
  # Skip header line
  $skip = $lines.MoveNext()
  $sessions = @()
  foreach($line in $lines) {
    $sessions += LineToSession($line)
  }
  return $sessions;
}