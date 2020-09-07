function InitPrivateData() {
    $modpath = $PSScriptRoot
    write-verbose "PSScriptRoot: $modpath"

    $requiredassemblies = @("bin\ReadablePassphrase.dll","bin\ReadablePassphrase.Words.dll")
    foreach ($dll in $requiredassemblies) {
        write-verbose "Importing $dll"
        try {
            write-verbose "- Unblocking DLL"
            unblock-file "$modpath\$dll"
        } catch {}
        #[System.Reflection.Assembly]::LoadFile("$modpath\$dll")
        add-type -path "$modpath\$dll"
    }

    $MyInvocation.MyCommand.Module.PrivateData = @{'defaultdictionary'="$modpath\bin\dictionary.xml.gz"}

}
InitPrivateData


. "$psscriptroot\Public\Get-ReadablePassphrase.ps1"
# Export-ModuleMember Get-ReadablePassphrase
