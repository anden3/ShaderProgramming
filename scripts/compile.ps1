$file = $args[0]

$basename = (Get-Item $file).BaseName

aqsl -o shaders/$basename.slx $file 2>&1 | ForEach-Object {
    if (($_ | Out-String).Contains($file)) {
        Write-Host $_
    }
}