# frozen_string_literal: true

namespace :tomcat do
  desc "Starts Tomcat Server on Mac with 'catalina run'"
  task :run_mac do
    puts 'Starting Tomcat Server on port 8080'
    puts 'Manager app at: http://localhost:8080/manager/html'
    puts 'Hit Ctrl+C to stop'
    `catalina run`
  end
end
