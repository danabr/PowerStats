# Outputs the number of hours the computer has been turned on.
# grouped by date.

. ".\common.ps1"

# Skip header line
$skip = $input.MoveNext().Split(',')

function LineToSession($line)
{
  $session = New-Session
  $parts = $line.Split(',')
  $session.Start = Get-Date $parts[0]
  $session.End = Get-Date $parts[1]
  return $session
}

# Normalize sessions, so that no session spans multiple dates.
$normalizedSessions = @()
foreach($line in $input) {
  $session = LineToSession($line)
  while ($session.Start.Date -ne $session.End.Date) {
    $newSession = New-Session
    $newSession.Start = $session.Start
    $newSession.End = $session.Start.Date+1
    $normalizedSessions += $newSession
    $session.Start = $newSession.End
  }
  $normalizedSessions += $session
}

# Gather statistics
$days = @{}
foreach($session in $normalizedSessions) {
  $duration = ($session.End - $session.Start).TotalHours
  $soFar = $days.Get_Item($session.Start.Date)
  if($soFar -eq $null) {
    $days.Add($session.Start.Date, $duration)
  }
  else {
    $days.Set_Item($session.Start.Date, $soFar + $duration)
  }
}

# Output as CSV
echo "Date,Hours"
foreach($day in $days.GetEnumerator()) {
  $date = $day.Name
  $hours = $day.Value
  echo "$date,$hours"
}