#!/bin/bash

rbenv_v='1.1.0'
ruby_build_v='20170201'
version="0.$(echo $rbenv_v | sed -e 's/[^0-9]//g').$(echo $ruby_build_v | sed -e 's/[^0-9]//g')"

[[ $DEBUG ]] || DEBUG=2

rbenv_url="https://github.com/rbenv/rbenv/archive/v${rbenv_v}.tar.gz"
ruby_build_url="https://github.com/rbenv/ruby-build/archive/v${ruby_build_v}.tar.gz"
result="rbenv-with-ruby-build-v${version}.tgz"
rbenv=$(basename "$rbenv_url")
rubyb=$(basename "$ruby_build_url")

[[ $DEBUG -lt 2 ]] || echo "version = '$version'"
[[ $DEBUG -lt 2 ]] || echo "rbenv = '$rbenv'"
[[ $DEBUG -lt 2 ]] || echo "rubyb = '$rubyb'"

main() {
  [[ -f $result ]] || {
    fetchum "$rbenv_url" "$rbenv" ;
    fetchum "$ruby_build_url" "$rubyb" ;
    esplode "$rbenv" rbenv ;
    esplode "$rubyb" ruby-build ;
    [[ -d rbenv/plugins ]] || mkdir rbenv/plugins ;
    [[ -d rbenv/plugins/ruby-build ]] || {
      mv ruby-build rbenv/plugins/ ;
      ln -s rbenv/plugins/ruby-build/ ./ ;
    }
    tar -czf $result rbenv ;

    # clean-up
    rm -rf "$explode_rbenv" || true ;
    rm -rf "$explode_rubyb" || true ;
  } ;
}
esplode() { # Simplifies the process of extracting a tgz bundle.
  local f=$1 ;
  local d=$2 ;
  [[ -d $d ]] || {
    local pwd=$(pwd) ;
    [[ $DEBUG -lt 2 ]] || echo "pwd = '$pwd'"
    local explode_d=`mktemp -d "${TMPDIR:-/tmp}/tmp.d.XXXXXXXXXX"` ;
    [[ $DEBUG -lt 2 ]] || echo "esplode() { explode_d = '$explode_d'... }"
    cd $explode_d && {
      tar -xzf "$pwd/$f" ;
      local one_folder=$(ls -A) ;
      local how_many=$(ls -A | wc -l) ;
      [[ 1 -eq $how_many && -d "$one_folder" ]] && {
        mv "$one_folder" "$pwd/$d" ;
      } || {
        mkdir "$pwd/$d" ;
        ls -A | while read x ; do mv "$x" "$pwd/$d"/ ; done ;
      }
    }
    cd "$pwd" ;
  }
}
fetchum() {
  local u=$1 ;
  local f=$2 ;
  [[ $f ]] || f=$(basename "$u") ;
  [[ -e "$f" ]] || {
    which curl > /dev/null && {
      curl -sL "$u" > "$f" ;
    } || {
      wget -O "$f" "$u" ;
    } ;
  }
}

main ;

#
