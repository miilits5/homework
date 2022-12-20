Logic of script:
1) Running script.bat checks if you are using linux or powershell
2) IF linux is detected it checks that openssl is present before continuing. If present, openssl is used with input from the user to generate a private key and CSR. The end result is displayed to the user.
3) IF powershell is detected then a prompt is shown from where the user can pick between CSR generation with Openssl or certreq. The third choice is generating a self-signed certificated and after that an end-endity certificated is issued using the same root self-signed certificate. After which it exports all the keys and certificates from the chain. If any other pkcs* tool would need to be used to generate the key or issue csr-s then that would need additional testing and implementation.

If I would put 10-20 more time to improve the script, everything would be commented, in git, all the authors I used the scripts from referenced and as a single script with non-recurring variables. But as for now I think that the requirements are set.

These scripts have been tested and are working on Ubuntu 22.04 LTS (WSL 2.0) and PSVersion 5.1.19041.2364 on Windows 10
Adding Read & Execute rights to the scripts is mandatory. 

RUN runthis.ps1 in both Linux and Powershell