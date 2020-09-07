function Get-ReadablePassphrase
{
    <#
.SYNOPSIS
Generates readable passphrases suitable for passwords

.DESCRIPTION
Describe the function in more detail

.EXAMPLE
Get-ReadablePassphrase
Generates a readable passphrase with the default settings.

.EXAMPLE
Get-ReadablePassphrase -AlternateDefault
Generates a readable passphrase with the alternate default settings.
Generates more readable, but *slightly* less secure passwords.

.PARAMETER Count
Optional. Default=1. The number of passwords to generate

.PARAMETER MinLength
Optional. Default=1. The minimum length of the password.

.PARAMETER MaxLength
Optional. Default=999. The maximum length of the password.

.PARAMETER Strength
Optional. Default=Random.
Valid Values:
'Random', 'RandomShort', 'RandomLong', 'RandomForever', 'Normal', 'NormalAnd', 'NormalEqual',
'NormalEqualAnd', 'NormalEqualSpeech', 'NormalRequired', 'NormalRequiredAnd', 'NormalRequiredSpeech',
'NormalSpeech', 'Strong', 'StrongAnd', 'StrongEqual', 'StrongEqualAnd', 'StrongEqualSpeech',
'StrongRequired', 'StrongRequiredAnd', 'StrongRequiredSpeech', 'StrongSpeech', 'Insane',
'InsaneAnd', 'InsaneEqual', 'InsaneEqualAnd', 'InsaneEqualSpeech', 'InsaneRequired',
'InsaneRequiredAnd', 'InsaneRequiredSpeech', 'InsaneSpeech', 'Custom'

.PARAMETER wordSeparator
Optional. Default=' '. Default word separator.  Can be empty

.PARAMETER AnyLength
Optional. Default=0. Used to indicate a non-gramatic, totally random selection of word forms

.PARAMETER phraseString
Optional. Default=$null.

.PARAMETER mutStandard
Optional. Default=$false.

.PARAMETER mutAlternate
Optional. Default=$false.

.PARAMETER mutUpper
Optional. Default=Never.
Valid Values:
'Never', 'StartOfWord', 'Anywhere', 'RunOfLetters', 'WholeWord'

.PARAMETER mutUpperCount
Optional. Default=2.

.PARAMETER mutNumeric
Optional. Default=Never.
Valid Values:
'Never', 'StartOfWord', 'EndOfWord', 'StartOrEndOfWord', 'Anywhere', 'EndOfPhrase'

.PARAMETER mutNumericCount
Optional. Default=2.

.PARAMETER DictionaryPath
Optional. Default=Internal dictionary. Use this to specify an alternate dictionary.

.PARAMETER AlternateDefault
Optional. Switch. use an alternate default configuration that is *slightly* less secure, but more readable.

.PARAMETER AsSecureString
Optional. Switch. Returns the password as a securestring rather than plain text.

#>
    [CmdletBinding(SupportsShouldProcess = $False, ConfirmImpact = 'Low')]
    param (
        [Parameter()]
        [int]$Count = 1,

        [Parameter()]
        [int]$MinLength = 1,

        [Parameter()]
        [int]$MaxLength = 999,

        [Parameter()]
        [ValidateSet('Random', 'RandomShort', 'RandomLong', 'RandomForever',
            'Normal', 'NormalAnd', 'NormalEqual', 'NormalEqualAnd', 'NormalEqualSpeech', 'NormalRequired', 'NormalRequiredAnd', 'NormalRequiredSpeech', 'NormalSpeech',
            'Strong', 'StrongAnd', 'StrongEqual', 'StrongEqualAnd', 'StrongEqualSpeech', 'StrongRequired', 'StrongRequiredAnd', 'StrongRequiredSpeech', 'StrongSpeech',
            'Insane', 'InsaneAnd', 'InsaneEqual', 'InsaneEqualAnd', 'InsaneEqualSpeech', 'InsaneRequired', 'InsaneRequiredAnd', 'InsaneRequiredSpeech', 'InsaneSpeech',
            'Custom')]
        [string]$Strength = 'Random',

        [Parameter()]
        [string]$wordSeparator = ' ',

        [Parameter()]
        #Used to indicate a non-gramatic, totally random selection of word forms
        [int]$anyLength = 0,

        [Parameter()]
        [string]$phraseString = $null,

        [Parameter()]
        [switch]$mutStandard = $false,
        [Parameter()]
        [switch]$mutAlternate = $false,

        [Parameter()]
        [ValidateSet('Never', 'StartOfWord', 'Anywhere', 'RunOfLetters', 'WholeWord')]
        [string]$mutUpper = 'Never',
        [Parameter()]
        [int]$mutUpperCount = 2,

        [Parameter()]
        [ValidateSet('Never', 'StartOfWord', 'EndOfWord', 'StartOrEndOfWord', 'Anywhere', 'EndOfPhrase')]
        [string]$mutNumeric = 'Never',
        [Parameter()]
        [int]$mutNumericCount = 2,

        [Parameter()]
        [ValidateScript( { (Test-Path $_) })] #must return $true/$false
        [string]$DictionaryPath,

        [Parameter()]
        [switch]$AlternateDefault,

        [Parameter()]
        [switch]$AsSecureString
    )

    begin
    {
        #do pre script checks, etc

        function genNonGrammaticalClause($count)
        {
            Write-Verbose "Generating Non-Grammatical Phrase Description of $count words"
            $wordset = @()
            (1..$count) | ForEach-Object { $wordset += ([MurrayGrant.ReadablePassphrase.PhraseDescription.AnyWordClause]::new()) }
            return $wordset
        }
        if (-not $PSBoundParameters.containskey("DictionaryPath")) {
            $dictionarypath = $MyInvocation.MyCommand.Module.PrivateData['defaultdictionary']
        }

    }

    process
    {

        if ($AlternateDefault)
        {
            Write-Verbose "Setting Alternate Defaults"
            if (-not $PSBoundParameters.ContainsKey("Count")) { $Count = 5 }
            if (-not $PSBoundParameters.ContainsKey("MinLength")) { $MinLength = 20 }
            if (-not $PSBoundParameters.ContainsKey("MaxLength")) { $MaxLength = 30 }
            if (-not $PSBoundParameters.ContainsKey("Strength")) { $Strength = "Custom" }
            if (-not $PSBoundParameters.ContainsKey("WordSeparator")) { $wordSeparator = "" }
            if (-not $PSBoundParameters.ContainsKey("anyLength")) { $anyLength = 0 }
            if (-not $PSBoundParameters.ContainsKey("mutStandard")) { $mutStandard = $false }
            if (-not $PSBoundParameters.ContainsKey("mutAlternate")) { $mutAlternate = $false }
            if (-not $PSBoundParameters.ContainsKey("mutUpper")) { $mutUpper = "StartOfWord" }
            if (-not $PSBoundParameters.ContainsKey("mutUpperCount")) { $mutUpperCount = 50 }
            if (-not $PSBoundParameters.ContainsKey("mutNumeric")) { $mutNumeric = "Never" }
            if (-not $PSBoundParameters.ContainsKey("mutNumericCount")) { $mutNumericCount = 0 }
            if (-not $PSBoundParameters.ContainsKey("PhraseString"))
            {
                $phraseString = "Noun = {
    Adjective->1, NoAdjective->1,
    NoArticle->5, DefiniteArticle->4, IndefiniteArticle->4, Demonstrative->0, PersonalPronoun->2,
    ProperNoun->1, CommonNoun->12, AdjectiveNoun->2,
    Number->1, NoNumber->5,
    Plural->0, Single->1,
    Preposition->0, NoPreposition->1,
 }

Verb = {
    Adverb->1, NoAdverb->1,
    Interrogative->1, NoInterrogative->8,
    IntransitiveByNoNoun->0, IntransitiveByPreposition->0,
    Present->10, Past->8, Future->8, ContinuousPast->0, Continuous->0, Perfect->0, Subjunctive->0,
 }

Noun = {
    Adjective->1, NoAdjective->1,
    NoArticle->5, DefiniteArticle->4, IndefiniteArticle->4, Demonstrative->0, PersonalPronoun->2,
    ProperNoun->0, CommonNoun->1, AdjectiveNoun->0,
    Number->1, NoNumber->0,
    Plural->1, Single->0,
    Preposition->0, NoPreposition->1,
 }"
            }
        }


        $objStrength = [MurrayGrant.ReadablePassphrase.PhraseStrength]::$strength
        $useCustomLoader = $false
        $loaderDll = ""
        $loaderType = ""
        $loaderArguments = ""
        $customPhrasePath = ""
        $query = $false
        $objNumericMutator = [MurrayGrant.ReadablePassphrase.Mutators.NumericStyles]::$mutNumeric
        $objUpperMutator = [MurrayGrant.ReadablePassphrase.Mutators.AllUppercaseStyles]::$mutUpper
        $phraseDescription = [MurrayGrant.ReadablePassphrase.PhraseDescription.Clause]::CreatePhraseDescription
        if ($phraseString -ne "" -and $phraseString -ne $null) { $phraseDescription = [MurrayGrant.ReadablePassphrase.PhraseDescription.Clause]::CreateCollectionFromTextString($phraseString) }
        $maxAttemptsPerCount = 1000

        Write-Verbose "Intializing Database"
        $generator = New-Object MurrayGrant.ReadablePassphrase.ReadablePassphraseGenerator
        $loaderT = New-Object MurrayGrant.ReadablePassphrase.Dictionaries.ExplicitXmlDictionaryLoader
        $loader = ([MurrayGrant.ReadablePassphrase.Dictionaries.IDictionaryLoader])


        $loaderarguments = "url=$dictionarypath; iscompressed=true; "
        $generator.LoadDictionary($loadert, $loaderArguments)
        #write-verbose the various settings


        if ($anylength -gt 0)
        {
            #haven't quite figured out how to do the equivalent in powershell.  He did a yield return new AnyWordClause()
            $combinations = $generator.CalculateCombinations((genNonGrammaticalClause -count $anyLength))
        }
        elseif ($objStrength -ne [MurrayGrant.ReadablePassphrase.PhraseStrength]::Custom)
        {
            $combinations = $generator.CalculateCombinations($objStrength)
        }
        else
        {
            #handle custom phrase description
            $combinations = $generator.CalculateCombinations($PhraseDescription)
        }

        Write-Verbose ("Average Combinations: {0:E3} ({1:N2} bits)" -f $combinations.OptionalAverage, $combinations.OptionalAverageAsEntropyBits)
        Write-Verbose ("Total Combinations: {0:E3} - {1:E3} ({2:N2} - {3:N2} bits)" -f $combinations.Shortest, $combinations.Longest, $combinations.ShortestAsEntropyBits, $combinations.LongestAsEntropyBits)


        #write-verbose mutator details
        $upperTypeText = switch -Wildcard ($mutUpper) { "run*" { [MurrayGrant.ReadablePassphrase.Mutators.AllUppercaseStyles]::RunOfLetters } "*word" { [MurrayGrant.ReadablePassphrase.Mutators.AllUppercaseStyles]::WholeWord } default { "" } }
        $upperTypeText2 = switch -Wildcard ($mutUpper) { "run*" { [MurrayGrant.ReadablePassphrase.Mutators.AllUppercaseStyles]::RunOfLetters } "*word" { [MurrayGrant.ReadablePassphrase.Mutators.AllUppercaseStyles]::WholeWord } default { "capital" } }

        #if ($mutStandard) {
        #    Write-Verbose "Use Std Mutators (2num 2cap)"
        #} elseif ($mutAlternate) {
        #    Write-Verbose "Use Alt Mutators (2num 1cap word)"
        #} elseif ($mutNumericCount -ne 0 -and $mutUpperCount -ne 0) {
        #    write-verbose ("Using upper case {2} and numeric mutators ({0:N0} {3}(s), {1:N0} number(s))" -f $mutUpperCount, $mutNumericCount, $upperTypeText, $upperTypeText2)
        #} elseif ($mutNumeric -eq "Never" -and $mutUpper -ne "Never") {
        #    write-verbose ("Using upper case {1} mutator only ({0:N0} {2}(s))" -f $mutUpperCount, $upperTypeText, $upperTypeText2)
        #} elseif ($mutNumeric -ne "Never" -and $mutUpper -eq "Never") {
        #    write-verbose ("Using numeric mutator only ({0:N0} number(s))" -f $mutNumericCount)
        #} else {
        #    write-verbose "Using no mutators"
        #}




        $mutators = @([MurrayGrant.ReadablePassphrase.Mutators.UppercaseMutator]::Basic , [MurrayGrant.ReadablePassphrase.Mutators.NumericMutator]::basic)
        if ($objUpperMutator -gt 0 -and $objUpperMutator -le [MurrayGrant.ReadablePassphrase.Mutators.AllUppercaseStyles]::Anywhere)
        {
            $mutators += [MurrayGrant.ReadablePassphrase.Mutators.UppercaseMutator]::Basic
        }
        #add code to create other mutators


        $mutators = @()
        if ($mutStandard)
        {
            Write-Verbose "Mutators: Adding Standard Set"
            $mutators += [MurrayGrant.ReadablePassphrase.Mutators.UppercaseMutator]::Basic
            $mutators += [MurrayGrant.ReadablePassphrase.Mutators.NumericMutator]::basic
        }
        elseif ($mutAlternate)
        {
            Write-Verbose "Mutators: Adding Alternate Set"
            $mutators += [MurrayGrant.ReadablePassphrase.Mutators.UppercaseWordMutator]::Basic
            $mutators += [MurrayGrant.ReadablePassphrase.Mutators.NumericMutator]::basic
        }
        else
        {

            if ($mutUpper -eq "StartOfWord" -or $mutUpper -eq "Anywhere")
            {
                #write-verbose "Mutators: Adding UppercaseMutator ($mutUpper, $mutUpperCount)"
                $newmut = New-Object MurrayGrant.ReadablePassphrase.Mutators.UppercaseMutator
                $newmut.When = $mutUpper
                $newmut.NumberOfCharactersToCapitalise = $mutUpperCount
                $mutators += $newmut
            }
            if ($mutUpper -eq "RunOfLetters")
            {
                #write-verbose "Mutators: Adding UppercaseRunMutator ($mutUpper, $mutUpperCount)"
                $newmut = New-Object MurrayGrant.ReadablePassphrase.Mutators.UppercaseRunMutator
                $newmut.NumberOfRuns = $mutUpperCount
                $mutators += $newmut
            }
            if ($mutUpper -eq "WholeWord")
            {
                #write-verbose "Mutators: Adding UppercaseWordMutator ($mutUpper, $mutUpperCount)"
                $newmut = New-Object MurrayGrant.ReadablePassphrase.Mutators.UppercaseWordMutator
                $newmut.NumberOfWordsToCapitalise = $mutUpperCount
                $mutators += $newmut
            }
            if ($mutNumeric -ne "Never")
            {
                #write-verbose "Mutators: Adding NumericMutator ($mutNumeric, $mutNumericCount)"
                $newmut = New-Object MurrayGrant.ReadablePassphrase.Mutators.NumericMutator
                $newmut.When = $mutNumeric
                $newmut.NumberOfNumbersToAdd = $mutNumericCount
                $mutators += $newmut
            }
        }

        #verbose output
        foreach ($mut in $mutators)
        {
            if ($mut.gettype().name -eq "NumericMutator")
            {
                Write-Verbose ("Mutator: Numeric, When: {0} Count: {1}" -f $mut.when, $mut.numberofnumberstoadd)
            }
            else
            {
                #uppercase mutator
                if ($mut.when -eq "StartOfWord" -or $mut.when -eq "Anywhere") { Write-Verbose ("Mutator: Uppercase, When: {0} Count; {1}" -f $mut.when, $mut.NumberOfCharactersToCapitalise) }
                if ($mut.when -eq "RunOfLetters") { Write-Verbose ("Mutator: Uppercase, When: {0} Count; {1}" -f $mut.when, $mut.NumberOfRuns) }
                if ($mut.when -eq "WholeWord") { Write-Verbose ("Mutator: Uppercase, When: {0} Count; {1}" -f $mut.when, $mut.NumberOfWordsToCapitalise) }
            }
        }

        ##### generate
        $generated = 0
        $attempts = 0
        $maxattempts = $count * $maxAttemptsPerCount
        Write-Verbose "Starting Password Generation (maxattempts: $maxattempts)"
        while ($generated -lt $count)
        {
            $attempts++
            if ($attempts % 10 -eq 0) { Write-Verbose "Attempt $attempts/$maxattempts; Complete: $generated/$count" }
            $phrase = ""
            try
            {
                if ($anyLength -gt 0)
                {
                    $nongram = genNonGrammaticalClause $anylength
                    $phrase = $generator.Generate([MurrayGrant.ReadablePassphrase.PhraseDescription.Clause[]]$nongram, " ", [MurrayGrant.ReadablePassphrase.Mutators.IMutator[]]$mutators)
                }
                elseif ($objStrength -eq [MurrayGrant.ReadablePassphrase.PhraseStrength]::Custom)
                {
                    $phrase = $generator.Generate($phraseDescription, " ", [MurrayGrant.ReadablePassphrase.Mutators.IMutator[]]$mutators)
                }
                else
                {
                    $phrase = $generator.Generate($objStrength, " ", [MurrayGrant.ReadablePassphrase.Mutators.IMutator[]]$mutators)
                }
            }
            catch {}
            if ($wordSeparator -ne " ")
            {
                #this has to be done afterwards or the mutators won't work.
                #mutators depend on spaces to work, then we apply the word separator
                $phrase = $phrase.Replace(" ", $wordSeparator)
            }

            if ($phrase.Length -ge $minLength -and $phrase.Length -le $maxLength)
            {
                $generated++
                if ($AsSecureString)
                {
                    Write-Output (ConvertTo-SecureString -String $phrase -AsPlainText -Force)
                }
                else
                {
                    Write-Output $phrase
                }
            }
            if ($attempts -ge $maxattempts) { break }
        }

        if ($attempts -ge $maxattempts)
        {
            Write-Error "Could not generate requested $count after $attempts attempts.  Try changing Min/MaxLength."

        }

    }

    end
    {

    }

}
