
# Basically follow some net suggestion to do http-> https
# https://chooseprivacyeveryday.org/resources/https-lets-encrypt/recipe-for-lets-encrypt-on-windows-2008-iis-web-server/
# 1. Upgrade .NET Framework 4.5, and upgrade Windows Server to newest version so that it has TLS
# 2. Set IIS binding (http 80 *) to you host
# 3. Go to https://www.win-acme.com/ download win-acme zip, decomprss, and run wacs.exe on your Windows Server cmd

# 4. Restart IIS & Test your SSL: https://www.ssllabs.com/ssltest/analyze.html?d=YOUR_HOST

# Redirect all http request to https
# https://www.namecheap.com/support/knowledgebase/article.aspx/9953/38/iis-redirect-http-to-https/
# 5. Install IIS plugin: URL Rewrite follow suggestions on this site, or directly edit web.config file under c:\inetpub\wwwroot
<configuration>
   <system.webServer>
   <rewrite>
     <rules>
     <rule name="HTTPS force" enabled="true" stopProcessing="true">
       <match url="(.*)" />
       <conditions>
         <add input="{HTTPS}" pattern="^OFF$" />
       </conditions>
       <action type="Redirect" url="https://{HTTP_HOST}{REQUEST_URI}" redirectType="Permanent" />
     </rule>
     </rules>
   </rewrite>
   </system.webServer>
</configuration>

#6. Restart IIS.
