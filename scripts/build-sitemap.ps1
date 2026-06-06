param(
  [string]$SiteUrl = $env:SITE_URL
)

$ErrorActionPreference = "Stop"

if (-not $SiteUrl) {
  throw "SITE_URL is required. Example: `$env:SITE_URL='https://example.com'; ./scripts/build-sitemap.ps1"
}

$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$SiteUrl = $SiteUrl.TrimEnd("/")
$today = (Get-Date).ToString("yyyy-MM-dd")
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

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

$urls = Get-ChildItem -Path $Root -Recurse -Filter "index.html" |
  Where-Object {
    $_.FullName -notmatch "\\(work|outputs|\.git)\\"
  } |
  ForEach-Object { Convert-IndexFileToUrl $_.FullName } |
  Select-Object -Unique

$items = $urls | ForEach-Object {
  "  <url><loc>$([System.Security.SecurityElement]::Escape($_))</loc><lastmod>$today</lastmod><changefreq>weekly</changefreq><priority>0.8</priority></url>"
}

$sitemap = @"
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
$($items -join "`n")
</urlset>
"@

[System.IO.File]::WriteAllText((Join-Path $Root "sitemap.xml"), $sitemap, $utf8NoBom)

$robots = @"
User-agent: *
Allow: /

Sitemap: $SiteUrl/sitemap.xml
"@

[System.IO.File]::WriteAllText((Join-Path $Root "robots.txt"), $robots, $utf8NoBom)
Write-Host "Generated sitemap.xml and robots.txt for $SiteUrl"
