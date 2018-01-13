# Widnows baseline check script

[![Build status](https://ci.appveyor.com/api/projects/status/kn804byw0r2viqpi?svg=true)](https://ci.appveyor.com/project/edxi/baselinecheck)

The purpose of this script which is provides windows baseline check functions.

## Features

* Find a Group Policy setting in an xml RSOP file.
* Compare GP settings.
  * To reads a given GP setting in a specifying format file.
  * Compare the GP setting items to check compliance.
* Invoke baseline check script. (in progress...)
  * To reads a given windows baseline scripts in a specifying format files.
  * Invoke scripts to compare target result to check compliance.
* Export compliance check to a report csv as a result. (in progress)

## Examples

### Find a GP setting

The `Find-RsopSetting` command refered a [technet blog](https://blogs.technet.microsoft.com/grouppolicy/2009/04/14/check-a-setting-in-all-gpos-security-admx-and-more/#comments), and rewrited xml namespaces to find RSOP xml file.
To find a setting in gpresult xml like following file fragment:

```xml
<ExtensionData>
    <Extension xmlns:q3="http://www.microsoft.com/GroupPolicy/Settings/Auditing" xsi:type="q3:AuditSettings" xmlns="http://www.microsoft.com/GroupPolicy/Settings">
    <q3:AuditSetting>
        <GPO xmlns="http://www.microsoft.com/GroupPolicy/Settings/Base">
            <Identifier xmlns="http://www.microsoft.com/GroupPolicy/Types">{A70D46E4-33C8-480F-B946-C857F880CA25}</Identifier>
            <Domain xmlns="http://www.microsoft.com/GroupPolicy/Types">dir.saicgmac.com</Domain>
        </GPO>
        <Precedence xmlns="http://www.microsoft.com/GroupPolicy/Settings/Base">1</Precedence>
        <q3:PolicyTarget>System</q3:PolicyTarget>
        <q3:SubcategoryName>Audit File Share</q3:SubcategoryName>
        <q3:SubcategoryGuid>{0cce9224-69ae-11d9-bed3-505054503030}</q3:SubcategoryGuid>
        <q3:SettingValue>3</q3:SettingValue>
    </q3:AuditSetting>
    <Name xmlns="http://www.microsoft.com/GroupPolicy/Settings">Advanced Audit Configuration</Name>
</ExtensionData>
```

Above is a computer setting of `Auditing`, which could be located by xml namespace.
Using the `Find-RsopSetting`, enter where the setting is (`-isComputerConfiguration $true`) by default, what type of setting it is (`-Extension Auditing`), and what value you’re looking for (`-Where Auditing –Is SubcategoryName`). If you want to know that the setting is configured in the GPO, but you don’t care what the value is, omit the `–Return` parameter.

* To check if element `SubcategoryName` is `Audit File Share`. The following command should return `True`.

```powershell
Find-RsopSetting -rsopxml $rsopxml -Extension 'Auditing' -Where 'SubcategoryName' -Is 'Audit File Share'
```

* To check if element `SubcategoryName` is `Audit File Share`. And return The element content of `SettingValue`. The following command should return `3`.

```powershell
Find-RsopSetting -rsopxml $rsopxml -Extension 'Auditing' -Where 'SubcategoryName' -Is 'Audit File Share' -Return 'SettingValue'
```

### Compare RSOP Items

Writing Compare-Rsop.ps1 In progress...

## Feedback

Please send your feedback to <https://github.com/edxi/BaselineCheck/issues>