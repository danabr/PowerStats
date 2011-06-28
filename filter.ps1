# Only outputs sessions that match the given filter.

. ".\common.ps1"

$filter = $args[0]

# Output header line
$ignore = $input.MoveNext()
$header = $input.Current
echo $header
$skip = $input.MoveNext()

# Filter sessions
foreach($line in $input) {
  $session = LineToSession($line)
  $test = (& $filter)
  if($test) {
    echo $line;
  }
}