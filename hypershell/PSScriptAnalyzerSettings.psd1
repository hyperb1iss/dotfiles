# PSScriptAnalyzer settings for hypershell/.
#
# Runs the full default rule set minus the two exclusions below. The module
# also passes the stricter-in-practice PSGallery preset with no exclusions at
# all:
#
#     Invoke-ScriptAnalyzer -Path hypershell -Recurse -Settings PSGallery
#     Invoke-ScriptAnalyzer -Path hypershell -Recurse -Settings hypershell/PSScriptAnalyzerSettings.psd1
#
# Both come back empty. Every other finding was fixed rather than suppressed.
#
# Rule selection only, no formatting rules, and that is deliberate.
# bin/pslint.ps1 hands this same file to Invoke-Formatter, so anything added
# here becomes the repo-wide formatting standard. Adopting the CodeFormatting
# preset today rewrites sixteen tracked files (bin/pslint.ps1, install.ps1,
# setup-windows.ps1, most of the module) over indentation, brace placement,
# and assignment alignment, and its PSUseCorrectCasing rule turns every -eq
# into -EQ. That is a repo-wide decision rather than a HyperShell one, so
# `make format-ps` stays a no-op until the repo makes it: no rules, no
# rewrites, no drift.

@{
    ExcludeRules = @(
        # HyperShell is a shell environment. Coloured banners, quick reference
        # cards, and installer progress are the product, not accidental
        # debugging output, and routing them through Write-Information would
        # make them invisible by default.
        #
        # Scope note: this exclusion exists for setup-windows.ps1, which is a
        # console installer with no pipeline contract. Module functions that
        # write to the host carry their own inline
        # SuppressMessageAttribute with a per-function justification, so they
        # stay clean even under a settings file that does not exclude this.
        'PSAvoidUsingWriteHost'

        # The rule wants a BOM on any file containing non-ASCII characters,
        # which is a Windows PowerShell 5.1 decoding concern. This module
        # requires PowerShell 7.4, where UTF-8 without a BOM is the default
        # encoding for reading and writing. Adding BOMs would also fight the
        # rest of the dotfiles tooling, which is BOM-free throughout.
        'PSUseBOMForUnicodeEncodedFile'
    )
}
