function Convert-ToonValue {
    param([object]$Value)

    if ($Value -is [System.Collections.IDictionary]) {
        $normalized = [ordered]@{}
        foreach ($key in $Value.Keys) {
            $normalized[$key] = Convert-ToonValue -Value $Value[$key]
        }
        return $normalized
    }
    elseif ($Value -is [System.Collections.IList]) {
        $normalized = @()
        foreach ($item in $Value) {
            $normalized += Convert-ToonValue -Value $item
        }
        return $normalized
    }
    elseif ($Value -is [PSCustomObject]) {
        $normalized = [ordered]@{}
        foreach ($prop in $Value.PSObject.Properties) {
            $normalized[$prop.Name] = Convert-ToonValue -Value $prop.Value
        }
        return $normalized
    }
    elseif ($Value -is [double] -or $Value -is [float]) {
        if ([double]::IsNaN($Value) -or [double]::IsInfinity($Value)) {
            return $null
        }
        # Canonical form: decimal without exponent
        return [double]$Value
    }
    elseif ($Value -is [int] -or $Value -is [long] -or $Value -is [decimal]) {
        return $Value
    }
    elseif ($Value -is [bool]) {
        return $Value
    }
    elseif ($null -eq $Value) {
        return $null
    }
    elseif ($Value -is [string]) {
        return $Value
    }
    elseif ($Value -is [DateTime]) {
        return $Value.ToString('o')  # ISO 8601
    }
    else {
        # Other types, convert to string
        return $Value.ToString()
    }
}