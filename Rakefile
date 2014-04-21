#!/usr/bin/env rake

desc "Default task"
task :default => :build

desc "delete the build dir"
task :clean do
  rm_rf '_site'
end

task :init => :clean do
  mkdir '_site'
end

task :build => :init do 
  sh 'bundle exec jekyll build'
end

task :deploy do
  sh 'rsync -avz _site/ www-data@iflowfor8hours.info:/var/www/iflowfor8hours.info/'
end
