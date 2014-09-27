#
# Cookbook Name:: server
# Recipe:: default
#
# Copyright (C) 2014
#
#
#
PROJECT="socket.io-simple-game"

package 'epel-release'

"
git
htop
nodejs
npm
python-pip
".split(/\n/).each do |pkg|
  if not pkg.empty?
    package pkg
  end
end

user "server"

def install_deps_of(path)
  bash "install dependencies at #{path}" do
    cwd path
    creates 'node_modules'
    user 'server'
    environment "HOME" => "/home/server"
    code "npm install --production && (mkdir node_modules || exit 0)"
  end
end

"
server
client
".split(/\n/).each do |repo|
  if not repo.empty?
    bash "setup #{repo}.git" do
      cwd '/home/server'
      creates "#{PROJECT}-#{repo}.git"
      user 'server'
      code "git clone --bare https://github.com/scoiatael/#{PROJECT}-#{repo}.git"
    end
  end
end

bash "setup real repo" do
  cwd '/home/server/'
  user 'server'
  creates "#{PROJECT}-server"
  code "git clone --recursive #{PROJECT}-server.git"
end

bash "install nodervisor" do
  cwd "/home/server"
  user 'server'
  creates "nodervisor"
  code "git clone --recursive https://github.com/TAKEALOT/nodervisor.git"
end

"
server
server/#{PROJECT}-client
".split(/\n/).each do |repo|
  if not repo.empty?
      install_deps_of "/home/server/#{PROJECT}-#{repo}"
  end
end

"
supervisor
".split(/\n/).each do |pkg|
  if not pkg.empty?
    bash "install #{pkg} with easy_install" do
      creates "/usr/bin/supervisord"
      code "easy_install #{pkg}"
    end
  end
end

install_deps_of "/home/server/nodervisor"

template "/etc/supervisord.conf" do
  source "supervisord.conf"
end

template "/etc/init.d/supervisord" do
  mode 0755
  source "initd-supervisord"
end

directory "/var/log/server" do
end

service "supervisord" do
  action [ :start, :enable ]
end

bash "set ownership of files" do
  cwd '/home/server'
  code 'chmod o+w,o+r,o+x -R ./'
end
