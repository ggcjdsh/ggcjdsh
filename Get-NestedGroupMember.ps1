function Get-NestedGroupMember{
<#
.SYNOPSIS
    Return a hash contains nested group members(Group Object ) of a given windows AD group
.DESCRIPTION
    The Get-NestedGroupMember function return all nested group members of a AD group to a hash.
    It requires a valid AD group parameter and a hash variable parameter.
    For e.g. There are 4 Groups A,B,C,D.A contains B & C, B contains D. 
    Given a $MyHash hash variable. run below ,
    Get-NestedGroupMember -GroupName A -Hash $MyHash
    $MyHash
    Key: value
    A:{B,C}
    B:{D}
    C:{$null}
    D:{$null}
.PARAMETER GroupName
    Prompts you valid active directory group name. You can use P1 as an alias.
    The parameter can be a single string or string array.
.PARAMETER Hash
    Prompts you a ordered hash variable. This hash variable is passed to functions by reference.
.NOTES
    Version:        1.0
    Author:         ggcjdsh
    Creation Date:  19 Apr 2022
    Purpose/Change: Get the nested group members(Group object) info of a given AD group    
.EXAMPLE
    $MyHash=[ordered]@{}
    Get-NestedGroupMember -GroupName "Domain Admins" -Hash  $MyHash
    This $MyHash will get all nested group members. Parent group name as key, group member as value.
    For e.g. There are 4 Groups A,B,C,D,A contains B & C, B contains C. 
    Given a $MyHash hash variable. run below ,
    Get-NestedGroupMember -GroupName A -Hash $MyHash
    $MyHash
    Key: value
    A:{B,C}
    B:{D}
    C:{$null}
    D:{$null}

#>
[CmdletBinding()]
param(
        [Parameter(Mandatory=$true,
                   HelpMessage='Type valid AD group,could be 1 group name or string array')]
                   [Alias("p1")]
                   [AllowNull()]
        $GroupName,
        $Hash
    )
# combine child group members of each group in groupnames array
[Microsoft.ActiveDirectory.Management.ADGroup[]]$total = $null
if ($GroupName.count -gt 0)
    {
      # tempoary array to store child group names.
      $array=@()
      $GroupName| % {
             write-verbose "Working on AD group: $_"
            $groupDN =(get-adgroup $_).DistinguishedName
            $temp=$_.name
            

            $filter = "(&(memberof=$groupDN))"
            $k= get-adgroup -ldapfilter $filter
            $array+=$k.Name

            $total += $k
           
           
            # if only 1 group, group.name will be null
            if ($temp -eq $null ){
                        $hash[$_]=$array
                        Write-Verbose "Genearte Hash key:$_ and value: $array"
                } 
                else {
                    
                     $hash[$temp]=$array
                    Write-Verbose "Genearte Hash key:$temp and value: $array"
                }
            
            # clear up temporary array
            $array=@()

           
        }

  
      
    Write-Verbose "Enter next recursive with  parameter: $total"
    return Get-NestedGroupMember -GroupName $total -Hash $hash
  }
else {
        
  
        return $null,$hash
        }
}


# example
$MyHash=[ordered]@{}
$grps = ("grpl1")
get-childgroup -GroupName $grps -Hash $MyHash | Out-Null
