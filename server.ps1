# Server Script (server.ps1)
param(
    [int]$port = 9000,
    [string]$savePath = ".\"
)

if (!(Test-Path $savePath)) {
    New-Item -ItemType Directory -Path $savePath | Out-Null
}

$listener = New-Object System.Net.Sockets.TcpListener ([System.Net.IPAddress]::Any, $port)
$listener.Start()
Write-Host "Server listening on port $port..."

while ($true) {
    $client = $listener.AcceptTcpClient()
    $stream = $client.GetStream()
    $reader = New-Object System.IO.BinaryReader($stream)
    $fileName = $reader.ReadString()
    $fileSize = $reader.ReadInt64()
    $filePath = Join-Path -Path $savePath -ChildPath $fileName

    [byte[]]$buffer = New-Object byte[] $fileSize
    $reader.Read($buffer, 0, $fileSize) | Out-Null
    [System.IO.File]::WriteAllBytes($filePath, $buffer)
    Write-Host "Received: $fileName ($fileSize bytes)"
    
    $reader.Close()
    $stream.Close()
    $client.Close()
}

$listener.Stop()