@{
    # Some defaults for all dependencies
    PSDependOptions = @{
        Target = '$ENV:USERPROFILE\Documents\WindowsPowerShell\Modules'
        AddToPath = $True
        Parameters = @{
            Force = $True
        }
    }

    # Grab some modules without depending on PowerShellGet
    'psake' = @{ DependencyType = 'PSGalleryNuget' }
    'PSDeploy' = @{ DependencyType = 'PSGalleryNuget' }
    'BuildHelpers' = @{ DependencyType = 'PSGalleryNuget' }
    'Pester' = @{ DependencyType = 'PSGalleryNuget' }
    'BaselineManagement' = @{ DependencyType = 'PSGalleryNuget'; Version = '2.8.8815' }
    'DSCEA' = @{ DependencyType = 'PSGalleryNuget'; Version = '1.2.0.0' }
    'PSExcel' = @{ DependencyType = 'PSGalleryNuget'; Version = '1.0.2' }
}