param(
  [int]$Port = 4173
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")
$listener.Start()

Write-Host "Serving $root at http://localhost:$Port/"

$contentTypes = @{
  ".css" = "text/css; charset=utf-8"
  ".html" = "text/html; charset=utf-8"
  ".ico" = "image/x-icon"
  ".jpg" = "image/jpeg"
  ".jpeg" = "image/jpeg"
  ".js" = "application/javascript; charset=utf-8"
  ".json" = "application/json; charset=utf-8"
  ".pdf" = "application/pdf"
  ".png" = "image/png"
  ".svg" = "image/svg+xml"
  ".txt" = "text/plain; charset=utf-8"
}

try {
  while ($listener.IsListening) {
    $context = $listener.GetContext()
    $request = $context.Request
    $response = $context.Response

    try {
      $relativePath = [System.Uri]::UnescapeDataString($request.Url.AbsolutePath.TrimStart("/"))
      if ([string]::IsNullOrWhiteSpace($relativePath)) {
        $relativePath = "index.html"
      }

      $targetPath = Join-Path $root $relativePath

      if ((Test-Path $targetPath) -and (Get-Item $targetPath).PSIsContainer) {
        $targetPath = Join-Path $targetPath "index.html"
      }

      if (-not (Test-Path $targetPath)) {
        $response.StatusCode = 404
        $buffer = [System.Text.Encoding]::UTF8.GetBytes("404 - File not found")
        $response.ContentType = "text/plain; charset=utf-8"
        $response.OutputStream.Write($buffer, 0, $buffer.Length)
        continue
      }

      $extension = [System.IO.Path]::GetExtension($targetPath).ToLowerInvariant()
      $response.ContentType = if ($contentTypes.ContainsKey($extension)) { $contentTypes[$extension] } else { "application/octet-stream" }

      $bytes = [System.IO.File]::ReadAllBytes($targetPath)
      $response.ContentLength64 = $bytes.Length
      $response.OutputStream.Write($bytes, 0, $bytes.Length)
    } catch {
      $response.StatusCode = 500
      $buffer = [System.Text.Encoding]::UTF8.GetBytes("500 - Internal server error")
      $response.ContentType = "text/plain; charset=utf-8"
      $response.OutputStream.Write($buffer, 0, $buffer.Length)
    } finally {
      $response.OutputStream.Close()
    }
  }
} finally {
  $listener.Stop()
  $listener.Close()
}
