# Outputs the number of hours the computer has been turned on.
# grouped by date.

. ".\common.ps1"

$sessions = CanonicalizeSessions(SessionsFromCSV($input))

# Gather statistics
$days = @{}
foreach($session in $sessions) {
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
foreach($day in ($days.GetEnumerator() | Sort-Object Name)) {
  $date = $day.Name
  $hours = $day.Value
  echo "$date,$hours"
}