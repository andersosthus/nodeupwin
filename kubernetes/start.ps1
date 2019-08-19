Param(
    [parameter(Mandatory = $true)] $ManagementIp,
    [ValidateSet("l2bridge", "overlay",IgnoreCase = $true)] [parameter(Mandatory = $true)] $NetworkMode,
    [parameter(Mandatory = $true)] [string] $MasterIp,
    [parameter(Mandatory = $false)] $ClusterCIDR="192.168.0.0/16"

)

$GithubRepository = 'andersosthus/nodeupwin'
if ((Test-Path env:GITHUB_SDN_REPOSITORY) -and ($env:GITHUB_SDN_REPOSITORY -ne ''))
{
    $GithubRepository = $env:GITHUB_SDN_REPOSITORY
}

function DownloadCniBinaries()
{
    Write-Host "Downloading CNI binaries"
    md $BaseDir\cni\config -ErrorAction Ignore

    DownloadFile -Url "https://raw.githubusercontent.com/$GithubRepository/master/cni/wincni.exe" -Destination $BaseDir\cni\wincni.exe
}

function DownloadWindowsKubernetesScripts()
{
    Write-Host "Downloading Windows Kubernetes scripts"
    DownloadFile -Url "https://raw.githubusercontent.com/$GithubRepository/master/hns.psm1" -Destination $BaseDir\hns.psm1
    DownloadFile -Url "https://raw.githubusercontent.com/$GithubRepository/master/InstallImages.ps1" -Destination $BaseDir\InstallImages.ps1
    DownloadFile -Url "https://raw.githubusercontent.com/$GithubRepository/master/Dockerfile" -Destination $BaseDir\Dockerfile
    DownloadFile -Url "https://raw.githubusercontent.com/$GithubRepository/master/stop.ps1" -Destination $BaseDir\stop.ps1
    DownloadFile -Url "https://raw.githubusercontent.com/$GithubRepository/master/start-kubelet.ps1" -Destination $BaseDir\start-kubelet.ps1
    DownloadFile -Url "https://raw.githubusercontent.com/$GithubRepository/master/start-kubeproxy.ps1" -Destination $BaseDir\start-Kubeproxy.ps1
    DownloadFile -Url "https://raw.githubusercontent.com/$GithubRepository/master/AddRoutes.ps1" -Destination $BaseDir\AddRoutes.ps1
}

function DownloadAllFiles()
{
    DownloadCniBinaries
    DownloadWindowsKubernetesScripts
}

$BaseDir = "c:\k"
md $BaseDir -ErrorAction Ignore

$helper = "c:\k\helper.psm1"
if (!(Test-Path $helper))
{
    Start-BitsTransfer "https://raw.githubusercontent.com/$GithubRepository/master/helper.psm1" -Destination c:\k\helper.psm1
}
ipmo $helper

DownloadAllFiles

# Prepare POD infra Images
start powershell $BaseDir\InstallImages.ps1

# Prepare Network & Start Infra services
$NetworkMode = "L2Bridge"

# WinCni needs the networkType and network name to be the same
$NetworkName = "l2bridge"

CleanupOldNetwork $NetworkName

Start powershell -ArgumentList "-File $BaseDir\start-kubelet.ps1 -clusterCIDR $clusterCIDR -NetworkName $NetworkName"

WaitForNetwork $NetworkName

start powershell -ArgumentList " -File $BaseDir\start-kubeproxy.ps1 -NetworkName $NetworkName"

powershell -File $BaseDir\AddRoutes.ps1 -masterIp $masterIp