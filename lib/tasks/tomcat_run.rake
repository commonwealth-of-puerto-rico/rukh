# frozen_string_literal: true

namespace :tomcat do
  desc "Starts Tomcat Server on Mac with 'catalina run'"
  task :run_mac do
    `catalina run`
  end
end
