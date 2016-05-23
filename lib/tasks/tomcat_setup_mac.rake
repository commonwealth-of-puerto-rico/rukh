namespace :tomcat do
  
  desc "Sets up Mac Homebrew's Tomcat server to handle Rails 4 JRuby apps."
  task :setup_mac do
    def edit(file, line_before, line_changed)
      old_content = File.read(file)
      if old_content[line_before]
        new_content = old_content.gsub(line_before, line_changed)
        File.open(file, "w+") do |f|
          f.write new_content
        end
      end
    end

    def create(file, content)
      File.open(file, "w+") do |f|
        f.write content
      end
    end

    def get_version
      version = Dir.entries("/usr/local/Cellar/tomcat/").last
      puts "Tomcat Version #{version}"
      fail unless version.match(/\A[0-9]+\.[0-9]+\.[0-9]+\z/)
      version
    end

    ## Task logic:
    version = get_version
    ## Below step may not be nescessary.
    create "/usr/local/Cellar/tomcat/#{version}/libexec/bin/setenv.sh",
      'CATALINA_OPTS="-XX:MaxPermSize=256M -XX:PermSize=256M -Xmx1024m"'

    ## Preserve the strange spacing below for matching purposes.
    edit "/usr/local/Cellar/tomcat/#{version}/libexec/conf/tomcat-users.xml",
'<!--
  <role rolename="tomcat"/>
  <role rolename="role1"/>
  <user username="tomcat" password="tomcat" roles="tomcat"/>
  <user username="both" password="tomcat" roles="tomcat,role1"/>
  <user username="role1" password="tomcat" roles="role1"/>
-->',
'<role rolename="tomcat"/>
<role rolename="role1"/>
<user username="tomcat" password="tomcat" roles="tomcat, manager-gui"/>
<user username="both" password="tomcat" roles="tomcat,role1"/>
<user username="role1" password="tomcat" roles="role1"/>'

    edit "/usr/local/Cellar/tomcat/#{version}/libexec/conf/tomcat-users.xml",
'<!--
  <role rolename="tomcat"/>
  <role rolename="role1"/>
  <user username="tomcat" password="<must-be-changed>" roles="tomcat"/>
  <user username="both" password="<must-be-changed>" roles="tomcat,role1"/>
  <user username="role1" password="<must-be-changed>" roles="role1"/>
-->',
'<role rolename="tomcat"/>
<role rolename="role1"/>
<user username="tomcat" password="tomcat" roles="tomcat, manager-gui"/>
<user username="both" password="tomcat" roles="tomcat,role1"/>
<user username="role1" password="tomcat" roles="role1"/>'

    edit "/usr/local/Cellar/tomcat/#{version}/libexec/webapps/manager/WEB-INF/web.xml",
      '<max-file-size>52428800</max-file-size>',  '<max-file-size>104857600</max-file-size>'
    edit "/usr/local/Cellar/tomcat/#{version}/libexec/webapps/manager/WEB-INF/web.xml",
      '<max-request-size>52428800</max-request-size>',  '<max-request-size>104857600</max-request-size>'
  end

  desc "Opens the relevant config files in mac or ubuntu."
  task :open_config do
    def get_os
      require 'rbconfig'
      host_os = RbConfig::CONFIG['host_os']
      case host_os
      when /darwin/, /Mac/
        :mac
      when /linux/
        distro = `python -c "import platform; print platform.dist()"`
        case distro
        when /ubutu/i
          :ubuntu
        else
          :linux
        end
      when /cygwin|mswin|mingw|bccwin|wince|emx/
        :windows
      when /solaris|bsd/
        :unix
      else
        fail "Couldn't recognize OS"
      end
    end
    os = get_os
    case os
    when :mac
      # Opens the configuration files for the latest tomcat version.
      version = Dir.entries("/usr/local/Cellar/tomcat/").last
      puts "Tomcat Version #{version}"
      fail unless version.match(/\A[0-9]+\.[0-9]+\.[0-9]+\z/)
      `open "/usr/local/Cellar/tomcat/#{version}/libexec/webapps/manager/WEB-INF/web.xml"`
      `open "/usr/local/Cellar/tomcat/#{version}/libexec/conf/tomcat-users.xml"`
      if Dir.entries("/usr/local/Cellar/tomcat/#{version}/libexec/bin/").include?("setenv.sh")
        `open "/usr/local/Cellar/tomcat/#{version}/libexec/bin/setenv.sh"`
      end
    when :ubuntu
      # Opens the configuration files for all tomcat versions installed.
      tomcat_vers = Dir.entries("/etc/").select {|x| x.match(/tomcat[0-9]+/) }
      editor = "nano"
      tomcat_vers.each do |tomcat_ver|
        if Dir.exists?("/usr/share/#{tomcat_ver}-admin")
          system "sudoedit /usr/share/#{tomcat_ver}-admin/manager/WEB-INF/web.xml"
        else
          puts "missing #{tomcat_ver}-admin package"
        end
        if Dir.exists?("atom /etc/default/#{tomcat_ver}")
          system "#{editor} /etc/default/#{tomcat_ver}/defaults.template"
        else
          puts "FYI: /etc/defalut/#{tomcat_ver} requires previledges."
          system "sudoedit /etc/default/#{tomcat_ver}"
        end
        puts "FYI: /etc/#{tomcat_ver}/tomcat-users.xml requires previledges."
        system "sudoedit /etc/#{tomcat_ver}/tomcat-users.xml"
      end
    else
      puts "OS #{os} not supported."
    end
  end
end
