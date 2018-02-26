Function Get-ExcelColumnInt
{   # http://stackoverflow.com/questions/667802/what-is-the-algorithm-to-convert-an-excel-column-letter-into-its-number
	[cmdletbinding()]
	param($ColumnName)
	[int]$Sum = 0
	for ($i = 0; $i -lt $ColumnName.Length; $i++)
	{
		$sum *= 26
		$sum += ($ColumnName[$i] - 65 + 1)
	}
	$sum
	Write-Verbose "Translated $ColumnName to $Sum"
}
