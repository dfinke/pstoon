@{
    RootModule        = 'PSToon.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = '2f008afa-8232-4f1e-ab99-f7e71ff6857f'  # Generate a real GUID
    Author            = 'Doug Finke'
    Description       = 'PowerShell implementation of TOON specification'
    Copyright         = '© 2025 All rights reserved.'
    PowerShellVersion = '5.1'
    FunctionsToExport = @('ConvertTo-Toon', 'ConvertFrom-Toon')
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()

    PrivateData       = @{
        PSData = @{
            Category    = 'PowerShell Toon Conversion'
            Tags        = @('TOON', 'PowerShell', 'Serialization')
            LicenseUri  = 'https://github.com/dfinke/pstoon/blob/main/LICENSE'
            ProjectUri  = 'https://github.com/dfinke/pstoon'

        }
    }
}