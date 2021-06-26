# KeyPresser

##### Version: 1.0.4 

## How to use 

#PS1
1. Open a powershell window
2. Run the following command 
   * Start-Process Powershell -Verb runAs -ArgumentList "-Command Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/DeveloperDurp/KeyPresser/main/KeyPresser.ps1'))" 

3. Enjoy
