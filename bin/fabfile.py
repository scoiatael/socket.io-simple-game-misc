from __future__ import with_statement
from fabric.api import env, lcd, local, sudo, cd, settings, hide
#from fabric.contrib.console import confirm

from os.path import basename

remotes = [
  'origin',
  'vagrant'
  ]

paths = {
  'local': {
    'vagrant' : "../vagrant/",
    'venv' : "../venv/",
    'repos' : [
      '../../socket.io-simple-game-server',
      '../../socket.io-simple-game-client'
      ]
    },
  'remote': {
    'repos': [
      '/home/server/socket.io-simple-game-server',
      '/home/server/socket.io-simple-game-server/socket.io-simple-game-client'
      ]
    }
  }

def vagrant():
  env.hosts = ["127.0.0.1:2222"]
  env.user = "vagrant"

  with lcd(paths['local']['vagrant']):
    # use vagrant ssh key
    result = local('vagrant ssh-config | grep IdentityFile', capture=True)
  env.key_filename = result.split()[1]

def pull():
  for path in paths['remote']['repos']:
    with cd(path):
      sudo("pwd && git pull origin master", user='server', group='server')

def push_to(target='origin'):
  for path in paths['local']['repos']:
    with lcd(path):
      print('At %s..' % basename(path))
      with settings(warn_only=True):
        with hide('running'):
          result = local('git remote show | grep %s' % target, capture=True)
          if not result.failed:
            url = local('git remote -v show %s | grep Push' % target,
                    capture=True)
            print(url)
            print(' ..refs..')
            local('git push --all %s' % target)
            print(' ..tags..')
            local('git push --tags %s' % target)
          else:
            print("Repo %s at %s not found; %s" %
                    ( target, path, result.stderr ))

def push():
  for remote in remotes:
    push_to(target=remote)

def deploy():
  push()
  pull()

