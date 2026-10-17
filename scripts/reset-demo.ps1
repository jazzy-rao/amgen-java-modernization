# Reset the demo project to the protected Git baseline (tag: demo-baseline).
#
# Restores: pom.xml, src/   Also resets: demo/results.js (from template), target/
# Never touches: .git, README.md, DEMO_GUIDE.md, demo/index.html, scripts/, or anything outside this folder.
# Never commits, never runs Maven/Bob, never triggers a migration.
$ErrorActionPreference = 'Stop'

$BaselineTag  = 'demo-baseline'
$RestorePaths = @('pom.xml', 'src')

$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
Set-Location $Root

if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw 'git is required.' }
$Top = (git rev-parse --show-toplevel 2>$null)
if (-not $Top -or ((Resolve-Path $Top).Path -ne $Root)) { throw "$Root is not the root of its own Git repository. Aborting." }
git rev-parse -q --verify "refs/tags/$BaselineTag" *> $null
if ($LASTEXITCODE -ne 0) { throw "Baseline tag '$BaselineTag' not found. Nothing was changed." }
if (-not (Test-Path 'demo/results.template.js')) { throw 'demo/results.template.js missing. Aborting.' }

Write-Host 'Demo reset'
Write-Host "  Project : $Root"
Write-Host "  Baseline: tag '$BaselineTag'"
Write-Host ''

$Changed   = @(git diff --name-status $BaselineTag -- $RestorePaths)
$Untracked = @(git ls-files --others --exclude-standard -- $RestorePaths)
$ResultsEdited = (Test-Path 'demo/results.js') -and `
  ((Get-FileHash 'demo/results.js').Hash -ne (Get-FileHash 'demo/results.template.js').Hash)

if ($Changed.Count -or $Untracked.Count -or $ResultsEdited) {
  Write-Host 'These files differ from the baseline and WILL BE OVERWRITTEN OR DELETED:'
  $Changed   | ForEach-Object { Write-Host "  $_" }
  $Untracked | ForEach-Object { Write-Host "  ?  (untracked, will be deleted) $_" }
  if ($ResultsEdited) { Write-Host '  M  demo/results.js (recorded demo results will be cleared)' }
  Write-Host ''
  $answer = Read-Host "Type 'reset' to continue, anything else cancels"
  if ($answer -ne 'reset') { Write-Host 'Cancelled. Nothing was changed.'; exit 1 }
} else {
  Write-Host 'Project already matches the baseline. Refreshing results and build output only.'
}

git restore --source=$BaselineTag --staged --worktree -- $RestorePaths
git clean -fdq -- $RestorePaths
Copy-Item 'demo/results.template.js' 'demo/results.js' -Force
if ((Test-Path 'target') -and -not ((Get-Item 'target').Attributes -band [IO.FileAttributes]::ReparsePoint)) {
  Remove-Item -Recurse -Force (Join-Path $Root 'target')
}

Write-Host ''
Write-Host 'Reset complete. Next: mvn clean verify   (see DEMO_GUIDE.md)'
