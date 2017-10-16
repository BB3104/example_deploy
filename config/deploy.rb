set :application, 'ec2_test'
set :repo_url, 'git@github.com:BB3104/ec2_test.git'
set :user, 'deploy'
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

set :branch, 'master' # デフォルトがmasterなのでこの場合書かなくてもいいです。
set :deploy_to, '/var/www/src'
set :scm, :git

set :format, :pretty
set :log_level, :debug
set :pty, true

# set :linked_files, %w{config/database.yml}
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# set :default_env, { path: "/opt/ruby/bin:$PATH" }
set :keep_releases, 5

set :rbenv_type, :system
set :rbenv_ruby, '2.3.0'
set :rbenv_path, '~/.rbenv'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}
 # set :rbenv_roles, :all # default value
 # set :default_env, { path: "/usr/local/rbenv/shims:/usr/local/rbenv/bin:$PATH" } # capistrano用bundleするのに必要
 # Default value for linked_dirs is []
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle}
namespace :deploy do
  #    Rake::Task["deploy:check:directories"].clear
  #   Rake::Task["deploy:check:linked_dirs"].clear
  #  namespace :check do
  #    desc '(overwrite) Check shared and release directories exist'
  #    task :directories do
  #      on release_roles :all do
  #        execute :sudo, :mkdir, '-pv', shared_path, releases_path, repo_path
  #        execute :sudo, :chown, '-R', "#{fetch(:user)}:#{fetch(:group)}", deploy_to
  #      end
  #    end
  #
  #    task :linked_dirs do
  #      next unless any? :linked_dirs
  #      on release_roles :all do
  #        execute :sudo, :mkdir, '-pv', linked_dirs(shared_path)
  #        execute :sudo, :chown, '-R', "#{fetch(:user)}:#{fetch(:group)}", deploy_to
  #      end
  #    end
  #  end
  desc 'Restart application'
  # task :restart do
  #   on roles(:app), in: :sequence, wait: 5 do
  #     # Your restart mechanism here, for example:
  #     # execute :touch, release_path.join('tmp/restart.txt')
  #   end
  # end

  after :restart, :clear_cache do
    on roles(:web1), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end
  before :cleanup, :cleanup_permissions

  desc 'Set permissions on old releases before cleanup'
  task :cleanup_permissions do
    on release_roles :all do |host|
      releases = capture(:ls, '-x', releases_path).split
      if releases.count >= fetch(:keep_releases)
        info "Cleaning permissions on old releases"
        directories = (releases - releases.last(1))
        if directories.any?
          directories.each do |release|
            within releases_path.join(release) do
                execute :sudo, :chown, '-R', 'deploy', 'public/uploads'
            end
          end
        else
          info t(:no_old_releases, host: host.to_s, keep_releases: fetch(:keep_releases))
        end
      end
    end
  end
  after :finishing, 'deploy:cleanup'
end
