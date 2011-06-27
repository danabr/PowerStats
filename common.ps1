# Creates a new session object
function New-Session()
{
  $sessionObject = New-Object PSObject
  $sessionObject | Add-Member -type NoteProperty -name Start -value 0
  $sessionObject | Add-Member -type NoteProperty -name End -value 0
  return $sessionObject
}