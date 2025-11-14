function ConvertFrom-Toon {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true, Mandatory = $true)]
        [string]$InputString,

        [Parameter()]
        [int]$IndentSize = 2,

        [Parameter()]
        [bool]$Strict = $true,

        [Parameter()]
        [ValidateSet('off', 'safe')]
        [string]$ExpandPaths = 'off',

        [Parameter()]
        [switch]$AsPSObject
    )

    begin {
        $collectedStrings = @()
    }

    process {
        $collectedStrings += $InputString
    }

    end {
        $toonText = $collectedStrings -join "`n"

        # Decode from TOON
        $decoded = Read-Toon -ToonText $toonText -IndentSize $IndentSize -Strict $Strict -ExpandPaths $ExpandPaths

        if ($AsPSObject) {
            # Write-Output ([pscustomobject]$decoded)

            $decoded | ForEach-Object {
                [pscustomobject]$_
            }
        }
        else {
            Write-Output $decoded
        }
    }
}