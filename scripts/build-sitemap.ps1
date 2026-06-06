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

function Get-PageMeta([string]$filePath) {
  $html = [System.IO.File]::ReadAllText($filePath, [System.Text.Encoding]::UTF8)
  $titleMatch = [regex]::Match($html, "<title>(.*?)</title>", "Singleline")
  $descMatch = [regex]::Match($html, '<meta\s+name="description"\s+content="(.*?)"', "Singleline")

  return @{
    title = if ($titleMatch.Success) { [System.Net.WebUtility]::HtmlDecode($titleMatch.Groups[1].Value.Trim()) } else { "Feel 마사지" }
    description = if ($descMatch.Success) { [System.Net.WebUtility]::HtmlDecode($descMatch.Groups[1].Value.Trim()) } else { "서울 강북구 출장마사지 안내 페이지입니다." }
  }
}

$pages = Get-ChildItem -Path $Root -Recurse -Filter "index.html" |
  Where-Object {
    $_.FullName -notmatch "\\(work|outputs|\.git)\\"
  } |
  Sort-Object FullName

$urls = $pages |
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

$rssItems = $pages | ForEach-Object {
  $url = Convert-IndexFileToUrl $_.FullName
  $meta = Get-PageMeta $_.FullName
  @"
    <item>
      <title>$([System.Security.SecurityElement]::Escape($meta.title))</title>
      <link>$([System.Security.SecurityElement]::Escape($url))</link>
      <guid isPermaLink="true">$([System.Security.SecurityElement]::Escape($url))</guid>
      <description>$([System.Security.SecurityElement]::Escape($meta.description))</description>
      <pubDate>$((Get-Date).ToUniversalTime().ToString("r"))</pubDate>
    </item>
"@
}

$rss = @"
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <channel>
    <title>Feel Massage Gangbuk Guide</title>
    <link>$SiteUrl/</link>
    <description>Gangbuk massage area guide and booking checklist</description>
    <language>ko-KR</language>
    <lastBuildDate>$((Get-Date).ToUniversalTime().ToString("r"))</lastBuildDate>
$($rssItems -join "`n")
  </channel>
</rss>
"@

[System.IO.File]::WriteAllText((Join-Path $Root "rss.xml"), $rss, $utf8NoBom)

$robots = @"
User-agent: *
Allow: /

User-agent: Googlebot
Allow: /

User-agent: Googlebot-Image
Allow: /

User-agent: Yeti
Allow: /

User-agent: bingbot
Allow: /

Sitemap: $SiteUrl/sitemap.xml
Sitemap: $SiteUrl/rss.xml
"@

[System.IO.File]::WriteAllText((Join-Path $Root "robots.txt"), $robots, $utf8NoBom)
Write-Host "Generated sitemap.xml, rss.xml, and robots.txt for $SiteUrl"
