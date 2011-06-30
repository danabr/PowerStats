# Outputs the number of hours the computer has been turned on.
# grouped by date.

. ".\common.ps1"

$sessions = CanonicalizeSessions(SessionsFromCSV($input))

# Gather statistics
$days = @{}

# Setup dates
if ($sessions.length -gt 1) {
  $current = $sessions[0].Start.Date
  $end  = $sessions[-1].Start.Date
  while($current -lt $end) {
    $days.Add($current, 0)
    $current = $current.AddDays(1)
  }
}

# Calculate hours per day
foreach($session in $sessions) {
  $duration = ($session.End - $session.Start).TotalHours
  $soFar = $days.Get_Item($session.Start.Date)
  $days.Set_Item($session.Start.Date, $soFar + $duration)
}

# Output as CSV
echo "Date,Hours"
foreach($day in ($days.GetEnumerator() | Sort-Object Name)) {
  $date = $day.Name
  $hours = $day.Value
  echo "$date,$hours"
}