param(
  [string]$SiteUrl = $env:SITE_URL,
  [string[]]$Url = @(),
  [switch]$All,
  [string]$Endpoint = "https://api.indexnow.org/indexnow"
)

$ErrorActionPreference = "Stop"

$Key = "87041de259bd4e94b8b60c79ddc77956"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

if (-not $SiteUrl) {
  throw "SITE_URL is required. Example: `$env:SITE_URL='https://example.com'; ./scripts/submit-indexnow.ps1 -All"
}

$SiteUrl = $SiteUrl.TrimEnd("/")
$hostName = ([uri]$SiteUrl).Host

function Convert-IndexFileToUrl([string]$filePath) {
  $relative = Resolve-Path -LiteralPath $filePath | ForEach-Object {
    $_.Path.Substring($Root.Length).TrimStart("\").Replace("\", "/")
  }

  if ($relative -eq "index.html") {
    return "$SiteUrl/"
  }

  $path = $relative -replace "/index\.html$", "/"
  return "$SiteUrl/$path"
}

if ($All) {
  $Url = Get-ChildItem -Path $Root -Recurse -Filter "index.html" |
    Where-Object {
      $_.FullName -notmatch "\\(work|outputs|\.git)\\"
    } |
    ForEach-Object { Convert-IndexFileToUrl $_.FullName }
}

if (-not $Url -or $Url.Count -eq 0) {
  throw "No URLs to submit. Pass -All or provide -Url."
}

$Url = $Url |
  ForEach-Object {
    if ($_ -match "^https?://") { $_ } else { "$SiteUrl/$($_.TrimStart('/'))" }
  } |
  Select-Object -Unique

$payload = @{
  host = $hostName
  key = $Key
  keyLocation = "$SiteUrl/$Key.txt"
  urlList = @($Url)
} | ConvertTo-Json -Depth 4

Write-Host "Submitting $($Url.Count) URL(s) to $Endpoint"
Invoke-RestMethod -Uri $Endpoint -Method Post -ContentType "application/json; charset=utf-8" -Body $payload
Write-Host "IndexNow submission completed."
