# PSToon

PowerShell module for working with [Token-Oriented Object Notation (TOON)](https://github.com/toon-format/toon) — a compact, human-readable, schema-aware JSON alternative optimized for LLM prompts.

## Overview

TOON combines YAML-like indentation for nested objects and CSV-style tabular layout for uniform arrays, minimizing tokens and improving readability for both humans and language models.

This module provides PowerShell functions to convert between TOON and PowerShell objects, making it easy to serialize and parse data for LLM workflows.

## Installation

Clone or download this repository, then import the module:

```powershell
Import-Module ./PSToon.psd1
```

## Usage

### Convert PowerShell objects to TOON

```powershell
$users = @(
		[PSCustomObject]@{id = 1; name = 'Alice'; role = 'admin'},
		[PSCustomObject]@{id = 2; name = 'Bob'; role = 'user'}
)
$toon = $users | ConvertTo-Toon
Write-Host $toon
# Output:
# [2]{id,name,role}:
#   1,Alice,admin
#   2,Bob,user
```

### Convert TOON text to PowerShell objects

```powershell
$toon = @"
users[2]{id,name,role}:
	1,Alice,admin
	2,Bob,user
"@
$obj = $toon | ConvertFrom-Toon
$obj.users[0].name  # Alice
$obj.users[1].role  # user
```

### Options

- `ConvertTo-Toon` supports `-IndentSize`, `-KeyFolding`, and `-FlattenDepth` for formatting.
- `ConvertFrom-Toon` supports `-IndentSize`, `-Strict`, `-ExpandPaths`, and `-AsPSObject` for parsing.

### Example: Key Folding

```powershell
$data = @{ data = @{ metadata = @{ items = @('a', 'b') } } }
$toon = $data | ConvertTo-Toon -KeyFolding safe
Write-Host $toon
# Output:
# data.metadata.items[2]: a,b
```

## Testing

Run the included Pester tests to validate functionality:

```powershell
Invoke-Pester ./Tests/pstoon.tests.ps1
```

## Resources

- [TOON Format Specification](https://github.com/toon-format/spec/blob/main/SPEC.md)
- [Upstream TOON Project](https://github.com/toon-format/toon)
- [Benchmarks & Examples](https://github.com/toon-format/toon#benchmarks)

## License

## License

This project is licensed under the MIT License. See the LICENSE file for details.
