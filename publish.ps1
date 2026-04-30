param(
  [Parameter(Mandatory = $true)]
  [string]$Source,
  [string]$AttachmentsDir,
  [string]$AssetsSubdir = "assets/img",
  [string]$Date = (Get-Date -Format "yyyy-MM-dd"),
  [string]$Title,
  [string]$Slug,
  [string[]]$Tags,
  [string[]]$Categories
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Normalize-Text([string]$text) {
  if ($null -eq $text) { return "" }
  return $text.Trim().ToLowerInvariant()
}

function Get-FrontMatter([string]$content) {
  $m = [regex]::Match($content, "^\s*---\s*\r?\n([\s\S]*?)\r?\n---\s*\r?\n")
  if (-not $m.Success) {
    return @{
      Yaml = $null
      Body = $content
      Data = @{}
    }
  }

  $yamlText = $m.Groups[1].Value
  $body = $content.Substring($m.Length)
  $data = @{}

  $lines = $yamlText -split "\r?\n"
  $i = 0
  while ($i -lt $lines.Count) {
    $line = $lines[$i]
    if ($line -match "^\s*([A-Za-z0-9_]+)\s*:\s*(.*)\s*$") {
      $key = $Matches[1]
      $value = $Matches[2]
      if ($value -match "^\[(.*)\]\s*$") {
        $items = $Matches[1] -split "," | ForEach-Object { $_.Trim().Trim('"').Trim("'") } | Where-Object { $_ -ne "" }
        $data[$key] = @($items)
      } elseif ($value -eq "") {
        $items = @()
        $j = $i + 1
        while ($j -lt $lines.Count -and $lines[$j] -match "^\s*-\s*(.+?)\s*$") {
          $items += $Matches[1].Trim().Trim('"').Trim("'")
          $j++
        }
        if ($items.Count -gt 0) {
          $data[$key] = @($items)
          $i = $j - 1
        } else {
          $data[$key] = ""
        }
      } else {
        $data[$key] = $value.Trim().Trim('"').Trim("'")
      }
    }
    $i++
  }

  return @{
    Yaml = $yamlText
    Body = $body
    Data = $data
  }
}

function Slugify([string]$text) {
  $t = ("" + $text).Trim()
  $t = $t -replace "[\s_]+", "-"
  $t = $t -replace "[^\p{L}\p{N}\-]+", "-"
  $t = $t -replace "-{2,}", "-"
  $t = $t.Trim("-")
  if ($t -eq "") { $t = "post" }
  return $t
}

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$postsDir = Join-Path $repoRoot "_posts"
if (-not (Test-Path $postsDir)) {
  throw "Cannot find _posts directory: $postsDir"
}

$sourcePath = (Resolve-Path $Source).Path
$raw = [System.IO.File]::ReadAllText($sourcePath, (New-Object System.Text.UTF8Encoding($true)))

$fm = Get-FrontMatter $raw
$body = $fm.Body
$data = $fm.Data

if (-not $Title) {
  if ($data.ContainsKey("title") -and ([string]$data["title"]).Trim() -ne "") {
    $Title = [string]$data["title"]
  } else {
    $mTitle = [regex]::Match($body, "(?m)^\s*#\s+(.+?)\s*$")
    if ($mTitle.Success) {
      $Title = $mTitle.Groups[1].Value.Trim()
    } else {
      $Title = [System.IO.Path]::GetFileNameWithoutExtension($sourcePath)
    }
  }
}

if ($data.ContainsKey("date") -and ([string]$data["date"]).Trim() -ne "") {
  $Date = [string]$data["date"]
}

$dateOnly = $Date
try {
  $dt = [datetime]::Parse($Date)
  $dateOnly = $dt.ToString("yyyy-MM-dd")
} catch {
  if ($Date -match "^\d{4}-\d{2}-\d{2}") {
    $dateOnly = $Matches[0]
  }
}

if (-not $Slug) {
  $Slug = Slugify $Title
}

$inlineTags = New-Object System.Collections.Generic.HashSet[string]
foreach ($m in [regex]::Matches($body, "(?<![\p{L}\p{N}_/])#([\p{L}\p{N}_-]+)")) {
  $tag = $m.Groups[1].Value.Trim()
  if ($tag -ne "") { [void]$inlineTags.Add($tag) }
}

$allTags = New-Object System.Collections.Generic.HashSet[string]
foreach ($t in @($Tags)) { if ($t) { [void]$allTags.Add($t.Trim()) } }
if ($data.ContainsKey("tags")) {
  foreach ($t in @($data["tags"])) { if ($t) { [void]$allTags.Add(([string]$t).Trim()) } }
}
foreach ($t in $inlineTags) { [void]$allTags.Add($t) }

$allCategories = New-Object System.Collections.Generic.HashSet[string]
foreach ($c in @($Categories)) { if ($c) { [void]$allCategories.Add($c.Trim()) } }
if ($data.ContainsKey("categories")) {
  foreach ($c in @($data["categories"])) { if ($c) { [void]$allCategories.Add(([string]$c).Trim()) } }
}

$postsBySlug = @{}
$postsByTitle = @{}
Get-ChildItem $postsDir -Filter "*.md" | ForEach-Object {
  $file = $_.FullName
  $name = $_.BaseName
  if ($name -match "^(\d{4})-(\d{2})-(\d{2})-(.+)$") {
    $y = $Matches[1]
    $m = $Matches[2]
    $d = $Matches[3]
    $s = $Matches[4]
    $url = "/$y/$m/$d/$s/"
    $postsBySlug[(Normalize-Text $s)] = $url
    $text = [System.IO.File]::ReadAllText($file, (New-Object System.Text.UTF8Encoding($true)))
    $fm2 = Get-FrontMatter $text
    if ($fm2.Data.ContainsKey("title")) {
      $t = [string]$fm2.Data["title"]
      if ($t.Trim() -ne "") {
        $postsByTitle[(Normalize-Text $t)] = $url
      }
    }
  }
}

function Resolve-WikilinkUrl([string]$target) {
  $t = ("" + $target).Trim()
  if ($t -match "\.md$") { $t = $t.Substring(0, $t.Length - 3) }
  $t = ($t -split "#")[0].Trim()
  $k = Normalize-Text $t
  if ($postsBySlug.ContainsKey($k)) { return $postsBySlug[$k] }
  if ($postsByTitle.ContainsKey($k)) { return $postsByTitle[$k] }
  return $null
}

$unresolved = New-Object System.Collections.Generic.HashSet[string]
$copiedImages = New-Object System.Collections.Generic.List[string]

$assetsDir = Join-Path $repoRoot $AssetsSubdir
function Ensure-AssetsDir() {
  if (-not (Test-Path $assetsDir)) {
    New-Item -ItemType Directory -Force -Path $assetsDir | Out-Null
  }
}

$sourceDir = Split-Path -Parent $sourcePath

$body = [regex]::Replace($body, "!\[\[([^\]\|]+?)(\|([^\]]+))?\]\]", {
  param($match)
  $fileName = $match.Groups[1].Value.Trim()
  $alt = $match.Groups[3].Value.Trim()
  if ($alt -eq "") { $alt = [System.IO.Path]::GetFileNameWithoutExtension($fileName) }

  $candidates = @()
  if ($AttachmentsDir) { $candidates += (Join-Path $AttachmentsDir $fileName) }
  $candidates += (Join-Path $sourceDir $fileName)

  $found = $null
  foreach ($p in $candidates) {
    if (Test-Path $p) { $found = (Resolve-Path $p).Path; break }
  }

  if (-not $found -and $AttachmentsDir) {
    $leaf = [System.IO.Path]::GetFileName($fileName)
    $hit = Get-ChildItem $AttachmentsDir -File -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq $leaf } | Select-Object -First 1
    if ($hit) { $found = $hit.FullName }
  }

  if (-not $found) {
    return "![$alt]($fileName)"
  }

  Ensure-AssetsDir
  $destName = [System.IO.Path]::GetFileName($found)
  $destPath = Join-Path $assetsDir $destName
  if (Test-Path $destPath) {
    $destName = "$dateOnly-$Slug-$destName"
    $destPath = Join-Path $assetsDir $destName
  }
  Copy-Item -Force $found $destPath
  $copiedImages.Add($destName) | Out-Null

  $encodedDestName = [System.Uri]::EscapeDataString($destName)
  $publicPath = ("/" + ($AssetsSubdir -replace "\\", "/").Trim("/") + "/" + $encodedDestName)
  return "![$alt]($publicPath)"
})

$body = [regex]::Replace($body, "\[\[([^\]\|]+?)(\|([^\]]+))?\]\]", {
  param($match)
  $target = $match.Groups[1].Value.Trim()
  $alias = $match.Groups[3].Value.Trim()
  if ($alias -eq "") { $alias = ($target -split "#")[0].Trim() }

  $url = Resolve-WikilinkUrl $target
  if ($null -ne $url) {
    return "[$alias]($url)"
  }

  if ($target -ne "") { [void]$unresolved.Add($target) }
  return $alias
})

$yamlLines = New-Object System.Collections.Generic.List[string]
$yamlLines.Add("---") | Out-Null
$yamlLines.Add("layout: post") | Out-Null
$yamlLines.Add(("title: ""{0}""" -f ($Title.Replace("""", "''")))) | Out-Null
$yamlLines.Add(("date: {0} 09:00:00 +0800" -f $dateOnly)) | Out-Null

if ($allCategories.Count -gt 0) {
  $cats = ($allCategories | Sort-Object)
  $yamlLines.Add("categories:") | Out-Null
  foreach ($c in $cats) { $yamlLines.Add(("  - ""{0}""" -f ($c.Replace("""", "''")))) | Out-Null }
}

if ($allTags.Count -gt 0) {
  $ts = ($allTags | Sort-Object)
  $yamlLines.Add("tags:") | Out-Null
  foreach ($t in $ts) { $yamlLines.Add(("  - ""{0}""" -f ($t.Replace("""", "''")))) | Out-Null }
}

$yamlLines.Add("---") | Out-Null

$outFile = Join-Path $postsDir ("{0}-{1}.md" -f $dateOnly, $Slug)
$output = ($yamlLines -join "`n") + "`n`n" + $body.Trim() + "`n"
[System.IO.File]::WriteAllText($outFile, $output, (New-Object System.Text.UTF8Encoding($false)))

Write-Host ('Generated post: {0}' -f $outFile)
if ($copiedImages.Count -gt 0) {
  Write-Host ('Copied images: {0}' -f ($copiedImages.Count))
}
if ($unresolved.Count -gt 0) {
  Write-Host 'Unresolved [[links]] (no matching published posts found):'
  foreach ($u in ($unresolved | Sort-Object)) { Write-Host ('- {0}' -f $u) }
}
