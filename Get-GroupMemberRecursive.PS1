function Get-GroupMemberRecursive{
<#
.SYNOPSIS
    Return a hash contains nested group members(Group Object ) of a given windows AD group
.DESCRIPTION
    The Get-GroupMemberRecursive function return all nested group members(exclude user member) of a AD group to a hash.
    Its performance is much better than those functions that use built-in Get-ADGroupMember.
    and also it can avoid nested loop. for e.g. Group B is member of C and C is member of B.
    It requires a valid AD group parameter and a hash variable parameter.
    For e.g. There are 4 Groups A,B,C,D.A contains B & C, B contains D. 
    Given a $MyHash hash variable. run below ,
    Get-GroupMemberRecursive -GroupName A -Hash $MyHash
    $MyHash
    Key: value
    A:{B,C}
    B:{D}
    C:{$null}
    D:{$null}
.PARAMETER GroupName
    Prompts you valid active directory group name. You can use P1 as an alias.
    The parameter can be a single string.
.PARAMETER Hash
    Prompts you a ordered hash variable. This hash variable is passed to functions by reference.
.NOTES
    Version:        1.0
    Author:         ggcjdsh
    Creation Date:  21 Apr 2022
    Purpose/Change: Get the nested group members(Group object) info of a given AD group    
.EXAMPLE
    $MyHash=[ordered]@{}
    Get-GroupMemberRecursive -GroupName "Domain Admins" -Hash  $MyHash
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
                   HelpMessage='Type valid AD group,could be 1 group name string')]
                   [Alias("p1")]
                   [AllowNull()]
        $GroupName,
        $Hash
    )


$groupDN =(get-adgroup $groupname).DistinguishedName
$filter = "(&(memberof:1.2.840.113556.1.4.1941:=$groupDN))"
$filter_OneLevel = "(&(memberof=$groupDN))"
$subtree= get-adgroup -ldapfilter $filter



$hash[$groupname] = (get-adgroup -ldapfilter $filter_OneLevel).name
Write-Verbose "group   :   Member"
Write-Verbose "$GroupName  : $OneLevel"

# this foreach loop to avoid nested loop. for e.g. Group B is member of C and C is member of B
foreach ($member in $k) {
                $UpperGroup = Get-ADGroup $member -Properties Memberof
                $filter_OneLevel2 = "(&(memberof=$UpperGroup))"
                $LowerGroup = get-adgroup -ldapfilter $filter_OneLevel2
                $LoopCheck = $UpperGroup.MemberOf | ForEach-Object {$lowerGroup.distinguishedName -contains $_}
            
                if ($LoopCheck -Contains $True) {
                    $rootname = $UpperGroup.Name
                    $hash[$member.name]=$lowergroup.name
                    Write-Warning "Loop found on $($UpperGroup.Name), Skipping..." 
                    Continue
                }
               Write-Verbose "$($member.name) : $($lowergroup.name) "
                $hash[$member.name]=$lowergroup.name
        } 

       # $hash
        

        }

#example
$MyHash=[ordered]@{}

Get-GroupMemberRecursive -GroupName "grpl1" -Hash $MyHash -Verbose
$MyHash
#help Get-GroupMemberRecursive 
