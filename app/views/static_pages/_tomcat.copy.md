# Procedimiento para hacer un deploy con Tomcat7 para Rails4 en windows & ubuntu

#### Procedure for a tomcat7 deploy on Windows & Ubuntu

## Server:
  
<!-- 2. NOT NEEDED Set `JRUBY_OPTS --2.0` in the **Environmental Variables**.  ('Control Panel > System > Advanced system settings >> Environmental Variables...').
  - *(En 'Control Panel > System > Advanced system settings >> Environmental Variables...' cree una nueva variable `JRUBY_OPTS` y en su valor ponga `--2.0`.  Este paso posiblemente no sea necesario con JRuby 9K en adelante.)*
  ![Environmental Variables][t1]
  Ubuntu/Mac: put this: `export JRUBY_OPTS=--2.0` in .bashrc/.bash_profile of the deploy user. -->
1. **Download:** [JDK7](http://www.oracle.com/technetwork/java/javase/downloads/index.html) + [tomcat7](http://tomcat.apache.org/download-70.cgi) + [JRuby 1.7.5 or later](http://www.jruby.org/download) + [Mariadb5.5](https://downloads.mariadb.org/) (or MySQL db or other db) & install them (see installation instructions).
  - *(Bajar el Java Development Kit 7 (mas reciente), tomcat 7, JRuby 1.7.5 o mas reciente (1.7.10 es el mas reciente) y Mariadb 5.5 (o MySQL) e instalalos (ver instruciones para instalación). )*
    
2. Download and install **Java Cryptographic Extensions (JCE)** security files for Java7 and  on your `jre7/lib/security` folder overwrite the `local_policy.jar` and `US_export_policy.jar`. In windows the JRE is located usually in `Program Files`.  
![Files to Replace][t2]
  - *(Bajar e instalar los JCE (Java Cryptographic Exentsions) del website de Oracle y remplazar los archivos indicados.)*  
  Ubuntu: if `which javac` is '/usr/bin/javac' then`echo $(readlink -f /usr/bin/javac | sed "s:bin/javac::")` produces the Java Home path. Switch to that directory and then drill into `jre/lib/security` from there. Typically: `/usr/lib/jvm/java-7-openjdk-amd64/jre/lib/security/`  
  Mac: Execute `/usr/libexec/java_home` to find Java Home. Switch to that directory and then drill into `jre/lib/security` from there.  
  
3. **NO SPACES** on path for Tomcat!!! (no # either) (Windows limitation)
  - *(El path para la instalacion de tomcat no puede tener espacios ni caracteres especiales. Esto es una limitación de Windows.)*
  
5. Set **Tomcat server Heap memory** up on the Java tab in Windows (Rails 4.1 requirement). 
   - `-XX:MaxPermSize=256M`
   - `-XX:PermSize=256M`
   - `-Xmx1024m` (possibly can be lower, like 512m)
   - `-Dfile.encoding=UTF-8` (windows only for UTF-8 compatibility)
     - *(Cambiar el setting de 'Heap Memory' en el tab de Java en la aplicación para el monitoreo de Tomcat (Windows) o en la configuración de Java. La ultima opción es particularmente importante para Rails 4.1 y Ubuntu.)*  
     ![Tomcat Windows Java Config][t3]  
  Ubuntu: Tomcat Heap Memory in `sudoedit /etc/default/tomcat7` or in `/etc/default/tomcat7/defaults.template`.
  Mac: edit `/usr/local/Cellar/tomcat/{{ version }}/libexec/bin/catalina.sh`
     
6. Set up the **admin user** for Tomcat. In tomcat/conf/tomcat-users.xml set up the following lines: ![Tomcat User Settings][t4]  Please note: the orginal file will have sample users, but they'll be wrapped in a comment! Remember to add the rolename ("tomcat,manager-gui") part as well.  
   - *(Cree el usuario 'admin' y añadale el rol de "tomcat,manager-gui" en tomcat-users.xml.)*
   - Ubuntu:`sudoedit /etc/tomcat7/tomcat-users.xml`
   - Mac Homebrew: `vim /usr/local/Cellar/tomcat/{{version}}/libexec/conf/tomcat-users.xml`

7. Increase tomcat7 manager's war deploy size if you want to deploy from the admin gui.
    `tomcat7/webapps/manager/WEB-INF/web.xml`
    
    Ubuntu: `/usr/share/tomcat7-admin/manager/WEB-INF/web.xml` and `/var/lib/tomcat7/webapps` for webapps
    Mac Homebrew: `/usr/local/Cellar/tomcat/{{version}}/libexec/webapps/manager/WEB-INF/web.xml`

8. Run **`jruby -S bundle exec rake db:create db:schema:load RAILS_ENV=production`** (this command can be run from the dev computer if it's in the same network and can connect to the database.) If run on the production machine it must me run on the directory with the application's Rake file:`<tomcat location>/webapps/<app name>/WEB-INF/`. 
  - *(Corra el commando para crear la base de datos. El commando debe correr del archivo localizado en `<tomcat location>/webapps/<app name>/WEB-INF/` que es donde esta localizado el Rakefile.)*
  - Ubuntu: Webapps located: `/var/lib/tomcat7/webapps`
  - Mac Homebrew: Webapps located: `/usr/local/Cellar/tomcat/{{version}}/libexec/webapps`
   
Notes/Notas:  
- War files are located in `/var/lib/tomcat7/webapps` in Ubuntu.
- Tomcat logs are located in `/var/lib/tomcat7/logs` in Ubuntu and `/usr/local/Cellar/tomcat/{{ version }}/libexec/logs` in Mac Homebrew
 
#### Pound
Pound is a reverse proxy. It can be used to resolve the https certificates (if needed) and forward port 80 calls to port 8080 of tomcat. If you have more than one server it can serve as a rudimentary load balancer. 

1. `sudoedit /etc/pound/pound.cfg`
ListenHTTP is the ip and port it listens on. Use port '80'.
Service Backend (there can be more than one) is the server. Use port '8080'. Specify a Priority if using more than one.
2. `sudoedit /etc/default/pound`
Change `startup=0` to `startup=1`
3. `sudo service pound start`
 
Pound can also handle certificates. 

#### Certificates for https with pound
[How To link](http://www.project-open.org/en/howto_pound_https_configuration)
 
### En la maquina de deploy  

1. Utilize Warble 1.4.5 o mas reciente
2. Cree un web.xml para que se copie -- no lo deje autogenerar.
3. Run JRuby Lint to find issues
4. Cambie las configuraciones para usar heroku settins en:
  - Gemfile
  - config/database.yml
  - config/application.rb:  
    ```
    # For Warble
    config.assets.enabled = true
    config.assets.initialize_on_precompile = false
    ```

  
Notes/Notas:

Ubuntu: `sudo service tomcat7 {stop|start|restart}`
Ubuntu: ROOT is in `/var/lib/tomcat7/ROOT`
Ubuntu: Logs are in `/var/log/tomcat7/`
Mac Homebrew: `catalina {run|stop|start|restart}`
Mac Homebrew: ROOT is in `/usr/local/Cellar/tomcat/{{version}}/libexec/webapps/ROOT`
Mac Homebrew: Logs are in `/usr/local/Cellar/tomcat/{{version}}/libexec/logs`


#### Usando Tomcat en Mac con Homebrew
`hombrew install tomcat`

Verifica con 
`catalina -h` & `catalina run`
To start/stop the server from the command line you use the catalina shell script:

`$ /usr/local/Cellar/tomcat/{{version}}/bin/catalina run`  
`$ /usr/local/Cellar/tomcat/{{version}}/bin/catalina stop`


¿Donde esta el directorio webapps? 
`/usr/local/Cellar/tomcat/{{version}}/libexec/webapps/`

# Setting up the SMTP relay (for sending emails)
If your SMTP is on a windows server you must add the ip of the server running tomcat to the whitelist of relays for SMTP.
Control Panel > Administrative Tools > IIS (Internet Info Server) > Default SMTP Virtual Server (Right Click)  
|+> Properties  
|+++> Access (Tab)  
|++++++> Relay   


<!-- [t1]:<%= asset_path('environmental_variables.png') %> "Environmental Variables" -->
[t2]: <%= asset_path('JCE_replace_files.png') %> "JCE replace files"
[t3]: <%= asset_path('tomcat_config_windows.png') %> "Tomcat Windows Java Config" 
[t4]: <%= asset_path('tomcatuserssettings.png') %> "Tomcat User Settings"


