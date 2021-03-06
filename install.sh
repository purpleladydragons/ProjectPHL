#!/usr/bin/env bash

##
# Absurdly rough script for setting up dev environment in OS X.
##

# Check for homebrew dependencies
echo "Checking for homebrew..."
if ! type brew > /dev/null ; then
    echo "Install homebrew before proceeding:"
    echo 'ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)'
    exit 1
else
    echo "Updating homebrew..."
    brew update
fi

echo "Checking for apple-gcc42..."
if ! [[ `command brew ls apple-gcc42` =~ "apple-gcc42" ]] ; then
    echo "apple-gcc42 not found. Installing..."
    brew install apple-gcc42
fi

echo "Checking for postgresql..."
if ! [[ `command psql --version` =~ "9.3.4" ]] ; then
    echo "PostgreSQL not found. Installing..."
    cd `brew --prefix`
    git checkout 2a5855c Library/Formula/postgresql.rb
    brew install postgresql
    brew switch postgresql 9.3.4
    echo "Now using PostgreSQL 9.3.4."
    git checkout -- Library/Formula/postgresql.rb
fi

# Versions
RUBY_VER="2.1.2"
RAILS_VER="4.1.0"
DEVISE_VER="3.2.4"
PG_VER="0.17.1"
# Gemset
GEMSET_NAME="gameon-dev"

# RVM
echo "Checking for RVM..."
if ! command rvm 2>/dev/null ; then
    echo "RVM not installed. Installing..."
    curl -sSL https://get.rvm.io | bash -s stable
else
    echo "RMV already installed."
fi
source "$HOME/.rvm/scripts/rvm"

# Ruby
echo "Installing ruby-$RUBY_VER..."
rvm install $RUBY_VER

# Establish gemset
rvm use $RUBY_VER
if ! [[ `command rvm gemset list` =~ "$GEMSET_NAME" ]] ; then
    echo "Creating gemset $GEMSET_NAME..."
    rvm gemset create $GEMSET_NAME
fi
echo "Using gemset $GEMSET_NAME..."
rvm gemset use $GEMSET_NAME

# Rails
echo "Installing rails-$RAILS_VER..."
gem install rails -v $RAILS_VER

# Other gems
echo "Installing gems..."
echo "Installing devise-$DEVISE_VER..."
gem install devise -v $DEVISE_VER
echo "Installing pg-$PG_VER..."
gem install pg -v $PG_VER

echo ""
echo "$(tput setaf 1)You will need to add the following lines to your .bash_profile:$(tput sgr0)"
echo ""
echo "$(tput setaf 1)source $HOME/.rvm/scripts/rvm$(tput sgr0)"
echo "$(tput setaf 1)rvm use gameon-dev@2.1.2$(tput sgr0)"
