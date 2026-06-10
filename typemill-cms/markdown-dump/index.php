<?php

$output=null;
$retval=null;
exec('/var/www/html/markdown-dump/create-dump.sh', $output, $retval);

$dumpFile = '/tmp/whole_site.md';

header('Content-Type: text/markdown; charset=UTF-8');
header('Content-Language: fi');
header('Content-Length: ' . filesize($dumpFile));
header('Content-Disposition: attachment; filename="Portfolio.md"');

readfile($dumpFile);
exit;

?>
