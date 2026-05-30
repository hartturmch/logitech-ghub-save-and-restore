[CmdletBinding()]
param(
    [ValidateSet('Menu', 'Backup', 'Restore', 'List')]
    [string]$Action = 'Menu',

    [string]$BackupRoot,

    [string]$BackupPath,

    [switch]$IncludeProgramData,

    [switch]$NoStopProcesses,

    [switch]$NoRestart,

    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$BackupFolderPrefix = 'GHubConfig-Backup'
$SafetyFolderPrefix = 'GHubConfig-PreRestore'
$script:UiLanguage = 'pt'
$script:LanguageOptions = @(
    [pscustomobject]@{ Number = '1'; Code = 'pt'; Label = 'Portugues' },
    [pscustomobject]@{ Number = '2'; Code = 'en'; Label = 'English' },
    [pscustomobject]@{ Number = '3'; Code = 'es'; Label = 'Espanol' },
    [pscustomobject]@{ Number = '4'; Code = 'de'; Label = 'Deutsch' },
    [pscustomobject]@{ Number = '5'; Code = 'fr'; Label = 'Francais' },
    [pscustomobject]@{ Number = '6'; Code = 'it'; Label = 'Italiano' },
    [pscustomobject]@{ Number = '7'; Code = 'ja'; Label = 'Japanese' },
    [pscustomobject]@{ Number = '8'; Code = 'zh'; Label = 'Chinese' },
    [pscustomobject]@{ Number = '9'; Code = 'hi'; Label = 'Hindi' },
    [pscustomobject]@{ Number = '10'; Code = 'ar'; Label = 'Arabic' },
    [pscustomobject]@{ Number = '11'; Code = 'ru'; Label = 'Russian' }
)
$script:UiText = @{
    en = @{
        LanguageTitle = 'Choose language'
        MainTitle = 'Logitech G HUB Backup/Restore'
        Main1 = 'Create backup'
        Main2 = 'Restore latest backup'
        Main3 = 'Choose backup to restore'
        Main4 = 'List backups'
        Main5 = 'Manage/delete backups'
        Main6 = 'Create backup including ProgramData (useful before formatting the PC and reinstalling the program)'
        Exit = 'Exit'
        Back = 'Back'
        Option = 'Option'
        InvalidOption = 'Invalid option. Use: {0}'
        InvalidOptionRange = 'Invalid option. Use 0-{0}'
        PressEnter = 'Press Enter to continue'
        DeleteTitle = 'Delete backups'
        Delete1 = 'Delete specific backup'
        Delete2 = 'Delete old backups and keep newest'
        Delete3 = 'Delete ALL backups'
        AvailableBackups = 'Available backups:'
        ChooseBackup = 'Choose backup number'
        NoBackups = 'No backups found in {0}'
        NoGHubData = 'No G HUB data folders found.'
        InvalidBackup = 'Invalid backup: manifest has no sources.'
        NoRestorableEntries = 'Backup has no restorable entries for selected options.'
        RestoreNoStop = 'Restore cannot use -NoStopProcesses. Let this script stop G HUB, or close G HUB first.'
        RestoreWarning = 'Restore will replace current G HUB data. A safety backup will be created first.'
        RestorePrompt = 'Type RESTORE to continue'
        RestoreCancelled = 'Restore cancelled.'
        DeleteThis = 'This will delete: {0}'
        DeletePrompt = 'Type DELETE to continue'
        DeleteAllPrompt = 'Type DELETE ALL to continue'
        DeleteCancelled = 'Delete cancelled.'
        CurrentBackups = 'Current backups: {0}'
        KeepNewestPrompt = 'Keep how many newest backups?'
        InvalidNumberDeleteCancelled = 'Invalid number. Delete cancelled.'
        NothingToDelete = 'Nothing to delete. Backup count <= {0}.'
        DeleteOldWarning = 'This will delete {0} old backup(s), keeping newest {1}.'
        DeleteAllWarning = 'This will delete ALL backups ({0}).'
        Deleted = 'Deleted: {0}'
        BackupSaved = 'Backup saved: {0}'
        ManifestSaved = 'Manifest: {0}'
        BackingUp = 'Backing up {0}'
        StartingGHub = 'Starting G HUB'
        StoppingGHub = 'Stopping G HUB ({0} process(es))'
        SafetyBackupFor = 'Safety backup for {0}'
        Restoring = 'Restoring {0}'
        RestoredFrom = 'Restored from: {0}'
        SafetyBackupSaved = 'Safety backup saved: {0}'
    }
    pt = @{
        LanguageTitle = 'Escolha o idioma'
        MainTitle = 'Logitech G HUB Backup/Restore'
        Main1 = 'Fazer backup'
        Main2 = 'Restaurar backup mais recente'
        Main3 = 'Escolher backup para restaurar'
        Main4 = 'Listar backups'
        Main5 = 'Gerenciar/excluir backups'
        Main6 = 'Fazer backup incluindo ProgramData (util para formatar o PC e reinstalar o programa)'
        Exit = 'Sair'
        Back = 'Voltar'
        Option = 'Opcao'
        InvalidOption = 'Opcao invalida. Use: {0}'
        InvalidOptionRange = 'Opcao invalida. Use 0-{0}'
        PressEnter = 'Pressione Enter para continuar'
        DeleteTitle = 'Excluir backups'
        Delete1 = 'Excluir backup especifico'
        Delete2 = 'Excluir backups antigos e manter os mais recentes'
        Delete3 = 'Excluir TODOS os backups'
        AvailableBackups = 'Backups disponiveis:'
        ChooseBackup = 'Escolha o numero do backup'
        NoBackups = 'Nenhum backup encontrado em {0}'
        NoGHubData = 'Nenhuma pasta de dados do G HUB encontrada.'
        InvalidBackup = 'Backup invalido: manifest nao tem fontes.'
        NoRestorableEntries = 'Backup nao tem entradas restauraveis para as opcoes selecionadas.'
        RestoreNoStop = 'Restauracao nao pode usar -NoStopProcesses. Deixe o script fechar o G HUB ou feche o G HUB antes.'
        RestoreWarning = 'A restauracao vai substituir os dados atuais do G HUB. Um backup de seguranca sera criado antes.'
        RestorePrompt = 'Digite RESTORE para continuar'
        RestoreCancelled = 'Restauracao cancelada.'
        DeleteThis = 'Isto vai excluir: {0}'
        DeletePrompt = 'Digite DELETE para continuar'
        DeleteAllPrompt = 'Digite DELETE ALL para continuar'
        DeleteCancelled = 'Exclusao cancelada.'
        CurrentBackups = 'Backups atuais: {0}'
        KeepNewestPrompt = 'Manter quantos backups mais recentes?'
        InvalidNumberDeleteCancelled = 'Numero invalido. Exclusao cancelada.'
        NothingToDelete = 'Nada para excluir. Quantidade de backups <= {0}.'
        DeleteOldWarning = 'Isto vai excluir {0} backup(s) antigo(s), mantendo os {1} mais recentes.'
        DeleteAllWarning = 'Isto vai excluir TODOS os backups ({0}).'
        Deleted = 'Excluido: {0}'
        BackupSaved = 'Backup salvo: {0}'
        ManifestSaved = 'Manifesto: {0}'
        BackingUp = 'Fazendo backup de {0}'
        StartingGHub = 'Abrindo G HUB'
        StoppingGHub = 'Fechando G HUB ({0} processo(s))'
        SafetyBackupFor = 'Backup de seguranca para {0}'
        Restoring = 'Restaurando {0}'
        RestoredFrom = 'Restaurado de: {0}'
        SafetyBackupSaved = 'Backup de seguranca salvo: {0}'
    }
    es = @{
        LanguageTitle = 'Elige idioma'
        Main1 = 'Crear copia de seguridad'
        Main2 = 'Restaurar copia mas reciente'
        Main3 = 'Elegir copia para restaurar'
        Main4 = 'Listar copias'
        Main5 = 'Gestionar/eliminar copias'
        Main6 = 'Crear copia con ProgramData (util antes de formatear el PC y reinstalar el programa)'
        Exit = 'Salir'
        Back = 'Volver'
        Option = 'Opcion'
        DeleteTitle = 'Eliminar copias'
        Delete1 = 'Eliminar copia especifica'
        Delete2 = 'Eliminar copias antiguas y mantener las recientes'
        Delete3 = 'Eliminar TODAS las copias'
        PressEnter = 'Pulsa Enter para continuar'
    }
    de = @{
        LanguageTitle = 'Sprache waehlen'
        Main1 = 'Backup erstellen'
        Main2 = 'Neuestes Backup wiederherstellen'
        Main3 = 'Backup zum Wiederherstellen waehlen'
        Main4 = 'Backups anzeigen'
        Main5 = 'Backups verwalten/loeschen'
        Main6 = 'Backup mit ProgramData erstellen (nuetzlich vor PC-Formatierung und Neuinstallation)'
        Exit = 'Beenden'
        Back = 'Zurueck'
        Option = 'Option'
        DeleteTitle = 'Backups loeschen'
        Delete1 = 'Bestimmtes Backup loeschen'
        Delete2 = 'Alte Backups loeschen und neueste behalten'
        Delete3 = 'ALLE Backups loeschen'
        PressEnter = 'Enter druecken zum Fortfahren'
    }
    fr = @{
        LanguageTitle = 'Choisir la langue'
        Main1 = 'Creer une sauvegarde'
        Main2 = 'Restaurer la sauvegarde la plus recente'
        Main3 = 'Choisir une sauvegarde a restaurer'
        Main4 = 'Lister les sauvegardes'
        Main5 = 'Gerer/supprimer les sauvegardes'
        Main6 = 'Creer une sauvegarde avec ProgramData (utile avant formatage du PC et reinstallation)'
        Exit = 'Quitter'
        Back = 'Retour'
        Option = 'Option'
        DeleteTitle = 'Supprimer les sauvegardes'
        Delete1 = 'Supprimer une sauvegarde specifique'
        Delete2 = 'Supprimer les anciennes et garder les recentes'
        Delete3 = 'Supprimer TOUTES les sauvegardes'
        PressEnter = 'Appuyez sur Enter pour continuer'
    }
    it = @{
        LanguageTitle = 'Scegli lingua'
        Main1 = 'Creare backup'
        Main2 = 'Ripristinare backup piu recente'
        Main3 = 'Scegliere backup da ripristinare'
        Main4 = 'Elencare backup'
        Main5 = 'Gestire/eliminare backup'
        Main6 = 'Creare backup con ProgramData (utile prima di formattare il PC e reinstallare il programma)'
        Exit = 'Esci'
        Back = 'Indietro'
        Option = 'Opzione'
        DeleteTitle = 'Eliminare backup'
        Delete1 = 'Eliminare backup specifico'
        Delete2 = 'Eliminare backup vecchi e mantenere i recenti'
        Delete3 = 'Eliminare TUTTI i backup'
        PressEnter = 'Premi Enter per continuare'
    }
    ja = @{
        LanguageTitle = 'Gengo wo erabu'
        Main1 = 'Backup sakusei'
        Main2 = 'Saishin backup wo fukugen'
        Main3 = 'Fukugen suru backup wo erabu'
        Main4 = 'Backup ichiran'
        Main5 = 'Backup kanri/sakujo'
        Main6 = 'ProgramData mo fukumu backup (PC format + program reinstall mae ni yuuyou)'
        Exit = 'Shuuryou'
        Back = 'Modoru'
        Option = 'Sentaku'
        DeleteTitle = 'Backup sakujo'
        Delete1 = 'Tokutei backup sakujo'
        Delete2 = 'Furui backup sakujo, atarashii mono wo nokosu'
        Delete3 = 'SUBETE no backup sakujo'
        PressEnter = 'Enter de tsuzuku'
    }
    zh = @{
        LanguageTitle = 'Xuanze yuyan'
        Main1 = 'Chuangjian backup'
        Main2 = 'Huifu zuixin backup'
        Main3 = 'Xuanze yao huifu de backup'
        Main4 = 'Liejv backup'
        Main5 = 'Guanli/shanchu backup'
        Main6 = 'Chuangjian han ProgramData backup (geshi hua PC he chongzhuang qian youyong)'
        Exit = 'Tuichu'
        Back = 'Fanhui'
        Option = 'Xuanxiang'
        DeleteTitle = 'Shanchu backup'
        Delete1 = 'Shanchu zhiding backup'
        Delete2 = 'Shanchu jiu backup bing baoliu xin backup'
        Delete3 = 'Shanchu SUOYOU backup'
        PressEnter = 'An Enter jixu'
    }
    hi = @{
        LanguageTitle = 'Bhasha chune'
        Main1 = 'Backup banaye'
        Main2 = 'Sabse naya backup restore kare'
        Main3 = 'Restore ke liye backup chune'
        Main4 = 'Backup list kare'
        Main5 = 'Backup manage/delete kare'
        Main6 = 'ProgramData ke saath backup (PC format aur reinstall se pehle useful)'
        Exit = 'Bahar'
        Back = 'Wapas'
        Option = 'Vikalp'
        DeleteTitle = 'Backup delete'
        Delete1 = 'Specific backup delete'
        Delete2 = 'Purane backup delete, naye rakhe'
        Delete3 = 'SABHI backup delete'
        PressEnter = 'Continue ke liye Enter dabaye'
    }
    ar = @{
        LanguageTitle = 'Ikhtar al-lugha'
        Main1 = 'Insha backup'
        Main2 = 'Istirja akher backup'
        Main3 = 'Ikhtar backup lil-istirja'
        Main4 = 'Ard backups'
        Main5 = 'Idarat/hadhf backups'
        Main6 = 'Backup maa ProgramData (mufid qabl format PC wa iadat tathbit)'
        Exit = 'Khurooj'
        Back = 'Rujoo'
        Option = 'Khayar'
        DeleteTitle = 'Hadhf backups'
        Delete1 = 'Hadhf backup moayyan'
        Delete2 = 'Hadhf qadim wa ibqa al-ahdath'
        Delete3 = 'Hadhf KOL backups'
        PressEnter = 'Idghat Enter lil-mutabaa'
    }
    ru = @{
        LanguageTitle = 'Vyberite yazyk'
        Main1 = 'Sozdat backup'
        Main2 = 'Vosstanovit posledniy backup'
        Main3 = 'Vybrat backup dlya vosstanovleniya'
        Main4 = 'Pokazat backups'
        Main5 = 'Upravlyat/udalit backups'
        Main6 = 'Sozdat backup s ProgramData (polezno pered formatom PC i pereustanovkoy)'
        Exit = 'Vyhod'
        Back = 'Nazad'
        Option = 'Variant'
        DeleteTitle = 'Udalit backups'
        Delete1 = 'Udalit konkretnyy backup'
        Delete2 = 'Udalit starye backups i ostavit novye'
        Delete3 = 'Udalit VSE backups'
        PressEnter = 'Nazhmite Enter dlya prodolzheniya'
    }
}

function Get-UiText {
    param([Parameter(Mandatory)][string]$Key)

    if ($script:UiText.ContainsKey($script:UiLanguage) -and
        $script:UiText[$script:UiLanguage].ContainsKey($Key)) {
        return $script:UiText[$script:UiLanguage][$Key]
    }

    if ($script:UiText.en.ContainsKey($Key)) {
        return $script:UiText.en[$Key]
    }

    return $Key
}

function Format-UiText {
    param(
        [Parameter(Mandatory)][string]$Key,
        [object[]]$Values = @()
    )

    return [string]::Format((Get-UiText -Key $Key), $Values)
}

if ([string]::IsNullOrWhiteSpace($BackupRoot)) {
    $scriptDirectory = $PSScriptRoot
    if ([string]::IsNullOrWhiteSpace($scriptDirectory)) {
        $scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
    }
    if ([string]::IsNullOrWhiteSpace($scriptDirectory)) {
        $scriptDirectory = (Get-Location).Path
    }
    $BackupRoot = $scriptDirectory
}

function Write-Step {
    param([string]$Message)
    Write-Host "==> $Message" -ForegroundColor Cyan
}

function Write-Ok {
    param([string]$Message)
    Write-Host "OK  $Message" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Message)
    Write-Host "WARN $Message" -ForegroundColor Yellow
}

function Get-TimeStamp {
    Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'
}

function Test-IsAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function New-Directory {
    param([Parameter(Mandatory)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function New-GHubTarget {
    param(
        [Parameter(Mandatory)][string]$Id,
        [Parameter(Mandatory)][string]$Label,
        [Parameter(Mandatory)][string]$Path,
        [bool]$RestoreByDefault = $true
    )

    [pscustomobject]@{
        Id = $Id
        Label = $Label
        Path = $Path
        RestoreByDefault = $RestoreByDefault
    }
}

function Get-GHubDataTargets {
    $targets = @()

    if ($env:LOCALAPPDATA) {
        $targets += New-GHubTarget `
            -Id 'LocalAppData_LGHUB' `
            -Label 'User settings DB, profiles, scripts, integrations' `
            -Path (Join-Path $env:LOCALAPPDATA 'LGHUB')
    }

    if ($env:APPDATA) {
        $targets += New-GHubTarget `
            -Id 'Roaming_LGHUB' `
            -Label 'Window state and frontend store' `
            -Path (Join-Path $env:APPDATA 'LGHUB')
    }

    if ($IncludeProgramData -and $env:PROGRAMDATA) {
        $targets += New-GHubTarget `
            -Id 'ProgramData_LGHUB' `
            -Label 'Shared G HUB install metadata' `
            -Path (Join-Path $env:PROGRAMDATA 'LGHUB') `
            -RestoreByDefault $false

        $targets += New-GHubTarget `
            -Id 'ProgramData_LGHUBData' `
            -Label 'Shared G HUB app data' `
            -Path (Join-Path $env:PROGRAMDATA 'LGHUBData') `
            -RestoreByDefault $false

        $targets += New-GHubTarget `
            -Id 'ProgramData_Logishrd_LGHUB' `
            -Label 'Shared Logitech data' `
            -Path (Join-Path $env:PROGRAMDATA 'Logishrd\LGHUB') `
            -RestoreByDefault $false
    }

    @($targets)
}

function Resolve-GHubTargetPath {
    param([Parameter(Mandatory)][string]$Id)

    switch ($Id) {
        'LocalAppData_LGHUB' {
            if ($env:LOCALAPPDATA) { return (Join-Path $env:LOCALAPPDATA 'LGHUB') }
        }
        'Roaming_LGHUB' {
            if ($env:APPDATA) { return (Join-Path $env:APPDATA 'LGHUB') }
        }
        'ProgramData_LGHUB' {
            if ($env:PROGRAMDATA) { return (Join-Path $env:PROGRAMDATA 'LGHUB') }
        }
        'ProgramData_LGHUBData' {
            if ($env:PROGRAMDATA) { return (Join-Path $env:PROGRAMDATA 'LGHUBData') }
        }
        'ProgramData_Logishrd_LGHUB' {
            if ($env:PROGRAMDATA) { return (Join-Path $env:PROGRAMDATA 'Logishrd\LGHUB') }
        }
    }

    return $null
}

function Get-GHubProcesses {
    $managedNames = @(
        'lghub',
        'lghub_agent',
        'lghub_system_tray',
        'lghub_software_manager',
        'lghub_sso_handler',
        'lghub_gl'
    )

    @(Get-Process -ErrorAction SilentlyContinue | Where-Object {
        $managedNames -contains $_.ProcessName
    })
}

function Find-GHubExecutable {
    param([object[]]$Processes = @())

    foreach ($process in @($Processes)) {
        try {
            if ($process.Path -and
                (Split-Path -Path $process.Path -Leaf) -ieq 'lghub.exe' -and
                (Test-Path -LiteralPath $process.Path)) {
                return $process.Path
            }
        }
        catch {
            # Some process paths need elevated access.
        }
    }

    $candidates = @()
    if ($env:ProgramFiles) {
        $candidates += (Join-Path $env:ProgramFiles 'LGHUB\lghub.exe')
    }
    if (${env:ProgramFiles(x86)}) {
        $candidates += (Join-Path ${env:ProgramFiles(x86)} 'LGHUB\lghub.exe')
    }

    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate) {
            return $candidate
        }
    }

    return $null
}

function Stop-GHubIfNeeded {
    if ($NoStopProcesses) {
        Write-Warn 'Skipping G HUB process stop. Backup may capture a changing SQLite DB.'
        return [pscustomobject]@{
            WasRunning = $false
            Executable = Find-GHubExecutable
        }
    }

    $processes = @(Get-GHubProcesses)
    $executable = Find-GHubExecutable -Processes $processes

    if ($processes.Count -eq 0) {
        return [pscustomobject]@{
            WasRunning = $false
            Executable = $executable
        }
    }

    Write-Step (Format-UiText -Key 'StoppingGHub' -Values @($processes.Count))

    foreach ($process in $processes) {
        try {
            if ($process.MainWindowHandle -ne 0) {
                [void]$process.CloseMainWindow()
            }
        }
        catch {
            # Fall through to Stop-Process below.
        }
    }

    Start-Sleep -Seconds 2

    $remaining = @(Get-GHubProcesses)
    foreach ($process in $remaining) {
        try {
            Stop-Process -Id $process.Id -Force -ErrorAction Stop
        }
        catch {
            Write-Warn ("Could not stop process {0} ({1})" -f $process.ProcessName, $process.Id)
        }
    }

    Start-Sleep -Seconds 1
    $remaining = @(Get-GHubProcesses)
    if ($remaining.Count -gt 0) {
        $names = ($remaining | ForEach-Object { '{0}({1})' -f $_.ProcessName, $_.Id }) -join ', '
        if (-not (Test-IsAdministrator)) {
            throw "G HUB processes still running: $names. Run GHubBackupRestore.bat and accept the Windows administrator prompt."
        }

        throw "G HUB processes still running: $names. Close G HUB manually and try again."
    }

    [pscustomobject]@{
        WasRunning = $true
        Executable = $executable
    }
}

function Start-GHubIfNeeded {
    param([Parameter(Mandatory)]$State)

    if ($NoRestart -or -not $State.WasRunning) {
        return
    }

    if ($State.Executable -and (Test-Path -LiteralPath $State.Executable)) {
        Write-Step (Get-UiText -Key 'StartingGHub')
        Start-Process -FilePath $State.Executable | Out-Null
    }
    else {
        Write-Warn 'G HUB was running, but lghub.exe was not found for restart.'
    }
}

function Invoke-RobocopyMirror {
    param(
        [Parameter(Mandatory)][string]$Source,
        [Parameter(Mandatory)][string]$Destination
    )

    if (-not (Test-Path -LiteralPath $Source)) {
        throw "Source not found: $Source"
    }

    New-Directory -Path $Destination

    $arguments = @(
        $Source,
        $Destination,
        '/MIR',
        '/COPY:DAT',
        '/DCOPY:DAT',
        '/R:2',
        '/W:1',
        '/XJ',
        '/NP',
        '/NFL',
        '/NDL',
        '/NJH',
        '/NJS'
    )

    & robocopy @arguments | Out-Null
    $exitCode = $LASTEXITCODE
    $global:LASTEXITCODE = 0

    if ($exitCode -gt 7) {
        throw "robocopy failed with exit code $exitCode. Source: $Source Destination: $Destination"
    }

    return $exitCode
}

function Measure-Folder {
    param([Parameter(Mandatory)][string]$Path)

    $measure = Get-ChildItem -LiteralPath $Path -Recurse -File -Force -ErrorAction SilentlyContinue |
        Measure-Object -Property Length -Sum

    $bytes = 0
    if ($null -ne $measure.Sum) {
        $bytes = [int64]$measure.Sum
    }

    [pscustomobject]@{
        FileCount = [int]$measure.Count
        Bytes = $bytes
    }
}

function Get-BackupManifests {
    if (-not (Test-Path -LiteralPath $BackupRoot)) {
        return @()
    }

    @(Get-ChildItem -LiteralPath $BackupRoot -Directory -ErrorAction SilentlyContinue |
        Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'manifest.json') } |
        ForEach-Object {
            try {
                $manifest = Get-Content -LiteralPath (Join-Path $_.FullName 'manifest.json') -Raw | ConvertFrom-Json
                $propertyNames = @($manifest.PSObject.Properties | ForEach-Object { $_.Name })
                if ($propertyNames -contains 'sources') {
                    [pscustomobject]@{
                        CreatedAt = $manifest.createdAt
                        Sources = (@($manifest.sources) | ForEach-Object { $_.id }) -join ', '
                        Path = $_.FullName
                    }
                }
            }
            catch {
                Write-Warn ("Ignoring invalid backup manifest: {0}" -f $_.FullName)
            }
        } |
        Sort-Object CreatedAt -Descending)
}

function Resolve-BackupPath {
    if ($BackupPath) {
        if (-not (Test-Path -LiteralPath $BackupPath)) {
            throw "Backup path not found: $BackupPath"
        }
        return (Resolve-Path -LiteralPath $BackupPath).Path
    }

    $latest = @(Get-BackupManifests | Select-Object -First 1)
    if ($latest.Count -eq 0) {
        throw (Format-UiText -Key 'NoBackups' -Values @($BackupRoot))
    }

    return $latest[0].Path
}

function Invoke-Backup {
    New-Directory -Path $BackupRoot

    $backupDirectory = Join-Path $BackupRoot ("{0}-{1}" -f $BackupFolderPrefix, (Get-TimeStamp))
    New-Directory -Path $backupDirectory

    $state = Stop-GHubIfNeeded

    try {
        $sources = @()
        $targets = @(Get-GHubDataTargets | Where-Object { Test-Path -LiteralPath $_.Path })

        if ($targets.Count -eq 0) {
            throw (Get-UiText -Key 'NoGHubData')
        }

        foreach ($target in $targets) {
            $destination = Join-Path $backupDirectory $target.Id
            Write-Step (Format-UiText -Key 'BackingUp' -Values @($target.Id))
            Invoke-RobocopyMirror -Source $target.Path -Destination $destination | Out-Null

            $stats = Measure-Folder -Path $destination
            $sources += [ordered]@{
                id = $target.Id
                label = $target.Label
                sourcePath = $target.Path
                backupFolder = $target.Id
                restoreByDefault = [bool]$target.RestoreByDefault
                fileCount = $stats.FileCount
                bytes = $stats.Bytes
            }
        }

        $manifest = [ordered]@{
            tool = 'logitech-ghub-save-restore'
            version = '1.0.0'
            createdAt = (Get-Date).ToString('o')
            computerName = $env:COMPUTERNAME
            userName = $env:USERNAME
            includeProgramData = [bool]$IncludeProgramData
            backupDirectory = $backupDirectory
            sources = $sources
        }

        $manifestPath = Join-Path $backupDirectory 'manifest.json'
        $manifest | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $manifestPath -Encoding UTF8

        Write-Ok (Format-UiText -Key 'BackupSaved' -Values @($backupDirectory))
        Write-Ok (Format-UiText -Key 'ManifestSaved' -Values @($manifestPath))
    }
    finally {
        Start-GHubIfNeeded -State $state
    }
}

function Invoke-List {
    $items = @(Get-BackupManifests)

    if ($items.Count -eq 0) {
        Write-Warn (Format-UiText -Key 'NoBackups' -Values @($BackupRoot))
        return
    }

    $items | Format-Table -AutoSize
}

function Read-MenuChoice {
    param(
        [Parameter(Mandatory)][string]$Prompt,
        [Parameter(Mandatory)][string[]]$ValidChoices
    )

    do {
        $choice = (Read-Host $Prompt).Trim()
        if ($ValidChoices -contains $choice) {
            return $choice
        }

        Write-Warn (Format-UiText -Key 'InvalidOption' -Values @(($ValidChoices -join ', ')))
    } while ($true)
}

function Wait-MenuContinue {
    Write-Host ''
    [void](Read-Host (Get-UiText -Key 'PressEnter'))
}

function Select-BackupFromMenu {
    $items = @(Get-BackupManifests)

    if ($items.Count -eq 0) {
        Write-Warn (Format-UiText -Key 'NoBackups' -Values @($BackupRoot))
        return $null
    }

    Write-Host ''
    Write-Host (Get-UiText -Key 'AvailableBackups') -ForegroundColor Cyan
    for ($index = 0; $index -lt $items.Count; $index++) {
        $number = $index + 1
        Write-Host ("{0}. {1} - {2}" -f $number, $items[$index].CreatedAt, $items[$index].Path)
    }
    Write-Host ("0. {0}" -f (Get-UiText -Key 'Back'))
    Write-Host ''

    do {
        $choice = Read-Host (Get-UiText -Key 'ChooseBackup')
        $parsed = 0
        if ([int]::TryParse($choice, [ref]$parsed)) {
            if ($parsed -eq 0) {
                return $null
            }
            if ($parsed -ge 1 -and $parsed -le $items.Count) {
                return $items[$parsed - 1].Path
            }
        }

        Write-Warn (Format-UiText -Key 'InvalidOptionRange' -Values @($items.Count))
    } while ($true)
}

function Assert-SafeBackupDirectory {
    param([Parameter(Mandatory)][string]$Path)

    $resolvedRoot = (Resolve-Path -LiteralPath $BackupRoot).Path.TrimEnd('\')
    $resolvedPath = (Resolve-Path -LiteralPath $Path).Path.TrimEnd('\')
    $leaf = Split-Path -Path $resolvedPath -Leaf

    $isInsideRoot = $resolvedPath.StartsWith($resolvedRoot + '\', [System.StringComparison]::OrdinalIgnoreCase)
    $hasBackupPrefix = $leaf -like "$BackupFolderPrefix-*"

    if (-not $isInsideRoot -or -not $hasBackupPrefix) {
        throw "Unsafe delete blocked: $resolvedPath"
    }
}

function Remove-BackupDirectory {
    param([Parameter(Mandatory)][string]$Path)

    Assert-SafeBackupDirectory -Path $Path
    Remove-Item -LiteralPath $Path -Recurse -Force
    Write-Ok (Format-UiText -Key 'Deleted' -Values @($Path))
}

function Invoke-DeleteSpecificBackup {
    $selectedBackup = Select-BackupFromMenu
    if (-not $selectedBackup) {
        return
    }

    Write-Warn (Format-UiText -Key 'DeleteThis' -Values @($selectedBackup))
    $answer = Read-Host (Get-UiText -Key 'DeletePrompt')
    if ($answer -ne 'DELETE') {
        Write-Warn (Get-UiText -Key 'DeleteCancelled')
        return
    }

    Remove-BackupDirectory -Path $selectedBackup
}

function Invoke-DeleteOldBackups {
    $items = @(Get-BackupManifests)

    if ($items.Count -eq 0) {
        Write-Warn (Format-UiText -Key 'NoBackups' -Values @($BackupRoot))
        return
    }

    Write-Host ''
    Write-Host (Format-UiText -Key 'CurrentBackups' -Values @($items.Count)) -ForegroundColor Cyan
    $keepText = Read-Host (Get-UiText -Key 'KeepNewestPrompt')
    $keep = 0
    if (-not [int]::TryParse($keepText, [ref]$keep) -or $keep -lt 1) {
        Write-Warn (Get-UiText -Key 'InvalidNumberDeleteCancelled')
        return
    }

    if ($items.Count -le $keep) {
        Write-Ok (Format-UiText -Key 'NothingToDelete' -Values @($keep))
        return
    }

    $toDelete = @($items | Select-Object -Skip $keep)

    Write-Warn (Format-UiText -Key 'DeleteOldWarning' -Values @($toDelete.Count, $keep))
    foreach ($item in $toDelete) {
        Write-Host ("- {0}" -f $item.Path)
    }

    $answer = Read-Host (Get-UiText -Key 'DeletePrompt')
    if ($answer -ne 'DELETE') {
        Write-Warn (Get-UiText -Key 'DeleteCancelled')
        return
    }

    foreach ($item in $toDelete) {
        Remove-BackupDirectory -Path $item.Path
    }
}

function Invoke-DeleteAllBackups {
    $items = @(Get-BackupManifests)

    if ($items.Count -eq 0) {
        Write-Warn (Format-UiText -Key 'NoBackups' -Values @($BackupRoot))
        return
    }

    Write-Warn (Format-UiText -Key 'DeleteAllWarning' -Values @($items.Count))
    foreach ($item in $items) {
        Write-Host ("- {0}" -f $item.Path)
    }

    $answer = Read-Host (Get-UiText -Key 'DeleteAllPrompt')
    if ($answer -ne 'DELETE ALL') {
        Write-Warn (Get-UiText -Key 'DeleteCancelled')
        return
    }

    foreach ($item in $items) {
        Remove-BackupDirectory -Path $item.Path
    }
}

function Invoke-DeleteMenu {
    do {
        Clear-Host
        Write-Host (Get-UiText -Key 'DeleteTitle') -ForegroundColor Cyan
        Write-Host ''
        Write-Host ("1. {0}" -f (Get-UiText -Key 'Delete1'))
        Write-Host ("2. {0}" -f (Get-UiText -Key 'Delete2'))
        Write-Host ("3. {0}" -f (Get-UiText -Key 'Delete3'))
        Write-Host ("0. {0}" -f (Get-UiText -Key 'Back'))
        Write-Host ''

        $choice = Read-MenuChoice -Prompt (Get-UiText -Key 'Option') -ValidChoices @('0', '1', '2', '3')

        switch ($choice) {
            '0' {
                return
            }
            '1' {
                Invoke-DeleteSpecificBackup
                Wait-MenuContinue
            }
            '2' {
                Invoke-DeleteOldBackups
                Wait-MenuContinue
            }
            '3' {
                Invoke-DeleteAllBackups
                Wait-MenuContinue
            }
        }
    } while ($true)
}

function Select-UiLanguage {
    do {
        Clear-Host
        Write-Host 'Language / Idioma' -ForegroundColor Cyan
        Write-Host ''
        foreach ($language in $script:LanguageOptions) {
            Write-Host ("{0}. {1}" -f $language.Number, $language.Label)
        }
        Write-Host '0. Exit / Sair'
        Write-Host ''

        $choice = (Read-Host 'Option / Opcao').Trim()

        if ($choice -eq '0') {
            return $false
        }

        $selectedLanguage = @($script:LanguageOptions | Where-Object { $_.Number -eq $choice } | Select-Object -First 1)
        if ($selectedLanguage.Count -eq 1) {
            $script:UiLanguage = $selectedLanguage[0].Code
            return $true
        }

        $lastOption = $script:LanguageOptions[-1].Number
        Write-Warn ("Invalid option. Use: 0-{0}" -f $lastOption)
        Start-Sleep -Seconds 1
    } while ($true)
}

function Invoke-Menu {
    if (-not (Select-UiLanguage)) {
        return
    }

    do {
        Clear-Host
        Write-Host (Get-UiText -Key 'MainTitle') -ForegroundColor Cyan
        Write-Host ''
        Write-Host ("1. {0}" -f (Get-UiText -Key 'Main1'))
        Write-Host ("2. {0}" -f (Get-UiText -Key 'Main2'))
        Write-Host ("3. {0}" -f (Get-UiText -Key 'Main3'))
        Write-Host ("4. {0}" -f (Get-UiText -Key 'Main4'))
        Write-Host ("5. {0}" -f (Get-UiText -Key 'Main5'))
        Write-Host ("6. {0}" -f (Get-UiText -Key 'Main6'))
        Write-Host ("0. {0}" -f (Get-UiText -Key 'Exit'))
        Write-Host ''

        $choice = Read-MenuChoice -Prompt (Get-UiText -Key 'Option') -ValidChoices @('0', '1', '2', '3', '4', '5', '6')

        try {
            switch ($choice) {
                '0' {
                    return
                }
                '1' {
                    Invoke-Backup
                    Wait-MenuContinue
                }
                '2' {
                    $script:BackupPath = $null
                    Invoke-Restore
                    Wait-MenuContinue
                }
                '3' {
                    $selectedBackup = Select-BackupFromMenu
                    if ($selectedBackup) {
                        $script:BackupPath = $selectedBackup
                        try {
                            Invoke-Restore
                        }
                        finally {
                            $script:BackupPath = $null
                        }
                    }
                    Wait-MenuContinue
                }
                '4' {
                    Invoke-List
                    Wait-MenuContinue
                }
                '5' {
                    Invoke-DeleteMenu
                }
                '6' {
                    $previousIncludeProgramData = $script:IncludeProgramData
                    $script:IncludeProgramData = $true
                    try {
                        Invoke-Backup
                    }
                    finally {
                        $script:IncludeProgramData = $previousIncludeProgramData
                    }
                    Wait-MenuContinue
                }
            }
        }
        catch {
            Write-Warn $_.Exception.Message
            Wait-MenuContinue
        }
    } while ($true)
}

function Confirm-Restore {
    if ($Force) {
        return
    }

    Write-Warn (Get-UiText -Key 'RestoreWarning')
    $answer = Read-Host (Get-UiText -Key 'RestorePrompt')
    if ($answer -ne 'RESTORE') {
        throw (Get-UiText -Key 'RestoreCancelled')
    }
}

function Invoke-Restore {
    if ($NoStopProcesses) {
        throw (Get-UiText -Key 'RestoreNoStop')
    }

    $resolvedBackupPath = Resolve-BackupPath
    $manifestPath = Join-Path $resolvedBackupPath 'manifest.json'
    if (-not (Test-Path -LiteralPath $manifestPath)) {
        throw "Backup manifest not found: $manifestPath"
    }

    $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
    $propertyNames = @($manifest.PSObject.Properties | ForEach-Object { $_.Name })
    if ($propertyNames -notcontains 'sources') {
        throw (Get-UiText -Key 'InvalidBackup')
    }

    $entries = @($manifest.sources | Where-Object {
        $_.restoreByDefault -or $IncludeProgramData
    })

    if ($entries.Count -eq 0) {
        throw (Get-UiText -Key 'NoRestorableEntries')
    }

    Confirm-Restore

    New-Directory -Path $BackupRoot
    $safetyDirectory = Join-Path $BackupRoot ("{0}-{1}" -f $SafetyFolderPrefix, (Get-TimeStamp))
    New-Directory -Path $safetyDirectory

    $state = Stop-GHubIfNeeded

    try {
        $restored = @()

        foreach ($entry in $entries) {
            $source = Join-Path $resolvedBackupPath $entry.backupFolder
            if (-not (Test-Path -LiteralPath $source)) {
                throw "Backup folder missing: $source"
            }

            $destination = Resolve-GHubTargetPath -Id $entry.id
            if (-not $destination) {
                $destination = $entry.sourcePath
            }
            if (-not $destination) {
                throw ("Cannot resolve destination for {0}" -f $entry.id)
            }

            if (Test-Path -LiteralPath $destination) {
                $safetyTarget = Join-Path $safetyDirectory $entry.id
                Write-Step (Format-UiText -Key 'SafetyBackupFor' -Values @($entry.id))
                Invoke-RobocopyMirror -Source $destination -Destination $safetyTarget | Out-Null
            }

            try {
                Write-Step (Format-UiText -Key 'Restoring' -Values @($entry.id))
                Invoke-RobocopyMirror -Source $source -Destination $destination | Out-Null
                $restored += [ordered]@{
                    id = $entry.id
                    destination = $destination
                }
            }
            catch {
                $safetyTarget = Join-Path $safetyDirectory $entry.id
                if (Test-Path -LiteralPath $safetyTarget) {
                    Write-Warn ("Restore failed for {0}. Rolling back from safety backup." -f $entry.id)
                    Invoke-RobocopyMirror -Source $safetyTarget -Destination $destination | Out-Null
                }
                throw
            }
        }

        $safetyManifest = [ordered]@{
            tool = 'logitech-ghub-save-restore'
            type = 'pre-restore-safety'
            createdAt = (Get-Date).ToString('o')
            restoredFrom = $resolvedBackupPath
            restored = $restored
        }
        $safetyManifest | ConvertTo-Json -Depth 8 |
            Set-Content -LiteralPath (Join-Path $safetyDirectory 'manifest.json') -Encoding UTF8

        Write-Ok (Format-UiText -Key 'RestoredFrom' -Values @($resolvedBackupPath))
        Write-Ok (Format-UiText -Key 'SafetyBackupSaved' -Values @($safetyDirectory))
    }
    finally {
        Start-GHubIfNeeded -State $state
    }
}

switch ($Action) {
    'Menu' { Invoke-Menu }
    'Backup' { Invoke-Backup }
    'Restore' { Invoke-Restore }
    'List' { Invoke-List }
}
