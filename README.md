# CodeSigning Demo

[![Build Status](https://ukhogov.visualstudio.com/Pipelines/_apis/build/status/UKHO.CodeSigning-Demo?branchName=master)](https://ukhogov.visualstudio.com/Pipelines/_build/latest?definitionId=108&branchName=master)

A demo project containing an example .Net Core class library. The Azure Pipeline steps build the project and signs a specific DLL using a code signing certificate that was stored in Azure Key Vault.

## Background

Code signing certificates need to be stored at FIPS 140-2 Level 2 or above. A common solution is using a USB token but that makes CI/CD automation difficult if build agents are cloud hosted.

This demo takes advantage of Azure Key Vault which uses FIPS 140-2 Level 2 validated HSMs to store the certificate and then utilise it in an Azure Pipeline.

## Overview of the build

- Build the project
  - This should use `--out` to send resulting DLLs elsewhere.
- Download the PFX from KeyVault
  - The secretsFilter is set to the name of the code signing certificate, so only the certificate is downloaded
  - The name of the Key Vault and SecretsFilter are secret variables set in the definition
  - The property `azureSubscription` is the AzureRM Service Connection name which needs to be created. This isn't a secret variable.
- Turn the code signing certificate into a .pfx
  - The powershell script saves the certificate to the file system and creates a build variable called `pfxOutLocation` with the location of the .pfx on the filesystem.
  - Secrets downloaded from Key Vault using the `AzureKeyVault` Azure Pipelines task are passed as a Base64 encoded string. This means they cannot be used directly to sign code and needs to be saved to the filesystem first as a .pfx
  - The password mapped is a secret variable set in the definition. This is the password that will be set for the .pfx when it is saved to the filesystem.
- Sign a single binary
  - Uses the SignTool to sign, using SHA1. You can use alternative methods for signing and should use SHA256.
  - As this is only a demo, we only sign a single binary.
  - The password mapped for this step is the same as used in the previous step. The password is used by the sign tool to access the certificate.
- Publish to inspect the signed DLL
- Delete the PFX to ensure it doesn't remain on disk.

## Dependencies

- An Azure KeyVault containing the Code Signing Certificate
- An [AzureRM Service Connection](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/connect-to-azure?view=azure-devops) in Azure Pipelines. The Service Principal used must have at least read access to the Azure KeyVault.

## Getting the certificate into Azure KeyVault

The basic process is to create the private key and CSR in Azure KeyVault, then use the CSR to generate the certificate through your Certificate Authority. The resulting certificate can then be uploaded to Azure KeyVault.

We used GlobalSign our as CA, not all allow this approach.

## Links

- [Create private key csr and import to Microsoft Azure](https://web.archive.org/web/20190812145559/https://www.entrustdatacard.com/knowledgebase/create-private-key-csr-import-microsoft-azure-hsm)
  - Use steps two and three. This tutorial uses AzureRm.
- [Create a csr or upload a certificate](https://github.com/dotnet/SignService/blob/master/docs/Administration.md#create-a-csr-or-upload-a-certificate)
  - Gives guidance on how to do this through the Azure Portal.
- [GlobalSign article on how to download a certificate for storing in a HSM](https://support.globalsign.com/customer/portal/articles/2844591)
  - To buy a certificate that could be uploaded into a HSM, we had to contact support for the option to be enabled. By default you can only buy them on USB tokens.
