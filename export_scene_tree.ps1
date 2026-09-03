$out = @()

Get-ChildItem -Recurse -Filter *.tscn |
Where-Object { $_.FullName -notmatch '\\.godot\\' } |
ForEach-Object {
    $out += ""
    $out += "===================================="
    $out += "SCENE: $($_.Name)"
    $out += "===================================="

    Get-Content $_.FullName |
    Where-Object { $_ -match '^\[node ' } |
    ForEach-Object {
        if ($_ -match 'name="([^"]+)"' ) { $name = $matches[1] } else { $name = "?" }
        if ($_ -match 'type="([^"]+)"' ) { $type = $matches[2] } else { $type = "Unknown" }
        if ($_ -match 'parent="([^"]+)"') { $parent = $matches[1] } else { $parent = $null }

        if ($null -eq $parent) {
            # Nodo root: nessun parent nel tag
            $out += "$name ($type)"
        }
        elseif ($parent -eq ".") {
            # Figlio diretto del root
            $out += "* $name ($type)"
        }
        else {
            # Profondità = numero di segmenti nel path del parent + 1
            $depth = ($parent -split "/").Count + 1
            $indent = "   " * $depth
            $out += "$indent* $name ($type)"
        }
    }
}

$out | Out-File Export\scene_tree.txt -Encoding utf8