#Current Filter:
#((((((((((((((((((((((((((((((((((((((((((((CustomAttribute7 -eq 'Yes365') -and (RecipientType -eq 'UserMailbox'))) -and (-not(RecipientTypeDetailsValue -eq 'SharedMailbox')))) -and (-not(RecipientTypeDetailsValue -eq 'RoomMailbox')))) -and (-not(Name -like 'SystemMailbox{*')))) -and (-not(Name -like 'CAS_{*')))) -and (-not(RecipientTypeDetailsValue -eq 'MailboxPlan')))) -and (-not(RecipientTypeDetailsValue -eq 'DiscoveryMailbox')))) -and (-not(RecipientTypeDetailsValue -eq 'PublicFolderMailbox')))) -and (-not(RecipientTypeDetailsValue -eq 'ArbitrationMailbox')))) -and (-not(RecipientTypeDetailsValue -eq 'AuditLogMailbox')))) -and (-not(RecipientTypeDetailsValue -eq 'AuxAuditLogMailbox')))) -and (-not(RecipientTypeDetailsValue -eq 'SupervisoryReviewPolicyMailbox')))) -and (-not(Name -like 'SystemMailbox{*')))) -and (-not(Name -like 'CAS_{*')))) -and (-not(RecipientTypeDetailsValue -eq 'MailboxPlan')))) -and (-not(RecipientTypeDetailsValue -eq 'DiscoveryMailbox')))) -and (-not(RecipientTypeDetailsValue -eq 'PublicFolderMailbox')))) -and (-not(RecipientTypeDetailsValue -eq 'ArbitrationMailbox')))) -and (-not(RecipientTypeDetailsValue -eq 'AuditLogMailbox')))) -and (-not(RecipientTypeDetailsValue -eq 'AuxAuditLogMailbox')))) -and (-not(RecipientTypeDetailsValue -eq 'SupervisoryReviewPolicyMailbox')))) -and (-not(Name -like 'SystemMailbox{*')) -and (-not(Name -like 'CAS_{*')) -and (-not(RecipientTypeDetailsValue -eq 'MailboxPlan')) -and (-not(RecipientTypeDetailsValue -eq 'DiscoveryMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'PublicFolderMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'ArbitrationMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'AuditLogMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'AuxAuditLogMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'SupervisoryReviewPolicyMailbox')))
#$NotRecipientTypeDetailsValue = @("SharedMailbox","RoomMailbox")
#$AllUsersFilter = "(((((((((((((((((((((((((((((((((((((((((((
#                (CustomAttribute7 -eq 'Yes365') -and
#                (RecipientType -eq 'UserMailbox'))) -and
#                (-not(RecipientTypeDetailsValue -eq 'SharedMailbox')))) -and (-not(RecipientTypeDetailsValue -eq 'RoomMailbox')))) -and (-not(Name -like 'SystemMailbox{*')))) -and (-not(Name -like 'CAS_{*')))) -and (-not(RecipientTypeDetailsValue -eq 'MailboxPlan')))) -and (-not(RecipientTypeDetailsValue -eq 'DiscoveryMailbox')))) -and (-not(RecipientTypeDetailsValue -eq 'PublicFolderMailbox')))) -and (-not(RecipientTypeDetailsValue -eq 'ArbitrationMailbox')))) -and (-not(RecipientTypeDetailsValue -eq 'AuditLogMailbox')))) -and (-not(RecipientTypeDetailsValue -eq 'AuxAuditLogMailbox')))) -and (-not(RecipientTypeDetailsValue -eq 'SupervisoryReviewPolicyMailbox')))) -and (-not(Name -like 'SystemMailbox{*')))) -and (-not(Name -like 'CAS_{*')))) -and (-not(RecipientTypeDetailsValue -eq 'MailboxPlan')))) -and (-not(RecipientTypeDetailsValue -eq 'DiscoveryMailbox')))) -and (-not(RecipientTypeDetailsValue -eq 'PublicFolderMailbox')))) -and (-not(RecipientTypeDetailsValue -eq 'ArbitrationMailbox')))) -and (-not(RecipientTypeDetailsValue -eq 'AuditLogMailbox')))) -and (-not(RecipientTypeDetailsValue -eq 'AuxAuditLogMailbox')))) -and (-not(RecipientTypeDetailsValue -eq 'SupervisoryReviewPolicyMailbox')))) -and (-not(Name -like 'SystemMailbox{*')) -and (-not(Name -like 'CAS_{*')) -and (-not(RecipientTypeDetailsValue -eq 'MailboxPlan')) -and (-not(RecipientTypeDetailsValue -eq 'DiscoveryMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'PublicFolderMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'ArbitrationMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'AuditLogMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'AuxAuditLogMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'SupervisoryReviewPolicyMailbox')))"


$MailBoxFilter = "((CustomAttribute7 -eq 'Yes365') -and" +
"(RecipientType -eq 'UserMailbox') -and" +
"(-not(RecipientTypeDetailsValue -eq 'SharedMailbox')) -and" +
"(-not(RecipientTypeDetailsValue -eq 'RoomMailbox')) -and" +
"(-not(Name -like 'SystemMailbox{*')) -and" +
"(-not(Name -like 'CAS_{*')) -and" +
"(-not(RecipientTypeDetailsValue -eq 'MailboxPlan')) -and" +
"(-not(RecipientTypeDetailsValue -eq 'DiscoveryMailbox')) -and" +
"(-not(RecipientTypeDetailsValue -eq 'PublicFolderMailbox')) -and" +
"(-not(RecipientTypeDetailsValue -eq 'ArbitrationMailbox')) -and" +
"(-not(RecipientTypeDetailsValue -eq 'AuditLogMailbox')) -and" +
"(-not(RecipientTypeDetailsValue -eq 'AuxAuditLogMailbox')) -and" +
"(-not(RecipientTypeDetailsValue -eq 'SupervisoryReviewPolicyMailbox')))"

$WVUMGroup = "(PrimarySMTPAddress -eq 'WVUMSharedUsersGroup@hsc.wvu.edu')"

$NewAllUsersFilter = "$MailboxFilter -or $WVUMGroup"
Write-Output "NewAllUsersFilter: $NewAllUsersFilter"