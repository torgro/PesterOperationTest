$here = Split-Path -Parent $MyInvocation.MyCommand.Path | Split-Path -Parent | Join-Path -ChildPath Functions

function Measure-String
{
[cmdletbinding()]
Param(
    [Parameter(ValueFromPipeline)]
    [string[]]$InputObject
    ,
    [string]$SearchString
    ,
    [switch]$SkipComments
)

Begin
{
    $count = 0
    $inCommentSection = $false
    $PreviousStr = ""
}

Process
{   
    if ($SearchString.Length -gt 1)
    {
        foreach ($str in $InputObject)
        {
            if($SkipComments.IsPresent)
            {
                if ($Str.Contains("<#"))
                {
                    $inCommentSection = $true
                    Write-Verbose "in commentssection"
                }
                
                $trimmed = $str.TrimStart()
                if ($PreviousStr.Contains("#>"))
                {
                    Write-Verbose "end of commentssection"
                    $inCommentSection = $false
                }

                $PreviousStr = $str

                if ($trimmed.StartsWith("#") -or $inCommentSection -eq $true)
                {
                    continue
                }
            }
            Write-Verbose "Searching [$str] for [$SearchString]"
            $stringlength = $str.length
            $searchTextLength = $SearchString.Length
            $replaced = $str.ToLower().Replace($SearchString.ToLower(),"")
            $foundCount = ($stringlength - $replaced.length) / $searchTextLength
            $count += $foundCount
            
        }
    }
    else
    {
        foreach ($str in $InputObject)
        {
            
            if($SkipComments.IsPresent)
            {
                if ($Str.Contains("<#"))
                {
                    $inCommentSection = $true
                    Write-Verbose "in commentssection"
                }
                
                $trimmed = $str.TrimStart()
                if ($PreviousStr.Contains("#>"))
                {
                    Write-Verbose "end of commentssection"
                    $inCommentSection = $false
                }

                $PreviousStr = $str

                if ($trimmed.StartsWith("#") -or $inCommentSection -eq $true)
                {
                    Write-Verbose "Skipping searching [$str] for [$SearchString]"
                    continue
                }
            }

            Write-Verbose "Searching [$str] for [$SearchString]"
            foreach ($char in $str.toCharArray())
            {
                if ($char -eq $SearchString)
                {
                    $count++
                }
            }
        }
    }    
}
END
{
    [Pscustomobject]@{
        SearchString = $SearchString
        Count = $count
    }    
}
}


Describe "Powershell Syntax Tests" {
    $files = Get-ChildItem -Path $here | Where-Object Name -notlike "*.Tests.ps1"    

    foreach ($file in $files)
    {
        $content = Get-Content -Path $file.fullname -Encoding UTF8 -ReadCount 0 -Raw
        $fileName = $file.FileName
        $name = $file.BaseName.Replace(".Tests","")
        $functionNameCount = Measure-String -InputObject $content -SearchString $name | Select-Object -ExpandProperty Count
        $quotes = Measure-String -InputObject $content -SearchString "'" -SkipComments | Select-Object -ExpandProperty Count
        $doubleQuotes = Measure-String -InputObject $content -SearchString '"' | Select-Object -ExpandProperty Count
        $doubleDollar = Measure-String -InputObject $content -SearchString '$$' | Select-Object -ExpandProperty Count
        $ifFormatting = Measure-String -InputObject $content -SearchString "if(" | Select-Object -ExpandProperty Count
        $foreachFormatting = Measure-String -InputObject $content -SearchString "foreach(" | Select-Object -ExpandProperty Count
        $cmdletbindingCount = Measure-String -InputObject $content -SearchString "cmdletbinding(" | Select-Object -ExpandProperty Count
        $aliasExceptions = @("foreach","h","r","type")
        $aliases = Get-Alias | Where Name -notin $aliasExceptions | Select-Object -ExpandProperty Name

        foreach ($alias in $aliases)
        {
            $aliasCount = (Measure-String -InputObject $content -SearchString " $alias " -SkipComments).Count
            if ($aliasCount -ne 0)
            {
                It "[$name] should not use Alias [$alias]" {
                    $aliasCount | Should Be 0
                }
            }            
        }

        It "[$name] should not be null" {
            $content | Should Not Be $null
        }

        It "[$name] should match function Name" {
            $functionNameCount | Should Not Be 0
        }

        It "[$name] Quotes count should be even" {
            $quotes % 2 | Should Be 0
        }

        It "[$name] doubleQuotes count should be even" {
            $doubleQuotes % 2 | Should Be 0
        }

        It "[$name] double dollar count should be 0" {
            $doubleDollar | Should Be 0
        }

        It "[$name] should not have if() formatting" {
            $ifFormatting | Should Be 0
        }

        It "[$name] should not have foreach() formatting" {
            $foreachFormatting | Should Be 0
        }

        It "[$name] should have cmdletbinding specified" {
            $cmdletbindingCount | should BeGreaterThan 0
        }        
        $aliasCount = 0        
    }    
}