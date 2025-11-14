function Read-Toon {
    param(
        [string]$ToonText,
        [int]$IndentSize = 2,
        [bool]$Strict = $true,
        [string]$ExpandPaths = 'off'
    )

    $lines = $ToonText -split "`n"
    $parsed = Read-ToonLines -Lines $lines -IndentSize $IndentSize -Strict $Strict

    if ($ExpandPaths -eq 'safe') {
        $parsed = Convert-ExpandedPath -Value $parsed -Strict $Strict
    }

    return $parsed
}

function Read-ToonLines {
    param([string[]]$Lines, [int]$IndentSize, [bool]$Strict, [int]$CurrentDepth = 0)

    $nonEmptyLines = $Lines | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    if ($nonEmptyLines.Count -eq 0) { return $null }

    $firstLine = $nonEmptyLines[0]
    # Match property tabular: users[2]{id,name,role}:
    if ($firstLine -match '^(\w+)\[(\d+)\](\{.*\})?:\s*(.*)$') {
        $prop = $matches[1]
        $length = [int]$matches[2]
        $fields = if ($matches[3]) { $matches[3].Trim('{','}').Split(',') | ForEach-Object { $_.Trim() } } else { $null }
        $inline = $matches[4]

        $array = @()
        if ($inline) {
            $array = $inline.Split(',') | ForEach-Object { Read-Primitive -Token $_.Trim() }
        } else {
            $rowLines = $nonEmptyLines | Select-Object -Skip 1
            foreach ($rowLine in $rowLines) {
                if ($fields) {
                    # Tabular
                    $values = $rowLine.Trim().Split(',')
                    $obj = [ordered]@{}
                    for ($k = 0; $k -lt $fields.Count; $k++) {
                        $obj[$fields[$k]] = Read-Primitive -Token $values[$k].Trim()
                    }
                    $array += $obj
                } else {
                    # List item
                    if ($rowLine.Trim() -match '^- (.+)$') {
                        $array += Read-Primitive -Token $matches[1]
                    }
                }
            }
        }
        $obj = [ordered]@{}
        $obj[$prop] = $array
        return $obj
    }
    elseif ($firstLine -match '^\[(\d+)\](\{.*\})?:\s*(.*)$') {
        # Root array
        $length = [int]$matches[1]
        $fields = if ($matches[2]) { $matches[2].Trim('{','}').Split(',') | ForEach-Object { $_.Trim() } } else { $null }
        $inline = $matches[3]

        $array = @()
        if ($inline) {
            $array = $inline.Split(',') | ForEach-Object { Read-Primitive -Token $_.Trim() }
        } else {
            $rowLines = $nonEmptyLines | Select-Object -Skip 1
            foreach ($rowLine in $rowLines) {
                if ($fields) {
                    # Tabular
                    $values = $rowLine.Trim().Split(',')
                    $obj = [ordered]@{}
                    for ($k = 0; $k -lt $fields.Count; $k++) {
                        $obj[$fields[$k]] = Read-Primitive -Token $values[$k].Trim()
                    }
                    $array += $obj
                } else {
                    # List item
                    if ($rowLine.Trim() -match '^- (.+)$') {
                        $array += Read-Primitive -Token $matches[1]
                    }
                }
            }
        }
        return $array
    } else {
        # Root object
        $obj = [ordered]@{}
        foreach ($line in $nonEmptyLines) {
            if ($line -match '^(\w+):\s*(.*)$') {
                $key = $matches[1]
                $val = $matches[2]
                $obj[$key] = Read-Primitive -Token $val
            }
        }
        return $obj
    }
}

function Get-LineDepth {
    param([string]$Line, [int]$IndentSize)
    $leadingSpaces = ($Line -match '^(\s*)')[1].Length
    return $leadingSpaces / $IndentSize
}

function Read-Primitive {
    param([string]$Token)

    $token = $Token.Trim()
    if ($token -eq 'null') { return $null }
    if ($token -eq 'true') { return $true }
    if ($token -eq 'false') { return $false }
    if ($token -match '^".*"$') {
        return $token.Trim('"').Replace('\\n', "`n").Replace('\\r', "`r").Replace('\\t', "`t").Replace('\\"', '"').Replace('\\\\', '\')
    }
    if ($token -match '^-?\d+(\.\d+)?$') { return [double]$token }
    return $token
}

function Convert-ExpandedPath {
    param([object]$Value, [bool]$Strict)

    # Simple expansion for dotted keys
    if ($Value -is [System.Collections.IDictionary]) {
        $expanded = [ordered]@{}
        foreach ($key in $Value.Keys) {
            if ($key -match '^\w+\.\w+$') {
                $parts = $key.Split('.')
                if (-not $expanded.Contains($parts[0])) {
                    $expanded[$parts[0]] = [ordered]@{}
                }
                $expanded[$parts[0]][$parts[1]] = Convert-ExpandedPath -Value $Value[$key] -Strict $Strict
            } else {
                $expanded[$key] = Convert-ExpandedPath -Value $Value[$key] -Strict $Strict
            }
        }
        return $expanded
    }
    elseif ($Value -is [System.Collections.IList]) {
        return $Value | ForEach-Object { Convert-ExpandedPath -Value $_ -Strict $Strict }
    }
    else {
        return $Value
    }
}