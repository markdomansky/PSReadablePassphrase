cd $PSScriptRoot
#remove module if to ensure we're testing the latest.

$sb = {
    write-host 'moving to tests folder'
    cd $args[0]

    write-host 'importing pester'
    Import-Module Pester

    # write-host 'importing psreadablepassphrase'
    # Import-Module ..\module\psreadablepassphrase.psd1 -ErrorAction stop

    #run tests
    write-host 'running pester'
    invoke-pester .\psreadablepassphrase.tests.ps1 -verbose
}
$job = start-job -scriptblock $sb -ArgumentList $psscriptroot -name "Tests"

while (($job | get-job).state -ne "Completed") {
    receive-job $job
    start-sleep -Milliseconds 250
}
receive-job $job
