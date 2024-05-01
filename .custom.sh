MYBG=056
export EDITOR=micro
export SUDO_EDITOR=micro
WIN_PROFILE_DIR="$(wslpath -u $(cd /mnt/c; cmd.exe /c 'echo %USERPROFILE%' | dos2unix))"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/home/dev/.sdkman"
[[ -s "/home/dev/.sdkman/bin/sdkman-init.sh" ]] && source "/home/dev/.sdkman/bin/sdkman-init.sh"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

# heroku autocomplete setup
HEROKU_AC_ZSH_SETUP_PATH=/home/dev/.cache/heroku/autocomplete/zsh_setup && test -f $HEROKU_AC_ZSH_SETUP_PATH && source $HEROKU_AC_ZSH_SETUP_PATH;

test -d ~/.rvm/scripts/rvm && source ~/.rvm/scripts/rvm

path+=(/opt/RubyMine/bin)
path+=(/usr/pgadmin4/bin)
path+=(~/aurora/bin)
ide() {
  pkill -ABRT -f RubyMine
  # &! "disowns" the process
  rubymine.sh > /tmp/rubymine.out 2>&1 &!
}

export AURORA_KEYSTORE_PASS=GyTpH9zq7JCybEVPWvCq6DfAPHpcf
export RAILS_MASTER_KEY=645c50d1b278580c6a16a34cf7aa8fec
export PORT=3000
export STREAM_APP_NAME=reachire-developer-sal


export LOGRAGE_ENABLED=true
export TRACE_STREAM_CALLS=true
export ACTIVE_RECORD_LOG_LEVEL=info
export FEATURE_FLAG_WEB_CHAT=off

export NODE_OPTIONS="--max-old-space-size=8192"

alias pga='ping www.google.com'
fix-net() {
  sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1 net.ipv6.conf.all.disable_ipv6=1
  # netscript restart
}

kserv() {( cd ~/aurora; bin/ksrv)}
ksrv() {( cd ~/aurora; bin/ksrv)}
kc() {
  spring stop && sleep 2 && pkill -f spring
  pkill -f 'rails c' && sleep 3
  pkill -9 -f 'rails c' 2>/dev/null && echo "Force killed rails c"
  pkill -9 -f 'spring' 2>/dev/null && echo "Force killed spring"
  rails console
}

build_test_db() {
  rails db:drop db:create db:migrate RAILS_ENV=test
}

reset_test() {
  rails db:schema:load db:seed:audit_event_types RAILS_ENV=test
}

reset() {
  pkill ruby # needed for db:drop

  # I've found thact combining multiple targets in one go gives wrong behavior
  rails db:drop &&
  rails db:create &&
  rails db:environment:set RAILS_ENV=development &&
  rails db:migrate &&
  rails db:seed

  rails db:schema:load db:seed:audit_event_types RAILS_ENV=test

  # imagemagick identify process get stuck on certain files, consume CPU
  pkill identify || true
}

up() {
  truncate -s0 ~/aurora/log/development.log
  rails db:migrate "$@" 2>&1 | (grep -v /gems/ || true)
}

down() {
  if [[ $1 =~ ^[0-9]+ ]]
  then
    argv[1]=STEP=$1
  fi

  truncate -s0 ~/aurora/log/development.log
  rails db:rollback "$@" 2>&1 | (grep -v /gems/ || true)
}

reup() { ( 
  set -e
  git stash push -m ++REUP++$$
  down
  git co db/schema.rb
  git stash list | grep -F ++REUP++$$ && git stash pop
  up	
) }

c() {(
  cd ~/aurora
  rails c
)}


# Usage:
#  heroku-app HEROKU_APP_NAME [GIT_REMOTE_ALIAS]
#  e.g.
#  $ heroku-app aurora-develop
#      creates git remote "heroku-develop"
#  can be shortened as:
#  $ heroku-app develop
heroku-app() {
  app=${1?App name is required (e.g. aurora-pr-987 or simply pr-987)}
  git_remote=aurora-${app/aurora-/}
  git_remote=${2:-${git_remote}}
  heroku git:remote -a aurora-${app} -r ${git_remote}
}

production-shell() {
	terminator -p production -x heroku run -a aurora-production bash
}

production-console() {
	terminator -p production -x heroku run -a aurora-production rails c
}

ro-console() {
    env=${1:-production}
	heroku run -a aurora-$env rails c --sandbox
}

debug-puma() {
  rdebug-ide --host 0.0.0.0 --port 1234 --dispatcher-port 26162 -- `which puma` -C config/puma.rb
}

debug-rails() {
  rdebug-ide --host 0.0.0.0 --port 1234 --dispatcher-port 26162 -- /home/dev/aurora/bin/rails console
}


export ANDROID_SDK_ROOT=~/Android/Sdk
export ANDROID_HOME=$ANDROID_SDK_ROOT
path+=(
  $ANDROID_HOME/emulator
  $ANDROID_HOME/tools
  $ANDROID_HOME/tools/bin
  $ANDROID_HOME/platform-tools
  ~/android-studio/bin
)


gitdt() {
	local curbr=$(git rev-parse --abbrev-ref HEAD)
	local dt=$1
	local branch=${2:-$curbr}
	git checkout `git rev-list -1 --before="${dt}" ${branch}`
}

rn() {
  react-native "$@"
}

check-a-m-root() {
  if ! grep -q aurora-mobile package.json
  then
    echo 'not in aurora-root folder?' >&1
    false
  fi
}

metro() {(
cd ~/aurora-mobile
  check-a-m-root && yarn install && yarn start
)}

ya() {(
  cd ~/aurora-mobile
  check-a-m-root || return

  if ! pgrep -f react-native > /dev/null
  then
	echo 'No Metro server running'
    return
  fi

  if ! adb devices | command grep -sq '[0-9]'
  then
    echo 'No device plugged in'
    while ! adb devices | command grep -sq '[0-9]'
    do
      echo -n .; sleep 1
    done
  fi

  yarn install &&
  yarn android
)}


promote() {
  local from=develop
  local to=master
  git stash &&
    git fetch &&
    git rebase ${from} ${to} &&
    git push &&
    git co ${from}
}

apilog() {
  if [[ -z $1 ]]
  then
    tail -f ~/aurora/log/development.log |
        sed -urn 's!.*method=([^ ]+).* path=(/?/api/v1/[^ ]+).* status=([^ ]+).* duration=([^ ]+) .*!\1 \2 \t\t\3  \4ms!igp'
  else
    local env=${1:-production}
    heroku logs -a aurora-${env} --tail |
        sed -urn 's!.*method=([^ ]+).* path="(/?/api/v1[^"]+).* service=([^ ]+).* status=([^ ]+) .*!\1 \2 \t\t\3 \4!igp' |
        sed -e "s/\(^.*[2][0-9][0-9]\)$/[32m\1[0m/g" \
            -e "s/\(^.*[3][0-9][0-9]\)$/[33m\1[0m/g" \
            -e "s/\(^.*[45][0-9][0-9]\)$/[31m\1[0m/g"
  fi
}

alias top=htop

stty sane erase '^?'

draft-pr()
{
  read  "title?PR name (Paste in the name of relevant Asana task): "
  gh pr create --title "$title" --body '' --base develop --label "work-in-progress"
}

hkr()
{(
  #set -x
  local app=${1?App name is required (e.g. aurora-develop, or just develop)}
  shift
  local cmd=bash
  if [[ $# > 0 ]]
  then
	  cmd="$@"
  fi
  app=aurora-${app/aurora-/}
  heroku run -a $app $cmd
)}

hke()
{(
  #set -x
  local app=${1?App name is required (e.g. aurora-develop, or just develop)}
  shift
  local cmd=bash
  if [[ $# > 0 ]]
  then
	  cmd="$@"
  fi
  app=aurora-${app/aurora-/}
  heroku ps:exec -a $app $cmd
)}


clean()
{
 rm -rf node_modules
 rm -rf public/assets
 rm -rf tmp
}


submodules() {
  git submodule update --init --recursive
}

alias xml=xmlstarlet
alias xsl='xmlstarlet val'

function go()
{
  (
  cat <<EOF
    def go(*params, **opts)
      @params = params
      @opts = opts
      load('go.rb')
      @res
    end
    go "$@"
EOF
  ) | rails runner -
}

path+=(~/gatling/bin)

function hk() {
  heroku "$@" -a aurora-stage
}

function h() {
  heroku "$@" -a aurora-stage
}


alias pg='service postgresql start'

apk() {
 (
   cd ~/aurora-mobile
   yarn apk && bin/install-apk release
     # cp ./android/app/build/outputs/apk/release/app-release.apk ~/win-home/Documents/APK/ &&
     # wslview ./android/app/build/outputs/apk/release/app-release.apk
 )
}

debugApk() {
 (
   if ! curl -s http://localhost:8081 2>&1 > /dev/null
   then
     echo ""
     echo "** Don't forget to start Metro server (in another window) **"
     echo ""
   fi

   cd ~/aurora-mobile/android;
   ./gradlew assembleDebug && ../bin/install-apk debug
   #  cp ./app/build/outputs/apk/debug/app-debug.apk ~/win-home/Documents/APK/ &&
   # wslview ./app/build/outputs/apk/debug/app-debug.apk
 )
}

apks() {
 (cd ~/aurora-mobile/android; ./gradlew assembleRelease assembleDebug && cp ./app/build/outputs/apk/*/app-*.apk ~/win-home/Documents/APK/)
}

c-p() {
  echo "** Copying database"
  (set -x;
    heroku pg:copy aurora-production::DATABASE DATABASE --app aurora-stage --confirm aurora-stage
    heroku ps:restart -a aurora-stage
  )

  echo "** Copying s3 bucket"
  (set -x;
    aws s3 sync s3://reachire-active-storage-production s3://reachire-active-storage-staging
  )


  echo "** Seeding QA data"
  (set -x;
    heroku run -a aurora-stage rails db:migrate db:seed:qa_teams
  )

}

# service postgresql status 2>&1 > /dev/null || service postgresql start

# Set/Show feature flags in Heroku
#   ff stage   # show feature flags from aurora-stage
#   ff stage tmcw true # set feature flag TMCW on aurora-stage
function ff() {
  local app=aurora-${1/aurora-//}
  if [[ $# -gt 1 ]]
  then
    local lhs=${2}
    local rhs=${3}
    local feature=$(echo -n $lhs | tr '[:lower:]' '[:upper:]')

    heroku config:set "FEATURE_FLAG_$feature=$rhs" -a $app
  else
    heroku config -a $app | grep '^FEATURE_FLAG_[^: ]*'
  fi
}

function recd() {
  cd /; cd -
}

unalias shutdown || true
function shutdown() {
  wsl.exe --shutdown
}

sudo pkill -0 dockerd || (sudo dockerd 2> /dev/null&)
export DOCKER_BUILDKIT=1
alias dirt='docker run -it'

alias e=micro
vi () {
  echo '** Use micro instead **'
  sleep 1
  micro "$@"
}

micro () {
	command micro "$@"
	rm -f log.txt
}

proxy() {
  if ! nc -w0 localhost 8080
  then
    echo "Error: Proxy server not reachable on localhost:8080" >&2
    return
  fi
  http_proxy=http://localhost:8080 HTTP_PROXY=http://localhost:8080 "$@"
}

eval "$(direnv hook zsh)"

export GIT_MERGE_AUTOEDIT=no
#export AURORA_DEMO_ACCOUNT=devparticipant@reachire.com

_top() {
  while [[ ! -d .git ]]
  do
    cd ..
  done
}

gpp() {
  (
    echo "Synching core"
    cdc &&
      git pull && git push &&
    bd &&
      echo "Synching top level"
      git co -- .idea;
      git pull && git push;
  )
}

cdc() {
  if [[ -d app/webpacker/aurora-client-core ]]
  then
    cd app/webpacker/aurora-client-core
  else
    cd src/core
  fi
}

co-d() {
  (_top; git co develop --recurse-submodules)
}

co-s() {
  (_top; test -d .idea && git co -- .idea; git co staging --recurse-submodules)
}

co-m() {
  (_top; test -d .idea && git co -- .idea; git co master --recurse-submodules)
}

gp() {
  git co .idea
  git pull --recurse-submodules
}

show-stash() {
  local n=${1:-0}
  git difftool -y "stash@{$n}~" "stash@{$n}"
}

# rails() {
  # spring stop
  # command rails "$@"
# }


export DONT_PROMPT_WSL_INSTALL=true

# TODO: fix this hack
if [[ -d /mnt/c/Users/*/AppData/Local/android/Sdk ]]
then
SDK=$(echo /mnt/c/Users/*/AppData/Local/android/Sdk)
fi

# # This runs the WINDOWS installed version of adb
# function adb() {
  # $SDK/platform-tools/adb.exe "$@"
# }

path+=(
  $ANDROID_HOME/cmdline-tools/latest
  $ANDROID_HOME/cmdline-tools/latest/bin
  $ANDROID_HOME/platform-tools
)

alias rnd='react-native-debugger --no-sandbox'

# path+=(/mnt/c/Users/*/AppData/Local/android/Sdk/platform-tools)

alias snapshot="pg_dump -f develop.dump -c -C reachire-web_development"
alias restore="psql -q -d postgres < develop.dump"

alias rrspec="rails db:schema:load db:migrate db:seed:audit_event_types RAILS_ENV=test && rspec"

alias ntp='sudo ntpdate pool.ntp.org'

function use-core() {
  local branch=$1
  git config -f .gitmodules submodule.app/webpacker/aurora-client-core.branch $branch
  git submodule update --remote
}


ready () {
  echo "Finished with status: $?" |
  yad --text-info --title "Ready" --button='Got it' --wrap --fontname 'Sans normal 14' --width 300
}

notify () {
  local title=${1:-Notification}
  local text='If something deserving your attention were to have happened, which it may or may not have at this time, you would have been notified with a message very much like this; possibly, but not definitely, containing useful information about what actually happened; or perhaps instead with some generic, vague and non-committal verbiage.'
  echo "$text" | yad --text-info --title "$title" --button='Got it' --wrap --fontname 'Sans normal 14' --geometry 500x300-300-200
}

hbo () {
  local env=${1:-develop}
  local app=aurora-$env
  title "hbo $env"
  (heroku builds:output -a "$app" 2>&1 | yad --text-info --listen --title "$app" --tail --geometry 800x300 --button 'Close:0' --auto-kill --kill-parent HUP)
  true
}

hro () {
  local env=${1:-develop}
  local app=aurora-$env
  title "hbo $env"
  (heroku releases:output -a "$app" 2>&1 | yad --text-info --listen --title "$app" --tail --geometry 800x300 --button 'Close:0' --auto-kill --kill-parent HUP)
  true
}


hbp () {
  local env=${1:-develop}
  local app=aurora-$env
  title "hbp $env"
  (heroku builds:output -a "$app" 2>&1 | yad --progress --pulsate --title "$app" --fontname 'helvetica 15' --button 'Close:0' --auto-close  --auto-kill --kill-parent HUP)
  true
}

yad () {
  command yad "$@" 2> /dev/null
}

precompile () {
  rails assets:clobber assets:clean; yarn; time (rails assets:precompile 2>&1 | cut -c1-300 | grep -v INFO); ready
}

function hotfix () {
  local hf_name=${1:-cumulative}
  local date=$(date +%Y-%m-%d)
  local live_commit=$(heroku config:get HEROKU_SLUG_COMMIT -a aurora-production)
  local branch_name="hotfix/$date-$hf_name"

  git checkout -B "${branch_name}" ${live_commit}
  git pull origin "${branch_name}" || true
  git push -u origin "${branch_name}"
}

# It should not be necessaryy to use this, as this should happen in heroku in deploy.sh
tag-live-commit () {
  local commit=$(heroku config:get HEROKU_SLUG_COMMIT -a aurora-production)
  git tag -f live-in-production ${commit}
}

aurora () {
  rails aurora:"$@"
}


# cancel all pending builds in a heroku env
hbc () {
  local env=${1:-develop}
  local app=aurora-${env/aurora-//}
  heroku builds -a $app | grep pending | cut -c1-36 | xargs --verbose -i@ heroku builds:cancel @ -a $app
}
