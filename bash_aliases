# .bash_aliases

# Allow for a local .bash_aliases
LOCAL_BASH_ALIASES=$HOME/.bash_aliases.local
if [ -f $LOCAL_BASH_ALIASES ]; then
  source $LOCAL_BASH_ALIASES
fi
unset LOCAL_BASH_ALIASES

# emacs
alias e='emacs -nw'

alias f='cd ~/src/flume'
alias k='cd ~/src/kudu'

# Git shortcuts
update_func() {
  BRANCH=$1
  if [[ -z "$BRANCH" ]]; then
    echo "Usage: update <branch>"
    return 1
  fi
  (
    set -x
    git checkout $BRANCH
    git pull --ff-only
  )
}
alias update=update_func

# re-enable keyboard mappings
#alias xmm='xmodmap ~/.xmodmaprc'

export LLVM_SYMBOLIZER=/home/mpercy/src/kudu/thirdparty/clang-toolchain/bin/llvm-symbolizer
export DEVTOOLSET='../../build-support/enable_devtoolset.sh'
export CMAKE='../../thirdparty/installed/common/bin/cmake'
NUM_PROCS=$(getconf _NPROCESSORS_ONLN)
export NUM_PROCS_MINUS_ONE=$(expr $NUM_PROCS - 1)
export CMAKE_GENERATOR=${CMAKE_GENERATOR:-Ninja}
export CMAKE_MAKE_PROG=${CMAKE_MAKE_PROG:-ninja}

kudu_gerrit_submit_branch() {
  (
    local BRANCH=$1
    shift
    if [ -z "$BRANCH" ]; then
      echo =======================================================
      echo "ERROR: No branch specified."
      echo =======================================================
      return 1
    fi
    # TODO: figure out how to deal with dual thirdparty
    #if ! git diff-index --quiet HEAD --; then
    #  echo ================================================================================
    #  echo "ERROR: Changes present in local tree. Please commit before pushing to Gerrit."
    #  echo ================================================================================
    #  echo
    #  git status --untracked-files=no
    #  return 1
    #fi
    local GERRIT_CMD="git push --no-thin gerrit HEAD:refs/for/$BRANCH"
    local ARGS=""
    while [ -n "$1" ]; do
      local REVIEWER=$1
      shift
      if [ -z "$ARGS" ]; then
        ARGS="%"
      else
        ARGS="${ARGS},"
      fi
      ARGS="${ARGS}r=$REVIEWER"
    done
    GERRIT_CMD="${GERRIT_CMD}${ARGS}"
    set -xe
    $GERRIT_CMD
  )
}

kudu_gerrit_submit() {
  kudu_gerrit_submit_branch master $*
}

kudu_gerrit_submit_current_branch() {
  local BRANCH=$(git rev-parse --abbrev-ref HEAD)
  kudu_gerrit_submit_branch "$BRANCH" $*
}

# kudu aliases
alias gerrit_submit=kudu_gerrit_submit
alias gerrit_submit_current_branch=kudu_gerrit_submit_current_branch
alias gerrit_submit_branch=kudu_gerrit_submit_branch
alias toolset-ninja='export CMAKE_GENERATOR=Ninja; export CMAKE_MAKE_PROG=ninja'
alias toolset-xcode='export CMAKE_GENERATOR=Xcode; export CMAKE_MAKE_PROG=xcodebuild'

kudu_run_cmake_func() {
  (
    set -x
    BUILD_TYPE=$1
    if [ -z "$BUILD_TYPE" ]; then
      echo Error: Must specify build type
      return
    fi

    if [ -z "$NO_REBUILD_THIRDPARTY" ]; then
      $DEVTOOLSET ../../thirdparty/build-if-necessary.sh
    fi

    rm -Rf CMakeCache.txt CMakeFiles/
    CMAKE_OPTS="-DCMAKE_EXPORT_COMPILE_COMMANDS=1 -DKUDU_FORCE_COLOR_DIAGNOSTICS=1 $CMAKE_OPTS"
    case $BUILD_TYPE in
      DYNDEBUG)
        $DEVTOOLSET $CMAKE ../.. -G $CMAKE_GENERATOR $CMAKE_OPTS -DCMAKE_BUILD_TYPE=debug
        ;;
      DEBUG)
        $DEVTOOLSET $CMAKE ../.. -G $CMAKE_GENERATOR $CMAKE_OPTS -DKUDU_LINK=static -DCMAKE_BUILD_TYPE=debug
        ;;
      CLANGDEBUG)
        CC=clang CXX=clang++ $DEVTOOLSET $CMAKE ../.. -G $CMAKE_GENERATOR $CMAKE_OPTS -DKUDU_LINK=static -DCMAKE_BUILD_TYPE=debug
        ;;
      DYNCLANG)
        # Probably the fastest build method.
        CC=clang CXX=clang++ $DEVTOOLSET $CMAKE ../.. -G $CMAKE_GENERATOR $CMAKE_OPTS -DKUDU_LINK=dynamic -DCMAKE_BUILD_TYPE=debug
        ;;
      ASAN)
        CC=clang CXX=clang++ $DEVTOOLSET $CMAKE ../.. -G $CMAKE_GENERATOR $CMAKE_OPTS -DCMAKE_BUILD_TYPE=fastdebug -DKUDU_USE_ASAN=1
        ;;
      ASANDEBUG)
        CC=clang CXX=clang++ $DEVTOOLSET $CMAKE ../.. -G $CMAKE_GENERATOR $CMAKE_OPTS -DCMAKE_BUILD_TYPE=debug -DKUDU_USE_ASAN=1 -DKUDU_USE_UBSAN=1 -DKUDU_LINK=static
        ;;
      TSAN)
        CC=clang CXX=clang++ $DEVTOOLSET $CMAKE ../.. -G $CMAKE_GENERATOR $CMAKE_OPTS -DCMAKE_BUILD_TYPE=fastdebug -DKUDU_USE_TSAN=1
        ;;
      TSANDEBUG)
        CC=clang CXX=clang++ $DEVTOOLSET $CMAKE ../.. -G $CMAKE_GENERATOR $CMAKE_OPTS -DCMAKE_BUILD_TYPE=debug -DKUDU_USE_TSAN=1
        ;;
      COVERAGE)
        CC=clang CXX=clang++ $DEVTOOLSET $CMAKE ../.. -G $CMAKE_GENERATOR $CMAKE_OPTS -DKUDU_LINK=dynamic -DCMAKE_BUILD_TYPE=debug -DKUDU_GENERATE_COVERAGE=1
        ;;
      CLIENT)
        CC=clang CXX=clang++ $DEVTOOLSET $CMAKE ../.. -G $CMAKE_GENERATOR $CMAKE_OPTS -DCMAKE_BUILD_TYPE=debug -DKUDU_EXPORTED_CLIENT=1
        ;;
      RELEASE|HEAPCHECK)
        $DEVTOOLSET $CMAKE ../.. -G $CMAKE_GENERATOR $CMAKE_OPTS -DCMAKE_BUILD_TYPE=release
        ;;
    esac
    $DEVTOOLSET $CMAKE_MAKE_PROG clean
  )
}

kudu_ensure_build_type() {
  BUILD_TYPE=$1
  CURRENT_BUILD_TYPE=$(grep CMAKE_BUILD_TYPE CMakeCache.txt | cut -d= -f2)
  if [ "$BUILD_TYPE" != "$CURRENT_BUILD_TYPE" ]; then
    kudu_run_cmake_func "$BUILD_TYPE"
  fi
}

kudu_build_func() {
  BUILD_TYPE=$1
  date \
  &&
  kudu_run_cmake_func $BUILD_TYPE \
  && date \
  && time $DEVTOOLSET $CMAKE_MAKE_PROG -j${NUM_PROCS_MINUS_ONE} $NINJA_OPTS
}

kudu_make_and_test_func() {
  BUILD_TYPE=$1
  kudu_build_func $BUILD_TYPE \
  && rm -rf /tmp/kudutest-1000 \
  && date \
  && time ctest -j${NUM_PROCS_MINUS_ONE}
}

alias kudu_build='kudu_make_and_test_func DEBUG'
alias kudu_build_dyn='kudu_make_and_test_func DYNDEBUG'
alias kudu_build_dynclang='kudu_make_and_test_func DYNCLANG'
alias kudu_build_clang='kudu_make_and_test_func CLANGDEBUG'
alias kudu_build_asan='kudu_make_and_test_func ASAN'
alias kudu_build_asandebug='kudu_make_and_test_func ASANDEBUG'
alias kudu_build_tsan='kudu_make_and_test_func TSAN'
alias kudu_build_tsandebug='kudu_make_and_test_func TSANDEBUG'
alias kudu_build_client='kudu_make_and_test_func CLIENT'
alias kudu_build_coverage='kudu_make_and_test_func COVERAGE; (set -x; lcov --capture --directory src --output-file coverage.info && genhtml coverage.info --output-directory out)'
alias kudu_build_heapcheck='kudu_make_and_test_func HEAPCHECK'
alias kudu_build_release='kudu_make_and_test_func RELEASE'

alias kudu_cmake='kudu_run_cmake_func DEBUG'
alias kudu_cmake_dyn='kudu_run_cmake_func DYNDEBUG'
alias kudu_cmake_dynclang='kudu_run_cmake_func DYNCLANG'
alias kudu_cmake_clang='kudu_run_cmake_func CLANGDEBUG'
alias kudu_cmake_asan='kudu_run_cmake_func ASAN'
alias kudu_cmake_asandebug='kudu_run_cmake_func ASANDEBUG'
alias kudu_cmake_coverage='kudu_run_cmake_func COVERAGE'
alias kudu_cmake_tsan='kudu_run_cmake_func TSAN'
alias kudu_cmake_tsandebug='kudu_run_cmake_func TSANDEBUG'
alias kudu_cmake_client='kudu_run_cmake_func CLIENT'
alias kudu_cmake_release='kudu_run_cmake_func RELEASE'

alias kbt='rm -rf /tmp/kudutest-1000 && date && time $DEVTOOLSET $CMAKE_MAKE_PROG -j${NUM_PROCS_MINUS_ONE} $NINJA_OPTS && ( export TSAN_OPTIONS="$TSAN_OPTIONS second_deadlock_stack=1 suppressions=$(pwd)/build-support/tsan-suppressions.txt history_size=7 external_symbolizer_path=$LLVM_SYMBOLIZER"; unset GLOG_colorlogtostderr; date; time ctest -j${NUM_PROCS_MINUS_ONE}); alert "kbt exited with return code=$?"'
alias skbt='rm -rf /tmp/kudutest-1000 && date && time $DEVTOOLSET $CMAKE_MAKE_PROG -j${NUM_PROCS_MINUS_ONE} $NINJA_OPTS && ( export KUDU_ALLOW_SLOW_TESTS=1; export TSAN_OPTIONS="$TSAN_OPTIONS second_deadlock_stack=1 suppressions=$(pwd)/build-support/tsan-suppressions.txt history_size=7 external_symbolizer_path=$LLVM_SYMBOLIZER"; unset GLOG_colorlogtostderr; date; time ctest -j${NUM_PROCS_MINUS_ONE}); alert "skbt exited with return code=$?"'
#alias hkbt='rm -rf /tmp/kudutest-1000 && kudu_build_func HEAPCHECK && ( export HEAPCHECK=normal; export KUDU_ALLOW_SLOW_TESTS=1; export TSAN_OPTIONS="$TSAN_OPTIONS second_deadlock_stack=1 suppressions=$(pwd)/build-support/tsan-suppressions.txt history_size=7 external_symbolizer_path=$LLVM_SYMBOLIZER"; date; time ctest -j${NUM_PROCS_MINUS_ONE}); alert "hkbt exited with return code=$?"'

ktt_func() {
  if [ -z "$1" ]; then
    echo "Must specify test name"
    return 1
  fi
  (
    TESTNAME=$1
    shift
    echo "KUDU_ALLOW_SLOW_TESTS=$KUDU_ALLOW_SLOW_TESTS"
    export TSAN_OPTIONS="$TSAN_OPTIONS second_deadlock_stack=1 suppressions=$(pwd)/../../build-support/tsan-suppressions.txt history_size=7 external_symbolizer_path=$LLVM_SYMBOLIZER"
    echo "TSAN_OPTIONS=$TSAN_OPTIONS"
    date
    set -x
    time ./bin/$TESTNAME $*
    RETCODE=$?
    set +x
    date
    # set $? to nonzero for alert()
    if [[ $RETCODE == 0 ]]; then
      /bin/true
    else
      /bin/false
    fi
    alert "$TESTNAME exited with return code=$RETCODE"
    return $RETCODE
  )
}

sktt_func() {
  (
    export KUDU_ALLOW_SLOW_TESTS=1
    ktt_func $*
  )
}

hktt_func() {
  (
    export HEAPCHECK=normal
    sktt_func $*
  )
}

kbtt_func() {
  TESTNAME=$1
  if [ -z "$TESTNAME" ]; then
    echo "Must specify test name"
    return 1
  fi
  (
    date
    set -ex
    time $DEVTOOLSET $CMAKE_MAKE_PROG -j${NUM_PROCS_MINUS_ONE} $NINJA_OPTS $1
    set +ex
    date
    ktt_func $*
  )
}

cbtt_func() {
  TESTNAME=$1
  if [ -z "$TESTNAME" ]; then
    echo "Must specify test name"
    return 1
  fi
  (
    unset GLOG_colorlogtostderr # avoid ANSI color garbage in the logs
    date
    set -x
    time $DEVTOOLSET $CMAKE_MAKE_PROG -j${NUM_PROCS_MINUS_ONE} $NINJA_OPTS $TESTNAME || return $?
    date
    time ../../build-support/run-test.sh ./bin/$TESTNAME $@
    RETCODE=$?
    set +x
    date
    # set $? to nonzero for alert()
    if [[ $RETCODE == 0 ]]; then
      /bin/true
    else
      /bin/false
    fi
    alert "$TESTNAME exited with return code=$RETCODE"
    return $RETCODE
  )
}

scbtt_func() {
  (
    export KUDU_ALLOW_SLOW_TESTS=1
    cbtt_func $*
  )
}

skbtt_func() {
  (
    export KUDU_ALLOW_SLOW_TESTS=1
    kbtt_func $*
  )
}

hkbtt_func() {
  (
    export HEAPCHECK=normal
    skbtt_func $*
  )
}

gdbtt_func() {
  if [ -z "$1" ]; then
    echo "Must specify test name"
    return 1
  fi
  (
    export KUDU_ALLOW_SLOW_TESTS=1
    export ASAN_OPTIONS=abort_on_error=1
    TESTNAME=$1
    echo "KUDU_ALLOW_SLOW_TESTS=$KUDU_ALLOW_SLOW_TESTS"
    export TSAN_OPTIONS="$TSAN_OPTIONS second_deadlock_stack=1 suppressions=$(pwd)/../../build-support/tsan-suppressions.txt history_size=7 external_symbolizer_path=$LLVM_SYMBOLIZER"
    echo "TSAN_OPTIONS=$TSAN_OPTIONS"
    shift
    date
    set -e
    set -x
    time $DEVTOOLSET $CMAKE_MAKE_PROG -j${NUM_PROCS_MINUS_ONE} $NINJA_OPTS $TESTNAME
    date
    GDB=$(which gdb)
    eval "$GDB $LOCAL_GDB_ARGS --args ./bin/$TESTNAME --gtest_break_on_failure $*"
  )
}

# TSAN-compatible GDB
tsgdbtt_func() {
  (
    export LOCAL_GDB_ARGS="-ex 'set disable-randomization off' -ex 'b __tsan::PrintReport'"
    gdbtt_func $*
  )
}

klog_func() {
  (
    set -x
    vim ./test-logs/$1.txt
  )
}

alias kbf='$DEVTOOLSET $CMAKE_MAKE_PROG -j12 $NINJA_OPTS' # kudu-build-fast
alias ktt=ktt_func
alias sktt=sktt_func
alias hktt=hktt_func
alias kbtt=kbtt_func
alias cbtt=cbtt_func
alias scbtt=scbtt_func
alias skbtt=skbtt_func
alias hkbtt=hkbtt_func
alias gdbtt=gdbtt_func
alias tsgdbtt=tsgdbtt_func

alias readmes='find src/ -type f | egrep "README|\.txt$" | egrep -v "CMake|CTest" | grep -v \.swp'
alias perfstat='perf stat -d -e task-clock -e context-switches -e cpu-migrations -e page-faults -e cycles -e instructions  -e branches -e branch-misses -e bus-cycles -e stalled-cycles-frontend -e stalled-cycles-backend -e ref-cycles -e context-switches -e L1-icache-loads -e L1-icache-load-misses -e L1-dcache-loads -e L1-dcache-load-misses -e dTLB-loads -e dTLB-load-misses -e iTLB-loads -e iTLB-load-misses -e branch-loads -e branch-load-misses -e cache-misses'

alias kudu_buildinfo="egrep 'CMAKE_BUILD_TYPE|KUDU_USE_' CMakeCache.txt | perl -pe 's/:\w+//'"
alias klog=klog_func
alias heapcheck='set -x; export HEAPCHECK=normal; export LD_BIND_NOW=1; set +x'

alias n='$DEVTOOLSET $CMAKE_MAKE_PROG'
alias cls='printf "\033c"'

alias pyhttpd='python -m SimpleHTTPServer'
alias tl="vim ~/todo-list.txt"

# Easy command to run for backups.
alias backup_homedir="mountpoint /media/mpercy/mpercy-backup && rsync -avz /home/mpercy /media/mpercy/mpercy-backup/root/home/"

# Rebase current git branch on master.
rebase_updated_branch() {
  local base_branch=$1
  (
  if [ -z "$base_branch" ]; then
    echo "Error: Must specify a branch to rebase onto"
    return 1
  fi
  set -xe
  if cur_branch=$(git symbolic-ref --short -q HEAD); then
    update $base_branch
    git checkout $cur_branch
    git rebase $base_branch
  else
    echo "Error: Not currently on any branch"
    return 1
  fi
  )
}

alias rebase_updated_master='rebase_updated_branch master'
alias rebase_updated_trunk='rebase_updated_branch trunk'

do_ntp_reset() {
  NTP_SERVER=pool.ntp.org
  set -x
  sudo service ntp stop || return
  sudo ntpdate "$NTP_SERVER" || return
  sudo service ntp start || return
  set +x
}

alias ntp-reset=do_ntp_reset
alias gist='gist-paste -po'
alias md='pandoc -f markdown_github -t html'
alias nm-restart='sudo service network-manager restart'
alias bt-restart='sudo service bluetooth restart'

alias bootstrap_vundle='[ ! -e ~/.vim/bundle/Vundle.vim ] && git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim && vim +PluginInstall +qall'

# For Flume contributors.
git_reset_author() {
  AUTHOR=$1
  if [ -z "$AUTHOR" ]; then
    echo "Error: Must specify author"
    return
  fi
  set -ex
  git commit --amend --no-edit --author="$AUTHOR"
  git log -n1
  set +ex
}

alias git_reset_author_lior='git_reset_author "Lior Zeno <liorzino@gmail.com>"'
alias git_reset_author_denes='git_reset_author "Denes Arvay <denes@cloudera.com>"'
alias git_reset_author_donat='git_reset_author "Bessenyei Balázs Donát <bessbd@cloudera.com>"'
alias git_reset_author_jholoman='git_reset_author "Jeff Holoman <jeff.holoman@gmail.com>"'
alias git_reset_author_tinawenqiao='git_reset_author "wenqiao <315524513@qq.com>"'
alias git_reset_author_granthenke='git_reset_author "Grant Henke <granthenke@gmail.com>"'
alias git_reset_author_sati='git_reset_author "Attila Simon <sati@cloudera.com>"'

# TODO: shouldn't this get sourced by the shell automatically somehow anyway?
. ~/.bash_completions
