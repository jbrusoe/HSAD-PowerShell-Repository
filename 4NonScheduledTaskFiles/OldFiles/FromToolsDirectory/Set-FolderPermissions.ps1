#get the current ACL and display the Access properties
get-acl C:\temp\lists.csv | select -ExpandProperty Access

#make the current ACL values a variable
$acl = get-acl "C:\temp"

#view the new variable values
$acl

#create a new variable with the new permissions to add. Note there are five properties in this: User, File System Rights, Inheritance flags (set to apply to 'This folder, subfolders and files'), Propagation flags, Access control type
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule ("HS\drodney-test","FullControl","ContainerInherit,ObjectInherit","None","Allow")

#View the new variable values
$Ar

#Combine the two variables, current permissions and new permissions, for the new full permissions to be applied
$acl.SetAccessRule($Ar)

#apply the combined new permissions
set-acl "C:\temp" $acl

#check permissions after the change
get-acl C:\temp\lists.csv | select -ExpandProperty Access