param([string]$ExpectedOwner = 'hidewood')

$ErrorActionPreference = 'Stop'
Set-Location (Split-Path -Parent $PSScriptRoot)

function Assert-LastCommand([string]$Message) {
    if ($LASTEXITCODE -ne 0) { throw $Message }
}

gh auth status --hostname github.com
Assert-LastCommand 'GitHub login is unavailable. Run gh auth login --hostname github.com --git-protocol https --web --scopes workflow first.'
$taskOwner = gh api user --jq '.login'
Assert-LastCommand 'Could not determine GitHub account.'
if ($taskOwner -ne $ExpectedOwner) { throw "Expected $ExpectedOwner, but logged in as $taskOwner." }

$taskRepoName = "$taskOwner.github.io"
$taskFullName = "$taskOwner/$taskRepoName"
$taskReposJson = gh repo list $taskOwner --limit 1000 --json name
Assert-LastCommand 'Could not inspect existing repositories.'
$taskRepos = $taskReposJson | ConvertFrom-Json
if ($taskRepos.name -contains $taskRepoName) {
    throw "$taskFullName already exists. Stop here and inspect it before publishing; no existing repository will be overwritten."
}
$taskRemotes = git remote
Assert-LastCommand 'Could not inspect local Git remotes.'
if ($taskRemotes -contains 'origin') { throw 'An origin remote already exists; inspect it before publishing.' }

$taskHugo = Join-Path (Get-Location) '.tools/hugo/hugo.exe'
if (-not (Test-Path -LiteralPath $taskHugo)) { $taskHugo = 'hugo' }
& $taskHugo --minify
Assert-LastCommand 'Hugo build failed.'

git add .
Assert-LastCommand 'Could not stage source files.'
$taskStatus = git status --porcelain
if ($taskStatus) {
    git commit -m 'Prepare technical blog for GitHub Pages'
    Assert-LastCommand 'Could not commit source files; check Git author configuration.'
}

gh auth setup-git --hostname github.com
Assert-LastCommand 'Could not configure Git authentication.'
gh repo create $taskFullName --public --source . --remote origin
Assert-LastCommand 'Could not create the public repository.'
git push -u origin main
Assert-LastCommand 'Could not push source files.'
try {
    gh api "repos/$taskFullName/pages" --silent 2>$null
    $taskPagesExist = ($LASTEXITCODE -eq 0)
} catch {
    $taskPagesExist = $false
}
if ($taskPagesExist) {
    gh api --method PUT "repos/$taskFullName/pages" -f build_type=workflow --silent
} else {
    gh api --method POST "repos/$taskFullName/pages" -f build_type=workflow --silent
}
Assert-LastCommand 'Source was pushed, but Pages setup failed. Inspect Settings > Pages before continuing.'
gh workflow run hugo.yaml --ref main
Assert-LastCommand 'Pages is configured. Check Actions and start Publish blog if needed.'
Write-Host "Deployment started. Inspect https://github.com/$taskFullName/actions"
Write-Host "Expected site address: https://$taskRepoName/"
