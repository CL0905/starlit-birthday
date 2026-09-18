param(
  [string]$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
  [int]$MaxImageWidth = 1680,
  [int]$JpegQuality = 82,
  [string]$ConfigPath = "",
  [switch]$IncludeVideo
)

$ErrorActionPreference = "Stop"
$assetsDir = Join-Path $ProjectRoot "assets-source"
$htmlPath = Join-Path $ProjectRoot "birthday.html"
$editorPath = Join-Path $ProjectRoot "editor.html"
$outDir = Join-Path $ProjectRoot "dist"
$deployDir = Join-Path $ProjectRoot "deploy"
$outPath = Join-Path $outDir "birthday.html"
$editorOutPath = Join-Path $outDir "editor.html"
$zipPath = Join-Path $outDir "birthday-package.zip"

New-Item -ItemType Directory -Force -Path $outDir | Out-Null
New-Item -ItemType Directory -Force -Path $deployDir | Out-Null

Add-Type -AssemblyName System.Drawing

function Convert-ImageToDataUri {
  param([string]$Path)

  $img = [System.Drawing.Image]::FromFile($Path)
  try {
    $ratio = [Math]::Min(1, $MaxImageWidth / [double]$img.Width)
    $width = [Math]::Max(1, [int]($img.Width * $ratio))
    $height = [Math]::Max(1, [int]($img.Height * $ratio))
    $bmp = New-Object System.Drawing.Bitmap $width, $height
    try {
      $g = [System.Drawing.Graphics]::FromImage($bmp)
      try {
        $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
        $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $g.DrawImage($img, 0, 0, $width, $height)
      } finally {
        $g.Dispose()
      }

      $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" } | Select-Object -First 1
      $params = New-Object System.Drawing.Imaging.EncoderParameters 1
      $params.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality), ([int64]$JpegQuality)
      $ms = New-Object System.IO.MemoryStream
      try {
        $bmp.Save($ms, $codec, $params)
        return "data:image/jpeg;base64," + [Convert]::ToBase64String($ms.ToArray())
      } finally {
        $ms.Dispose()
      }
    } finally {
      $bmp.Dispose()
    }
  } finally {
    $img.Dispose()
  }
}

function Convert-BinaryToDataUri {
  param([string]$Path, [string]$Mime)
  return "data:$Mime;base64," + [Convert]::ToBase64String([IO.File]::ReadAllBytes($Path))
}

function Escape-JsString {
  param([string]$Value)
  return $Value.Replace("\", "\\").Replace('"', '\"')
}

$assets = @{}
$assetStats = @{}
$music = ""
$musicStats = $null
$warnings = New-Object System.Collections.Generic.List[string]
$imageExts = @(".jpg", ".jpeg", ".png", ".webp")
$audioExts = @(".mp3", ".m4a", ".ogg", ".wav")
$videoExts = @(".mp4", ".mov", ".webm")

Get-ChildItem -Path $assetsDir -File | ForEach-Object {
  $ext = $_.Extension.ToLowerInvariant()
  $key = [IO.Path]::GetFileNameWithoutExtension($_.Name)
  if ($_.Length -gt 8MB) {
    $warnings.Add("Large source asset: $($_.Name) is $([Math]::Round($_.Length / 1MB, 2)) MB")
  }
  if ($imageExts -contains $ext) {
    try {
      $assets[$key] = Convert-ImageToDataUri $_.FullName
      $assetStats[$key] = @{
        original_bytes = $_.Length
        embedded_bytes = [int]([Math]::Round(($assets[$key].Length - $assets[$key].IndexOf(",") - 1) * 0.75))
        output_format = "jpeg"
      }
    } catch {
      $warnings.Add("Image conversion failed for $($_.Name): $($_.Exception.Message). Embedding original bytes instead.")
      $mime = if ($ext -eq ".png") { "image/png" } elseif ($ext -eq ".webp") { "image/webp" } else { "image/jpeg" }
      $assets[$key] = Convert-BinaryToDataUri $_.FullName $mime
      $assetStats[$key] = @{
        original_bytes = $_.Length
        embedded_bytes = [int]([Math]::Round(($assets[$key].Length - $assets[$key].IndexOf(",") - 1) * 0.75))
        output_format = $mime
      }
    }
  } elseif ($audioExts -contains $ext) {
    $mime = switch ($ext) {
      ".mp3" { "audio/mpeg" }
      ".m4a" { "audio/mp4" }
      ".ogg" { "audio/ogg" }
      default { "audio/wav" }
    }
    $music = Convert-BinaryToDataUri $_.FullName $mime
    $musicStats = @{
      original_bytes = $_.Length
      embedded_bytes = [int]([Math]::Round(($music.Length - $music.IndexOf(",") - 1) * 0.75))
      output_format = $mime
    }
    if ($_.Length -gt 5MB) { $warnings.Add("Music file $($_.Name) may make the email attachment large.") }
  } elseif ($videoExts -contains $ext) {
    if ($IncludeVideo) {
      $warnings.Add("Video $($_.Name) was detected. birthday.html does not include a video slot by default; add one intentionally before embedding.")
    } else {
      $warnings.Add("Skipped video $($_.Name). Use -IncludeVideo only after accepting a much larger HTML attachment.")
    }
  }
}

$html = Get-Content -LiteralPath $htmlPath -Raw -Encoding UTF8
if ($ConfigPath) {
  $resolvedConfig = Resolve-Path -LiteralPath $ConfigPath
  $configJson = Get-Content -LiteralPath $resolvedConfig -Raw -Encoding UTF8
  $html = [Regex]::Replace($html, 'const CONFIG = loadEmbeddedConfig\(\s*/\*__CONFIG__\*/[\s\S]*?\);\s*const CHAPTERS', "const CONFIG = loadEmbeddedConfig(/*__CONFIG__*/$configJson,false);`n  const CHAPTERS", 1)
}
foreach ($entry in $assets.GetEnumerator()) {
  $pattern = '("' + [Regex]::Escape($entry.Key) + '"\s*:\s*")[^"]*(")'
  $replacement = '${1}' + (Escape-JsString $entry.Value) + '${2}'
  $html = [Regex]::Replace($html, $pattern, $replacement, 1)
}
if ($music) {
  $replacement = '${1}' + (Escape-JsString $music) + '${2}'
  $html = [Regex]::Replace($html, '(music\s*:\s*")[^"]*(")', $replacement, 1)
}

$runtimeHtml = $html.Replace("/*__CONFIG__*/", "")
Set-Content -LiteralPath $outPath -Value $runtimeHtml -Encoding UTF8
Copy-Item -LiteralPath $outPath -Destination (Join-Path $deployDir "index.html") -Force
Copy-Item -LiteralPath $outPath -Destination (Join-Path $deployDir "birthday.html") -Force
Copy-Item -LiteralPath $outPath -Destination (Join-Path $deployDir "404.html") -Force
Set-Content -LiteralPath (Join-Path $deployDir ".nojekyll") -Value "" -Encoding UTF8
Set-Content -LiteralPath (Join-Path $deployDir "robots.txt") -Value "User-agent: *`nDisallow: /`n" -Encoding UTF8
if (Test-Path -LiteralPath $editorPath) {
  $editorHtml = Get-Content -LiteralPath $editorPath -Raw -Encoding UTF8
  $templateBytes = [Text.Encoding]::UTF8.GetBytes($html)
  $templateBase64 = [Convert]::ToBase64String($templateBytes)
  $editorHtml = [Regex]::Replace($editorHtml, 'const TEMPLATE_BASE64="__BIRTHDAY_TEMPLATE_BASE64__";', 'const TEMPLATE_BASE64="' + $templateBase64 + '";', 1)
  Set-Content -LiteralPath $editorOutPath -Value $editorHtml -Encoding UTF8
  Copy-Item -LiteralPath $editorOutPath -Destination (Join-Path $deployDir "editor.html") -Force
}
$emailPath = Join-Path $ProjectRoot "email.html"
if (Test-Path -LiteralPath $emailPath) {
  Copy-Item -LiteralPath $emailPath -Destination (Join-Path $deployDir "email.html") -Force
}
$sizeMb = [Math]::Round((Get-Item -LiteralPath $outPath).Length / 1MB, 2)
$stats = @{
  built_at = (Get-Date).ToString("s")
  final_html_bytes = (Get-Item -LiteralPath $outPath).Length
  assets = $assetStats
  music = $musicStats
  warnings = @($warnings)
}
$statsPath = Join-Path $outDir "asset-stats.json"
$stats | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $statsPath -Encoding UTF8

if (Test-Path -LiteralPath $zipPath) { Remove-Item -LiteralPath $zipPath -Force }
$zipItems = @($outPath, $editorOutPath, $deployDir, (Join-Path $ProjectRoot "email.html"), (Join-Path $ProjectRoot "README.md"))
$qaPath = Join-Path $ProjectRoot "QA-REPORT.md"
if (Test-Path -LiteralPath $qaPath) { $zipItems += $qaPath }
$deployReportPath = Join-Path $ProjectRoot "DEPLOYMENT-REPORT.md"
if (Test-Path -LiteralPath $deployReportPath) { $zipItems += $deployReportPath }
$workflowPath = Join-Path $ProjectRoot ".github\workflows\deploy-pages.yml"
if (Test-Path -LiteralPath $workflowPath) { $zipItems += $workflowPath }
Compress-Archive -LiteralPath $zipItems -DestinationPath $zipPath -Force

Write-Host "Built: $outPath"
if (Test-Path -LiteralPath $editorOutPath) {
  Write-Host "Copied editor: $editorOutPath"
}
Write-Host "Stats: $statsPath"
Write-Host "ZIP: $zipPath"
Write-Host "Final birthday.html size: $sizeMb MB"
if ($sizeMb -gt 18) {
  $warnings.Add("Final HTML is larger than 18 MB. Gmail may reject or make this awkward as an attachment.")
}
if ($warnings.Count -gt 0) {
  Write-Host ""
  Write-Host "Warnings:"
  $warnings | ForEach-Object { Write-Host "- $_" }
}
