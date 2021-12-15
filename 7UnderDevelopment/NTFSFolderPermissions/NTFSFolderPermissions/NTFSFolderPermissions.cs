using System;
using System.IO;
using System.Security.AccessControl;
using System.Security.Principal;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NTFSFolderPermissions
{
    class NTFSFolderPermissions
    {
        static void Main(string[] args)
        {
            //string DirectoryToSearch = @"c:\users\jeff\";
            string DirectoryToSearch = @"\\hsazuredc1\admin$";

            Console.WriteLine("C# Version of Get-NTFSFolderPermission.ps1");
            Console.WriteLine("Direcdtory to Search: " + DirectoryToSearch);

            GetDirectories(DirectoryToSearch);

            Console.ReadLine();
        }

        private static void GetDirectories(string strPath)
        {
            try 
            {
                string[] Directories = Directory.GetDirectories(strPath);

                foreach (string DirectoryToSearch in Directories)
                {
                    Console.WriteLine(DirectoryToSearch);

                    DirectorySecurity DirSecurity = Directory.GetAccessControl(strPath);
                    Console.WriteLine(DirSecurity.GetAccessRules(true, true, typeof(NTAccount)));
                    //foreach (FileSystemAccessRule rule in DirSecurity.GetAccessRules(true, true, typeof(NTAccount)))
                    //{
                    //    Console.
                    //    Console.WriteLine(rule.IdentityReference.Value);
                    //}

                    GetDirectories(DirectoryToSearch);

                    Console.WriteLine("****************************");
                }
            }
            catch (Exception e)
            {
              //  Block of code to handle errors
            }

            Console.WriteLine("Done");
            
        }
    }
}
