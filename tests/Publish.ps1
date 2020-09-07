
#config.json = {"ApiKey":"PSGalleryAPIKey"}
$config = convertfrom-json -InputObject (gc .\config.json -raw)
$outpath = "$psscriptroot\..\Releases"
$srcpath = "$psscriptroot\..\Module"
$srcdata = Import-PowerShellDataFile "$srcpath\psreadablepassphrase.psd1"
$ver = $srcdata.ModuleVersion
$name = 'PSReadablePassphrase'

if ($env:psmodulepath -notlike "*$outpath*" ) {$env:PSModulePath = $env:PSModulePath + ";$outpath"}
$targetpath = "$outpath\$name\$ver"

if ((test-path $targetpath)) {remove-item $targetpath -recurse -force}

new-item $targetpath -ItemType Directory
robocopy /mir $srcpath $targetpath

#publish-module -name $name -nugetapikey $apikey -repository PSGallery
#-path "C:\Dropbox\Scripts\VB.NET\WebJEA\WebJEAConfig\Module"
#
publish-module -path $targetpath -NuGetApiKey $config.apikey -Repository PSGallery
