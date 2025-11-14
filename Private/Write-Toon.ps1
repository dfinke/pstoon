function Write-Toon {
    param(
        [object]$Value,
        [int]$IndentSize = 2,
        [string]$KeyFolding = 'off',
        [int]$FlattenDepth = [int]::MaxValue,
        [int]$Depth = 0,
        [string]$Key = $null
    )

    $indent = ' ' * ($Depth * $IndentSize)

    if ($Value -is [string]) {
        # Treat string as primitive
        return Write-Primitive -Value $Value -Delimiter ','
    }
    elseif ($Value -is [System.Collections.IList]) {
        # Array
        $length = $Value.Count
        $isUniformObjects = Test-UniformObject -Array $Value
        $headerKey = if ($Key) { "$Key" } else { "" }
        if ($isUniformObjects) {
            # Tabular
            $fields = Get-ObjectField -Object $Value[0]
            $fieldList = $fields -join ','
            $header = "${headerKey}[$length]{$fieldList}:"
            $lines = @($header)
            foreach ($item in $Value) {
                $row = @()
                foreach ($field in $fields) {
                    $row += Write-Primitive -Value $item[$field] -Delimiter ','
                }
                $lines += ($row -join ',')
            }
            return $lines -join "`n"
        }
        else {
            # Mixed array
            $header = "${headerKey}[$length]:"
            $lines = @($header)
            foreach ($item in $Value) {
                $encodedItem = Write-Toon -Value $item -IndentSize $IndentSize -KeyFolding $KeyFolding -FlattenDepth $FlattenDepth -Depth ($Depth + 1)
                $lines += "- $encodedItem"
            }
            return ($lines -join "`n").Replace("`n", "`n$indent")
        }
    }
    elseif ($Value -is [System.Collections.IDictionary]) {
        # Object
        $lines = @()
        foreach ($k in $Value.Keys) {
            $val = $Value[$k]
            if ($val -is [System.Collections.IList] -and (Test-UniformObject -Array $val)) {
                # Tabular array
                $lines += Write-Toon -Value $val -IndentSize $IndentSize -KeyFolding $KeyFolding -FlattenDepth $FlattenDepth -Depth $Depth -Key $k
            }
            else {
                $lines += "${k}: $(Write-Primitive -Value $val -Delimiter ',')"
            }
        }
        return $lines -join "`n"
    }
    else {
        # Primitive
        if ($Key) {
            return "$Key`: $(Write-Primitive -Value $Value -Delimiter ',')"
        }
        else {
            return Write-Primitive -Value $Value -Delimiter ','
        }
    }
}

function Test-UniformObject {
    param([System.Collections.IList]$Array)

    if ($Array.Count -eq 0) { return $false }
    $first = $Array[0]
    if (-not ($first -is [System.Collections.IDictionary])) { return $false }

    $fields = Get-ObjectField -Object $first
    foreach ($item in $Array) {
        if (-not ($item -is [System.Collections.IDictionary])) { return $false }
        $itemFields = Get-ObjectField -Object $item
        if ($fields.Count -ne $itemFields.Count -or (Compare-Object $fields $itemFields)) { return $false }
    }
    return $true
}

function Get-ObjectField {
    param([System.Collections.IDictionary]$Object)
    return $Object.Keys | Sort-Object
}

function Write-Primitive {
    param([object]$Value, [string]$Delimiter = ',')

    if ($null -eq $Value) { return 'null' }
    if ($Value -is [bool]) { return $Value.ToString().ToLower() }
    if ($Value -is [string]) {
        if (Test-QuoteString -String $Value -Delimiter $Delimiter) {
            return "`"$($Value.Replace('\', '\\').Replace('"', '\"').Replace("`n", '\n').Replace("`r", '\r').Replace("`t", '\t'))`""
        }
        else {
            return $Value
        }
    }
    if ($Value -is [double] -or $Value -is [int] -or $Value -is [long]) {
        return $Value.ToString()
    }
    return $Value.ToString()
}

function Test-QuoteString {
    param([string]$String, [string]$Delimiter)

    if ($String -eq '') { return $true }
    if ($String -match '^\s|\s$') { return $true }
    if ($String -in @('true', 'false', 'null')) { return $true }
    if ($String -match '^-|^-.*') { return $true }
    if ($String -match '[:\[\]{}' + [regex]::Escape($Delimiter) + '\n\r\t\\]') { return $true }
    if ($String -match '^0\d+$') { return $true }
    if ($String -match '^-?\d+(\.\d+)?([eE][+-]?\d+)?$') { return $true }
    return $false
}