Function Move-EBFile{
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory)][string] $SourcePath,
    [Parameter(Mandatory)][string] $DestinationPath,
    [Parameter][bool] $DeleteSource
)

Try{
    Get-ChildItem -Path $SourcePath -Recurse | ForEach-Object {
        Write-Verbose -Message 'Replacing source path with destination path'
        $DestinationFile = $_.FullName -replace [regex]::Escape($SourcePath),$DestinationPath
        $SourceFile = $_.FullName
        Try {
            Copy-Item -Path $SourceFile -Destination $DestinationFile
        } Catch {
            Write-Error -Message "File Copy not able to be completed."  
        }
        IF((Get-Childitem -Path $DestinationFile).Name -eq (Split-Path -Path $SourceFile -Leaf)){
            Try {
                $FileHashTable = $null
                $FileHashTable = [Ordered]@{"SourceFile" = $SourceFile; 
                    "SourceHash"                    = (Get-FileHash -Path $SourceFile -Algorithm MD5).Hash; 
                    "DestinationFile"               = $DestinationFile; 
                    "DestinationHash"               = (Get-FileHash -Path $DestinationFile -Algorithm MD5).Hash 
                }
                IF ($FileHashTable.SourceHash -ne $FileHashTable.DestinationHash) {
                    $FIlehashTable.Add("Result", $false)
                }
                Else {
                    $FilehashTable.Add("Result", $true)
                }
            } Catch{
                Write-Error -Message "File Hash not able to be completed."
             }

         }
         IF($FileHashTable.Result){
             Write-Verbose "File copy completed and hash matches the source."
             Write-Output  $FileHashTable
             If($DeleteSource){
                 Remove-Item -Path $SourceFile
             }
         } Else {
             Write-Verbose "File copy hash does not match the source."
             Write-Output $FileHashTable
         }
    }
} Catch {
    Write-Verbose -Message 'Copy item script issue.'
}
}