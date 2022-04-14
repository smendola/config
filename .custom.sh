MYBG=056
export EDITOR=vim

# NVM setup
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/home/dev/.sdkman"
[[ -s "/home/dev/.sdkman/bin/sdkman-init.sh" ]] && source "/home/dev/.sdkman/bin/sdkman-init.sh"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

# heroku autocomplete setup
HEROKU_AC_ZSH_SETUP_PATH=/home/dev/.cache/heroku/autocomplete/zsh_setup && test -f $HEROKU_AC_ZSH_SETUP_PATH && source $HEROKU_AC_ZSH_SETUP_PATH;

source ~/.rvm/scripts/rvm

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
export FOREST_ENV_SECRET=660b9fc6b96f476f5fc0d8e9b4da85e15f6732c4c6e6df26d13ef9c583b5bc9c
export LOGRAGE_ENABLED=true

alias pga='ping www.google.com'
fix-net() {
  sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1 net.ipv6.conf.all.disable_ipv6=1
  # netscript restart
}

kserv() {( cd ~/aurora; bin/ksrv)} 
ksrv() {( cd ~/aurora; bin/ksrv)} 
krc() { 
  pkill -f rails
  sleep 2
  pkill -9 -f rails 2>/dev/null && echo "Force killed"
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
  rails db:seed &&
  rails db:schema:load db:seed:audit_event_types RAILS_ENV=test

  # imagemagick identify process get stuck on certain files, consume CPU
  pkill identify || true
}

up() {
  truncate -s0 ~/aurora/log/development.log
  rails db:migrate "$@" 2>&1 | (grep -v /gems/ || true)
}

down() {
  truncate -s0 ~/aurora/log/development.log
  rails db:rollback "$@" 2>&1 | (grep -v /gems/ || true)
}

c() {
  rails r nil 2>/dev/null
  rails c
}


# Usage:
#  heroku-app HEROKU_APP_NAME [GIT_REMOTE_ALIAS]
#  GIT_REMOTE_ALIAS defaults to heroku-HEROKU_APP_NAME with the substring "aurora-" removed
#  e.g.
#  $ heroku-app aurora-develop
#      creates git remote "heroku-develop"
heroku-app() {
  app=${1?App name is required (e.g. aurora-develop)}
  git_remote=heroku-${app/aurora-/}
  git_remote=${2:-${git_remote}}
  heroku git:remote -a ${app} -r ${git_remote}
}

# Usage:
# deploy [BRANCH [APP]]
# BRANCH defaults to 'develop'
# APP defaults to develop, meaning remote 'heroku-develop'
# e.g.
# $ deploy
#    deploys local develop branch to heroku-develop
# $ deploy mybranch
#    deploys local mybranch branch to heroku-develop
# $ deploy develop stage
#    deploys local develop branch to heroku-stage
#
deploy() {
  local branch=${1:-develop}
  local env=${2:-develop}
  git push heroku-$env ${branch}:master
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

# only works on production, as that pg server is only attached to production
ro-psql() {
  heroku pg:psql postgresql-silhouetted-48232 --credential sal-readonly --app aurora-$1
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
)


clone-prod() {
  echo "** Entering maintenance mode" 
  (set -x;
    heroku maintenance:on -a aurora-stage
  )

  echo "** Copying database"
  (set -x;
    heroku pg:copy aurora-production::DATABASE DATABASE --app aurora-stage --confirm aurora-stage
    heroku ps:restart -a aurora-stage
    heroku maintenance:off -a aurora-stage
  )

  echo "** Copying s3 bucket"
  (set -x;
    aws configure set default.s3.max_concurrent_requests 200
    aws s3 sync s3://reachire-active-storage-production s3://reachire-active-storage-staging
  )

  echo "** Migrating database"
  (set -x;
    heroku run -a aurora-stage rails db:migrate
  )

  echo "** Exiting maintenance mode" 
  (set -x;
    heroku maintenance:off -a aurora-stage
  )

  echo "** Resetting push and chat accounts"
  (set -x;
    heroku run -a aurora-stage rails onesignal:delete_all_players
    heroku run -a aurora-stage rails stream:reset 
  )

  echo "** Anonymizing"
  (set -x;
    heroku run -a aurora-stage rails aurora:anonymize
  )

  echo "** Seeding QA data"
  (set -x;
    heroku run -a aurora-stage rails db:seed:qa_teams
  )
}


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



# Send files via transfer.sh service
# Uses encryption in transit

# Usage:
#  send PATH ...
#  send mods
#  Can send mix of files and dirs
#  If PATH is exactly 'mods' it will instead send
#  files that are modified in git
# The output of this command includes the command
# to be used on the receiving end to receive the files.
# If possible, the command is also sent to the clipboard.
function send() {
  if [[ $1 == "mods" ]]
  then
    declare -a mods=( $(git status -s -uno | sed -e 's/^.* //g') )
    send "${mods[@]}"
    return
  fi

  local url=$(tar Jcf - "$@" | gpg -ac -o- | 
   curl -s -X PUT -T - \
        -H "Max-Downloads: 1" \
        -H "Max-Days: 5" \
        https://transfer.sh/send.gpg
  )
  local receive_cmd="curl -s '$url' | gpg -d -o- | tar Jxfvv -"
  echo $receive_cmd
  echo "$receive_cmd" | xsel -i -b | echo 'Sent to clipboard' || echo '(No clipboard)'
}


function receive() {
   curl -s "$1" | gpg -d -o- | tar Jxfvv -
}

ttysend()
{
  if [[ $1 == "mods" ]]
  then
	declare -a mods=( $(git status -s -uno | sed -e 's/^.* //g') )
    ttysend "${mods[@]}"
    return
  fi

  if [[ ! -e "$1" ]]
  then
	echo "No such file: $1" 1>&2
    return
  fi

  clear
  echo -n -e '\e[32m'
  echo '###########################################################################'
  echo '# Paste all that follows this into a TTY window on the target machine     #'
  echo '###########################################################################'
  echo -e '\e[0m'
  echo ' (base64 -d | tar Jxpf -) << EOF'
  tar Jcf - "$@" | base64
  echo EOF
}

clean()
{
 rm -rf node_modules
 rm -rf public/assets
 rm -rf tmp
}


push-core() {
  test -f package.json || fail
  local need_stash=$(git status -uno -s)
  if [[ $need_stash ]]; then git stash save -m 'doing push-core'; fi
  yarn zip-core
  echo git commit -m 'zip-core'
  echo git push
  if [[ $need_stash ]]; then git stash pop; fi
}

submodules() {
  git submodule update --init --recursive
}

alias xml=xmlstarlet
alias xsl='xmlstarlet val'

alias go='rails runner `pwd`/go.rb'

path+=(~/gatling/bin)
#export DATABASE_URL='postgres://dev:dev@sm-dev/reachire-web_development?pool=5'

function hk() {
  heroku "$@" -a aurora-stage
}

function h() {
  heroku "$@" -a aurora-stage
}


alias pg='service postgresql start'
export MAIL_SERVICE=mailtrap
export FEATURE_FLAG_TMCW=true
export FEATURE_FLAG_ONBOARDING=true

apk() {
 (
   cd ~/aurora-mobile
   yarn apk && cp ./android/app/build/outputs/apk/release/app-release.apk ~/win-home/Documents/APK/
 )
}

debugApk() {
 (cd ~/aurora-mobile/android; ./gradlew assembleDebug && cp ./app/build/outputs/apk/debug/app-debug.apk ~/win-home/Documents/APK/)
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

service postgresql status 2>&1 > /dev/null || service postgresql start

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

unalias shutdown
function shutdown() {
  wsl.exe --shutdown
}

transfer(){ if [ $# -eq 0 ];then echo "No arguments specified.\nUsage:\n transfer <file|directory>\n ... | transfer <file_name>">&2;return 1;fi;if tty -s;then file="$1";file_name=$(basename "$file");if [ ! -e "$file" ];then echo "$file: No such file or directory">&2;return 1;fi;if [ -d "$file" ];then file_name="$file_name.zip" ,;(cd "$file"&&zip -r -q - .)|curl --progress-bar --upload-file "-" "https://transfer.sh/$file_name"|tee /dev/null,;else cat "$file"|curl --progress-bar --upload-file "-" "https://transfer.sh/$file_name"|tee /dev/null;fi;else file_name=$1;curl --progress-bar --upload-file "-" "https://transfer.sh/$file_name"|tee /dev/null;fi;}
