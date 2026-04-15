param(
    [switch]$SkipFrontendBuild,
    [switch]$SkipBackendBuild,
    [switch]$SkipRuntimeCopy
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Require-Command {
    param([string]$Name)
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Command not found: $Name"
    }
}

function Ensure-Directory {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Reset-Directory {
    param([string]$Path)
    if (Test-Path -LiteralPath $Path) {
        Remove-Item -LiteralPath $Path -Recurse -Force
    }
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
}

function Copy-DirectoryContent {
    param(
        [string]$Source,
        [string]$Target
    )
    Ensure-Directory $Target
    Get-ChildItem -LiteralPath $Target -Force -ErrorAction SilentlyContinue |
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    Copy-Item -Path (Join-Path $Source '*') -Destination $Target -Recurse -Force
}

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$workspaceRoot = Split-Path -Parent $scriptRoot
$backendRoot = Join-Path $workspaceRoot 'RuoYi-Vue-master'
$frontendRoot = Join-Path $workspaceRoot 'Hanzhong-Elec-AfterSale-Web'
$sqlRoot = Join-Path $backendRoot 'sql'
$templateRoot = Join-Path $scriptRoot 'templates'
$mysqlTemplateRoot = Join-Path $scriptRoot 'mysql-template'
$staticTarget = Join-Path $backendRoot 'ruoyi-admin\src\main\resources\static'
$jarPath = Join-Path $backendRoot 'ruoyi-admin\target\ruoyi-admin.jar'
$distRoot = Join-Path $scriptRoot 'dist\Hanzhong-AfterSale-Desktop'
$runtimeTarget = Join-Path $distRoot 'jre'
$portableMysqlTarget = Join-Path $distRoot 'portable-mysql'
$mavenRepoLocal = Join-Path $workspaceRoot '.m2repo'

Require-Command npm
Require-Command mvn
Ensure-Directory $mavenRepoLocal

if (-not $env:JAVA_HOME) {
    throw 'JAVA_HOME is required so the portable package can embed a runtime.'
}

Write-Host ''
Write-Host '== Portable desktop packaging =='
Write-Host "Workspace : $workspaceRoot"
Write-Host "Output    : $distRoot"

if (-not $SkipFrontendBuild) {
    Write-Host ''
    Write-Host '1/5 Build web frontend'
    Push-Location $frontendRoot
    try {
        if (-not (Test-Path -LiteralPath (Join-Path $frontendRoot 'node_modules'))) {
            npm install
        }
        npm run build
    }
    finally {
        Pop-Location
    }
} else {
    Write-Host ''
    Write-Host '1/5 Skip web frontend build'
}

Write-Host ''
Write-Host '2/5 Sync frontend assets into Spring Boot'
Copy-DirectoryContent -Source (Join-Path $frontendRoot 'dist') -Target $staticTarget

if (-not $SkipBackendBuild) {
    Write-Host ''
    Write-Host '3/5 Build Spring Boot jar'
    $mavenRepoPath = (Resolve-Path -LiteralPath $mavenRepoLocal).Path -replace '\\', '/'
    Push-Location $backendRoot
    try {
        mvn -U "-Dmaven.repo.local=$mavenRepoPath" -pl ruoyi-admin -am clean package -DskipTests
    }
    finally {
        Pop-Location
    }
} else {
    Write-Host ''
    Write-Host '3/5 Skip backend build'
}

if (-not (Test-Path -LiteralPath $jarPath)) {
    throw "Jar not found: $jarPath"
}

Write-Host ''
Write-Host '4/5 Assemble portable directory'
Reset-Directory $distRoot
@(
    'app',
    'data',
    'data\h2',
    'data\upload',
    'data\run',
    'portable-mysql',
    'portable-mysql\data',
    'portable-mysql\logs',
    'portable-mysql\mysql',
    'portable-mysql\scripts'
) | ForEach-Object {
    Ensure-Directory (Join-Path $distRoot $_)
}

Copy-Item -LiteralPath $jarPath -Destination (Join-Path $distRoot 'app\ruoyi-admin.jar') -Force
Copy-Item -LiteralPath (Join-Path $templateRoot 'start-app.bat') -Destination (Join-Path $distRoot 'start-app.bat') -Force
Copy-Item -LiteralPath (Join-Path $templateRoot 'stop-app.bat') -Destination (Join-Path $distRoot 'stop-app.bat') -Force
Copy-Item -LiteralPath (Join-Path $templateRoot 'start-app-mysql.bat') -Destination (Join-Path $distRoot 'start-app-mysql.bat') -Force
Copy-Item -LiteralPath (Join-Path $scriptRoot 'README.md') -Destination (Join-Path $distRoot 'README.md') -Force
Copy-Item -LiteralPath (Join-Path $mysqlTemplateRoot 'my.ini') -Destination (Join-Path $portableMysqlTarget 'my.ini') -Force
Copy-Item -LiteralPath (Join-Path $mysqlTemplateRoot 'start-mysql.bat') -Destination (Join-Path $portableMysqlTarget 'scripts\start-mysql.bat') -Force
Copy-Item -LiteralPath (Join-Path $mysqlTemplateRoot 'stop-mysql.bat') -Destination (Join-Path $portableMysqlTarget 'scripts\stop-mysql.bat') -Force
Copy-Item -LiteralPath (Join-Path $sqlRoot 'init_hanzhong_project_full.sql') -Destination (Join-Path $portableMysqlTarget 'scripts\init-database.sql') -Force

if (-not $SkipRuntimeCopy) {
    Write-Host ''
    Write-Host '5/5 Copy embedded runtime'
    $javaHome = $env:JAVA_HOME
    $sourceRuntime = if (Test-Path -LiteralPath (Join-Path $javaHome 'jre')) {
        Join-Path $javaHome 'jre'
    } else {
        $javaHome
    }

    Copy-Item -LiteralPath $sourceRuntime -Destination $runtimeTarget -Recurse -Force
} else {
    Write-Host ''
    Write-Host '5/5 Skip runtime copy'
}

Write-Host ''
Write-Host 'Portable package completed.'
Write-Host "Run file: $(Join-Path $distRoot 'start-app.bat')"
