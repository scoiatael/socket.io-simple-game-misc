#!/bin/sh
which chef-solo || which chef-client || (curl -L https://www.opscode.com/chef/install.sh 2>&- | bash)
