class Paths {
    static [string[]]FindAnyPathInHome([string]$Pattern){
        # $Root = Get-Location;
        $Root = "~/"
        $MatchedPaths = Get-ChildItem -Path $Root -Recurse -Directory -ErrorAction SilentlyContinue | ?{$_.FullName -like "*$Pattern*"};
        if($MatchedPaths){return $MatchedPaths.FullName;}else{Write-Warning "Unable to find path with pattern '$($Pattern)'";return "N/A";}
    }

    static [string[]]FindRootPathInHome([string]$Pattern){
        # $Root = Get-Location;
        $Root = "~/"
        $MatchedPaths = Get-ChildItem -Path $Root -Recurse -Directory -ErrorAction SilentlyContinue | ?{$_.FullName -like "*$Pattern"};
        if($MatchedPaths){return $MatchedPaths.FullName;}else{Write-Warning "Unable to find path with pattern '$($Pattern)'";return "N/A";}
    }
}