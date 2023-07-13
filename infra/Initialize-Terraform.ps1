#Requires -Modules @{ ModuleName="Az.Resources"; ModuleVersion="6.4.1" }

PARAM
(
    [Parameter(Mandatory = $false)]
    [ValidateSet("dev", "staging", "prod")]
    [string] $Stage = "dev"
)

$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

# Connect to Azure and get the proper context
Connect-AzAccount
Get-AzTenant
$tenantId = Read-Host "Choose a tenant id"
Set-AzContext -TenantId $tenantId
$azContext = Get-AzContext;
if ($null -eq $azContext) {
    Write-Error "No Azure context found. Please connect to Azure first."
    exit 1
}


# Resource Group
$resourceGroupName = "test-azure-iac-$($Stage)-rg-tf"
Get-AzResourceGroup -Name $resourceGroupName -ErrorVariable notPresent -ErrorAction SilentlyContinue
if ($notPresent) {
    New-AzResourceGroup -Name $resourceGroupName -Location "westeurope"
    Write-Host "Resource Group $($resourceGroupName) created successfully."
}
else {
    Write-Host "Resource Group $($resourceGroupName) already exists."
}

# Storage Account and Container
$storageAccountName = "testazureiac$($Stage)storacctf"
$containerName = "test-azure-iac-$($Stage)-tfstate"
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName -ErrorAction SilentlyContinue
if (!$storageAccount) {
    New-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName -Location "westeurope" -SkuName "Standard_LRS"
    $storageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $resourceGroupName -Name $storageAccountName)[0].Value
    $storageAccountContext = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $storageAccountKey
    $container = New-AzStorageContainer -Name $containerName -Context $storageAccountContext

    Write-Host "Storage account $($storageAccountName) and $($containerName) created successfully."
} 
else {
    Write-Host "Storage account already exists."
}