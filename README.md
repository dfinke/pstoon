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

## How This Module Was Built (Maximum Transparency)

Total human-written lines of code: **< 15**  
Total time from “hey, TOON looks useful” to fully working module with tests: **under 1 hour**

Process:
1. Opened the [TOON spec](https://github.com/toon-format/spec/blob/main/SPEC.md) in VS Code  
2. Told GitHub Copilot + Claude 3.5 Sonnet: “Write a complete, idiomatic PowerShell module that round-trips TOON ↔ PS objects. Include Pester tests. Go.”  
3. Ran the tests, found a few edge-case bugs, threw the errors back at the model → instant fixes  
4. One final manual tweak for style, commit, push  

~99 % AI-generated, 100 % tested and shipped by a human who mostly just typed prompts and drank coffee.

This is now my default module-creation speedrun. Expect many more to drop exactly like this.

Curious about the prompts or want to see the full Copilot/Claude chat? DM me @dfinke – happy to open-source the workflow too.

#AIAssisted #OneHourModule #PowerShell

## License

This project is licensed under the MIT License. See the LICENSE file for details.
