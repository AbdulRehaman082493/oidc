@description('Name of the storage account. Must be globally unique.')
param storageAccountName string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('SKU of the Storage Account.')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
])
param skuName string = 'Standard_LRS'

@description('Kind of the Storage Account.')
@allowed([
  'StorageV2'
  'Storage'
  'BlobStorage'
  'FileStorage'
  'BlockBlobStorage'
])
param kind string = 'StorageV2'

@description('Enable hierarchical namespace for Data Lake Gen2.')
param isHnsEnabled bool = false

@description('Network rule set for the storage account.')
param networkAcls object = {
  bypass: 'AzureServices'
  defaultAction: 'Deny'
  ipRules: []
  virtualNetworkRules: []
}

@description('Tags to apply to the storage account.')
param tags object = {
  environment: 'dev'
  owner: 'Abdul'
}

resource stg 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: skuName
  }
  kind: kind
  tags: tags
  properties: {
    isHnsEnabled: isHnsEnabled

    networkAcls: networkAcls

    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    allowSharedKeyAccess: true
    supportsHttpsTrafficOnly: true

    // Enable recommended security defaults
    encryption: {
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }

    accessTier: 'Hot'
  }
}

output storageAccountId string = stg.id
output storageAccountNameOut string = stg.name
output primaryEndpoints object = stg.properties.primaryEndpoints
