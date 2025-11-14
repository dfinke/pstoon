function ConvertTo-Toon {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true, Mandatory = $true)]
        [object]$InputObject,

        [Parameter()]
        [int]$IndentSize = 2,

        [Parameter()]
        [ValidateSet('off', 'safe')]
        [string]$KeyFolding = 'off',

        [Parameter()]
        [int]$FlattenDepth = [int]::MaxValue
    )

    begin {
        $collectedObjects = @()
    }

    process {
        $collectedObjects += $InputObject
    }

    end {
        if ($collectedObjects.Count -eq 1) {
            $data = $collectedObjects[0]
        }
        elseif ($collectedObjects.Count -gt 1 -and $collectedObjects[0] -is [char]) {
            $data = -join $collectedObjects
        }
        else {
            $data = $collectedObjects
        }

        # If primitive, output directly
        if ($data -is [string] -or $data -is [int] -or $data -is [long] -or $data -is [double] -or $data -is [bool]) {
            Write-Output $data
            return
        }

        # Normalize to JSON model
        $normalized = Convert-ToonValue -Value $data

        # Encode to TOON
        $toonString = Write-Toon -Value $normalized -IndentSize $IndentSize -KeyFolding $KeyFolding -FlattenDepth $FlattenDepth

        Write-Output $toonString
    }
}