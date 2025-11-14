Import-Module $PSScriptRoot\..\PSToon.psd1

Describe 'ConvertTo-Toon' {
    It 'Converts a hashtable to TOON' {
        $obj = @{name = 'Alice'; age = 30 }
        $result = $obj | ConvertTo-Toon
        $expected1 = "age: 30`nname: Alice"
        $expected2 = "name: Alice`nage: 30"
        ($result -eq $expected1 -or $result -eq $expected2) | Should -Be $true
    }

    It 'Converts an array of objects to tabular TOON' {
        $array = @(
            @{id = 1; name = 'Alice' },
            @{id = 2; name = 'Bob' }
        )
        $result = $array | ConvertTo-Toon
        $result | Should -Match '\[2\]\{id,name}:'
    }

    It 'Handles primitives' {
        $value = 'hello'
        $result = $value | ConvertTo-Toon
        $result | Should -Be 'hello'
    }
}

Describe 'ConvertFrom-Toon' {
    It 'Converts TOON to hashtable' {
        $toon = "name: Alice`nage: 30"
        $result = $toon | ConvertFrom-Toon
        $result.name | Should -Be 'Alice'
        $result.age | Should -Be 30
    }

    It 'Converts TOON to hashtable as PSObject' {
        $toon = "name: Alice`nage: 30"
        $result = $toon | ConvertFrom-Toon -AsPSObject
        $result.name | Should -Be 'Alice'
        $result.age | Should -Be 30
        $result | Should -BeOfType [pscustomobject]
    }

    It 'Converts tabular TOON to array' {
        $toon = "[2]{id,name}:`n1,Alice`n2,Bob"
        $result = $toon | ConvertFrom-Toon
        $result.Count | Should -Be 2
        $result[0].name | Should -Be 'Alice'
    }

    It 'Converts tabular TOON to array as PSObject' {
        $toon = "[2]{id,name}:`n1,Alice`n2,Bob"
        $result = $toon | ConvertFrom-Toon -AsPSObject
        $result.Count | Should -Be 2
        $result[0].name | Should -Be 'Alice'
        $result | Should -BeOfType [pscustomobject]
    }
}
$modulePath = Join-Path -Path $PSScriptRoot -ChildPath "..\PSToon.psm1"
Import-Module (Resolve-Path $modulePath)

Describe 'ConvertTo-Toon' {
    It 'Encodes array of objects as tabular' {
        $users = @(
            [PSCustomObject]@{id = 1; name = 'Alice'; role = 'admin' },
            [PSCustomObject]@{id = 2; name = 'Bob'; role = 'user' }
        )
        $out = $users | ConvertTo-Toon | Out-String
        $out | Should -Match '\[2\]' -Because 'matches header'
        $out | Should -Match 'Alice' -Because 'Row values present'
    }

    It 'Encodes a hashtable' {
        $obj = @{name = 'Ada'; id = 123 }
        $out = $obj | ConvertTo-Toon | Out-String
        $out | Should -Match 'name: Ada'
        $out | Should -Match 'id: 123'
    }
}

Describe 'ConvertFrom-Toon' {
    It 'Parses tabular' {
        $toon = @"
users[2]{id,name,role}:
  1,Alice,admin
  2,Bob,user
"@ -split "`n"
        $obj = $toon | ConvertFrom-Toon
        $obj.users | Should -BeOfType 'System.Object'
        $obj.users.Count | Should -Be 2
    }
}
