param([switch]$Publish)
cd $PSScriptRoot
#remove module if to ensure we're testing the latest.

$sb = {
    $ErrorActionPreference = "Stop"
    $rootpath = $args[0]
    $publish = $args[1]
    write-host 'moving to tests folder'
    cd $rootpath

    write-host 'importing pester'
    Import-Module Pester

    write-host "Increment version"
    $psdinfo = Import-PowerShellDataFile -Path ..\module\PSReadablePassphrase.psd1
    [system.version]$ver = $psdinfo.ModuleVersion
    $newver = [system.version]::new($ver.major,$ver.min,$ver.build+1)
    Update-ModuleManifest -Path ..\module\PSReadablePassphrase.psd1 -ModuleVersion $newver
    write-host -ForegroundColor cyan "New Version: $newver"

    #run tests
    write-host 'running pester'
    invoke-pester .\psreadablepassphrase.tests.ps1 -verbose

    if ($publish) {
        write-host "Publish"
        & .\Publish.ps1
    }
}
$job = start-job -scriptblock $sb -ArgumentList $psscriptroot,$publish -name "Tests"

while (($job | get-job).state -ne "Completed") {
    receive-job $job
    start-sleep -Milliseconds 250
}
receive-job $job
