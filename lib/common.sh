error() {
  echo " !     $*" >&2
  exit 1
}

head() {
  echo ""
  echo "-----> $*"
}

info() {
  #echo "`date +\"%M:%S\"`  $*"
  echo "       $*"
}

warning() {
  local tip=$1
  local url=$2
  echo "WARNING: $tip" >> $warnings
  echo "${url:-https://devcenter.heroku.com/articles/nodejs-support}" >> $warnings
  echo "" >> $warnings
}

file_contents() {
  if test -f $1; then
    echo "$(cat $1)"
  else
    echo ""
  fi
}

read_json() {
  local file=$1
  local node=$2
  if test -f $file; then
    local result="$(cat $file | $bp_dir/vendor/jq -r $node)"
    if [ "$result" == "null" ]; then
      echo ""
    else
      echo "$result"
    fi
  else
    echo ""
  fi
}

# sed -l basically makes sed replace and buffer through stdin to stdout
# so you get updates while the command runs and dont wait for the end
# e.g. npm install | indent
indent() {
  c='s/^/       /'
  case $(uname) in
    Darwin) sed -l "$c";; # mac/bsd sed: -l buffers on line boundaries
    *)      sed -u "$c";; # unix/gnu sed: -u unbuffered (arbitrary) chunks of data
  esac
}

cat_npm_debug_log() {
  test -f $build_dir/npm-debug.log && cat $build_dir/npm-debug.log
}

export_env_dir() {
  env_dir=$1
  if [ -d "$env_dir" ]; then
    whitelist_regex=${2:-''}
    blacklist_regex=${3:-'^(PATH|GIT_DIR|CPATH|CPPATH|LD_PRELOAD|LIBRARY_PATH)$'}
    if [ -d "$env_dir" ]; then
      for e in $(ls $env_dir); do
        echo "$e" | grep -E "$whitelist_regex" | grep -qvE "$blacklist_regex" &&
        export "$e=$(cat $env_dir/$e)"
        :
      done
    fi
  fi
}
