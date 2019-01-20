$fileName = $args[0]
$file = Get-ChildItem -Recurse -Filter "$fileName.rib" -File
$fileRelative = $file.FullName | Resolve-Path -Relative

aqsis -shaders="./shaders/:&" $fileRelative 2>&1 | ForEach-Object {
    Write-Host $_
}

$imageFile = Get-ChildItem -Recurse -Filter "*.tif" -File

[Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
$img = New-Object System.Drawing.Bitmap $imageFile.FullName
$img.Save("images/" + $imageFile.BaseName + ".png", "PNG")

# Remove-Item ($imageFile.FullName | Resolve-Path -Relative)