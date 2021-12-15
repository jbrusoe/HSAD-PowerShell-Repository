## HSC PowerShell Modules

This directory contains all of the HSC PowerShell modules (.psm1) and module manifests (.psd1) that are referenced by other files. The PSModulePath on the server should point to the local path. Doing this will allow the modules in this directory to be used without having to run Import-Module<br>.

Modules currently in this directory include:
* HSC-ActiveDirectoryModule.psm1
* HSC-CommonCodeModule.psm1
* HSC-Office365Module.psm1
