namespace :setup do
  
  desc "Sets up the secret files after a git clone."
  task :secret_files do
    def edit(file, line_old, line_changed)
      old_content = File.read(file)
      if old_content[line_old]
        new_content = old_content.gsub(line_old, line_changed)
        File.open(file, "w+") do |f|
          f.write new_content
        end
      end
    end
    
    def copy(filename, filename2)
      fail "Could not locate #{filename}." unless File.exist? filename
      fail "File #{filename2} already exists." if File.exist? filename2
      FileUtils.cp filename, filename2
    end
    
    def secret_key
      secret = `rake secret`
      fail unless $?.exitstatus == 0
      puts secret
      secret.chomp
    end
    
    copy "config/database.yml.txt", "config/database.yml"
    copy "config/secrets.yml.txt",  "config/secrets.yml"

    edit "config/secrets.yml",
"development:
  secret_key_base: 
  salt: 
  secret_token: 
  devise_secret_key:

test:
  secret_key_base: 
  salt: 
",
"development:
  secret_key_base: #{secret_key}
  salt: #{rand 9}
  secret_token: #{rand 9}
  devise_secret_key: #{secret_key}

test:
  secret_key_base: #{secret_key}
  salt: #{rand 9}
"
    edit "config/secrets.yml",
"production:
  secret_key_base: 
  salt: 0",
"production:
  secret_key_base: #{secret_key}
  salt: #{rand 9}"

  end
  
end
