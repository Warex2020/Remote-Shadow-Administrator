$code = Get-Content RSA_1.4.ps1 -Raw

$lines = $code.Split("`n")
for ($i=0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match "[\p{IsCyrillic}]") {
        Write-Output "Line $($i+1): $($lines[$i] | Select-String "[\p{IsCyrillic}]+")"
    }
}