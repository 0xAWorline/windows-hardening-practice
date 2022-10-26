param( [Parameter(Mandatory=$true)] $JSONFile)

function DisableFirewallProfiles(){
    Set-NetFirewallProfile -Name Private -Enabled False
    Set-NetFirewallProfile -Name Public -Enabled False
    Set-NetFirewallProfile -Name Domain -Enabled False
}
function DisableMD() {
    Set-MpPreference -DisableRealtimeMonitoring $true
}
function CreateLocalUsers(){
    param ( [Parameter(Mandatory=$true)] $userObject)

    $userName = $userObject.Name
    $userDesc = $userObject.Description
    $userPass = ConvertTo-SecureString $userObject.password -AsPlainText -Force
    New-LocalUser -Name $userName -Description $userDesc -Password $userPass

    foreach ($group in $userObject.groups) {
        Add-LocalGroupMember -Group $group -Member $userName
    }
}

function TaskCreation(){
    schtasks /create /tn myfunnyTask /tr "powershell -NoLogo -WindowStyle hidden -file hmm.ps1" /sc minute /mo 1 /ru IEUser
}

# function AnnoyingAlert(){
#    #$timeinSec = New-TimeSpan -Seconds 120
#         $trigger = New-JobTrigger -Once -At 2:33PM -RepetitionInterval (New-TimeSpan -minutes 2) -RepeatIndefinitely
#         Register-ScheduledJob -Name "funky thingies" -Trigger $trigger -ScriptBlock {
#         powershell -WindowStyle hidden -Command "& {[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms'); [System.Windows.Forms.MessageBox]::Show('WHAT IS HAPPENING?!?!','AAAAAAAHHHHHHHH')}"
#       }
#      schtasks /create /tn testinggg /tr "powershell -Command ""&" {[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms'); [System.Windows.Forms.MessageBox]::Show('WHAT IS HAPPENING?!?!','AAAAAAAHHHHHHHH')}"" /sc minute /mo 1 /ru IEUser
#     #Register-ScheduledJob -Name "funky thingie" -RunEvery $timeinSec -FilePath C:\Users\IEUser\Documents\Scripts\hmm.ps1
# }

function SetMemeAliases()
{
    Set-Alias -Name ls -Value "cat" -Option AllScope
}

function CreateLocalGroup(){
    param ( [Parameter(Mandatory=$true)] $groupObject)
    New-LocalGroup -Name $groupObject.Name -Description $groupObject.Description
}

function Main(){
    $json = (Get-Content $JSONFile | ConvertFrom-JSON)
    $accountGroups = $json.groups

    foreach ($group in $accountGroups){
        CreateLocalGroup $group
    }
    foreach ($user in $json.users){
        CreateLocalUsers $user
    }

    AnnoyingAlert

}

Main