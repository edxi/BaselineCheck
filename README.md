# Widnows baseline check script

[![Build status](https://ci.appveyor.com/api/projects/status/kn804byw0r2viqpi?svg=true)](https://ci.appveyor.com/project/edxi/baselinecheck)

The purpose of this script which is provides windows baseline check functions.

## Features

* Compare pre-defined .xlsx file with DSCEA csv output to check baseline items.
* Find a Group Policy setting in an xml RSOP file.
* Compare GP settings.
  * To reads a given GP setting in a specifying format file.
  * Compare the GP setting items to check compliance.
* Invoke baseline check script.
  * To reads a given windows baseline scripts in a specifying format files.
  * Invoke scripts to compare target result to check compliance.
* Export compliance check to a report csv as a result.

## Examples

### Compare DSCEA csv out

This example shows fills up a predefined baseline excel file by following procedures:

1. Generate a .mof file by convert a GPO.
2. Scan the localhost by this .mof file and generate DSCEA .xml file.
3. Convert the .xml file to .csv report.
4. Compare the .csv report to fill up baseline excel.

```powershell
PS C:\Users\edxi> ConvertFrom-GPO -Path C:\baselinegpo\

    Directory: C:\Users\edxi\Output

Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-a----        2/25/2018  11:13 AM         253530 localhost.mof

PS C:\Users\edxi> Start-DSCEAscan -MofFile .\Output\localhost.mof -ComputerName localhost

    Directory: C:\Users\edxi

Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-a----        2/25/2018  11:14 AM        1147916 results.20180225-1113-42.xml

PS C:\Users\edxi> Convert-DSCEAresultsToCSV .\results.20180225-1113-42.xml

    Directory: C:\Users\edxi

Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-a----        2/25/2018  11:14 AM          40862 output.csv

PS C:\Users\edxi> Import-Module PSExcel
PS C:\Users\edxi> Compare-DSCEAcsv -xlsxfile C:\Users\edxi\baseline.xlsx -csvfile C:\Users\edxi\output.csv
```

As above procedure, at least following three external module is needed.

* The step 1 needs [BaselineManagement](https://github.com/Microsoft/BaselineManagement).
* Step 2 and 3 needs [DSCEA](https://github.com/Microsoft/DSCEA).
* Step 4 needs [PSExcel](https://github.com/RamblingCookieMonster/PSExcel).

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

As most of baseline setting is part of group policy, this function could call gpresult and compare generated xml with a predefined .csv file.
The predefined .csv file should includes at least four columns:

* `Extension` - Identify the extesion namespace.
* `Where` - Element name which looking for.
* `Is` - Element content which looking for.
* `Return` - Element content would be return.

```powershell
Compare-Rsop -csvfile c:\temp\baseline.csv
```

This will generate a report csv file in `$env:TEMP`, based on inputed c:\temp\baseline.csv file.

### Compare Script Output

Some baseline setting could only be checked by script.
A predefined .csv file should includes a column `Script` to store the script block.
The script block need return a hash object, includes:

* `Actual Value` - The script gets the actual avalue from system according to checking item.
* `Check Result` - As compared to baseline value, the result of compliance or not.

```powershell
Compare-ScriptOutput -csvfile c:\temp\baseline.csv
```

This will generate a report csv file in `$env:TEMP`, based on inputed c:\temp\baseline.csv file.

## Feedback

Please send your feedback to <https://github.com/edxi/BaselineCheck/issues>