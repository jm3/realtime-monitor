require 'capistrano_colors'

set :application, "realtime-monitor"
set :deploy_to,   "/var/www/#{application}"
set :deploy_via,  :export
set :port,        9210
set :repository,  "git@github.com:jm3/#{application}.git"
set :scm,         :git
set :use_sudo,    false

server "#{application}", :app, :web, :db, :primary => true

before "deploy:update", "git:uncommitted"
after "deploy:update_code", "nerd:bundle"
#after "deploy:update_code", "nerd:declinate_ownership"
after "deploy", "deploy:cleanup"

deploy.task :restart, :roles => :app do
  run "touch #{current_path}/tmp/restart.txt"
  run "ln -s #{deploy_to}/shared/media #{current_path}/public/media"
end

namespace :git do
  desc "check for uncommitted files"
  task :uncommitted do
    output = `git status | egrep -i 'delete|modified|Untracked|branch is ahead'`
    set(:deploy_with_uncommitted_changes) { 
      Capistrano::CLI.ui.ask("You have uncommitted changes. Really deploy without your current changes? (Yn) ") 
    }
  end
end

namespace :nerd do
  # no code is faster than no code. - old Merb saying.
  desc "Installing bundled gems from inside the app (NOT from rubyforge and NOT into the system)"
  task :bundle do
    run("cd #{release_path} && /usr/local/rvm/gems/ruby-1.8.7-p330/bin/bundle install --local --path vendor --without=development production")
  end
  desc "drop file ownership to www-data"
  task :declinate_ownership do
    run("cd #{release_path} && chown -R www-data *")
  end
end

capistrano_color_matchers = [
 { :match => /command finished/,        :color => :hide,      :prio => 10 },
 { :match => /Currently /,              :color => :hide,      :prio => 10 },
 { :match => /servers: .*/,             :color => :hide,      :prio => 10 },
 { :match => /Installing \w+/,          :color => :magenta,   :prio => 10 },
 { :match => /Using bundler|Updating .gem files in vendor|with native extensions/,          :color => :green,   :prio => 10 },
 { :match => /out :: jm3.net\]\s*$/,     :color => :hide,      :prio => 10 },
 { :match => /executing command/,       :color => :cyan,      :prio => 10, :attribute => :underscore },
 { :match => /^transaction: commit$/,   :color => :magenta,   :prio => 10, :attribute => :blink },
 { :match => /git/,                     :color => :white,     :prio => 20  },
]
colorize( capistrano_color_matchers )
