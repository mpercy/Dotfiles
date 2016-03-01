# .bash_aliases

# emacs
alias e='emacs -nw'

alias f='cd ~/src/flume'
alias k='cd ~/src/kudu'

# Git shortcuts
update_func() {
  BRANCH=$1
  if [[ -z "$BRANCH" ]]; then
    echo "Usage: update <branch>"
    exit 1
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

LLVM_SYMBOLIZER=/home/mpercy/src/kudu/thirdparty/clang-toolchain/bin/llvm-symbolizer

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


kudu_run_cmake_func() {
  (
    set -x
    BUILD_TYPE=$1
    if [ -z "$BUILD_TYPE" ]; then
      echo Error: Must specify build type
      return
    fi

    if [ -z "$NO_REBUILD_THIRDPARTY" ]; then
      ./thirdparty/build-if-necessary.sh
    fi

    rm -Rf CMakeCache.txt CMakeFiles/
    CMAKE_OPTS="-DCMAKE_EXPORT_COMPILE_COMMANDS=1"
    case $BUILD_TYPE in
      DYNDEBUG)
        cmake ../.. -G Ninja $CMAKE_OPTS -DCMAKE_BUILD_TYPE=debug
        ;;
      DEBUG)
        cmake ../.. -G Ninja $CMAKE_OPTS -DKUDU_LINK=static -DCMAKE_BUILD_TYPE=debug
        ;;
      CLANGDEBUG)
        CC=clang CXX=clang++ cmake ../.. -G Ninja $CMAKE_OPTS -DKUDU_LINK=static -DCMAKE_BUILD_TYPE=debug
        ;;
      DYNCLANG)
        # Probably the fastest build method.
        CC=clang CXX=clang++ cmake ../.. -G Ninja $CMAKE_OPTS -DKUDU_LINK=dynamic -DCMAKE_BUILD_TYPE=debug
        ;;
      ASAN)
        CC=clang CXX=clang++ cmake ../.. -G Ninja $CMAKE_OPTS -DCMAKE_BUILD_TYPE=fastdebug -DKUDU_USE_ASAN=1 -DKUDU_USE_UBSAN=1 .
        ;;
      ASANDEBUG)
        CC=clang CXX=clang++ cmake ../.. -G Ninja $CMAKE_OPTS -DKUDU_LINK=static -DCMAKE_BUILD_TYPE=debug -DKUDU_USE_ASAN=1 -DKUDU_USE_UBSAN=1 .
        ;;
      TSAN)
        CC=clang CXX=clang++ cmake ../.. -G Ninja $CMAKE_OPTS -DCMAKE_BUILD_TYPE=fastdebug -DKUDU_USE_TSAN=1
        ;;
      CLIENT)
        CC=clang CXX=clang++ cmake ../.. -G Ninja $CMAKE_OPTS -DCMAKE_BUILD_TYPE=debug -DKUDU_EXPORTED_CLIENT=1
        ;;
      RELEASE|HEAPCHECK)
        cmake ../.. -G Ninja $CMAKE_OPTS -DCMAKE_BUILD_TYPE=release
        ;;
    esac
    ninja clean
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
  && time ninja -j7 $NINJA_OPTS
}

kudu_make_and_test_func() {
  BUILD_TYPE=$1
  kudu_build_func $BUILD_TYPE \
  && rm -rf /tmp/kudutest-1000 \
  && date \
  && time ctest -j7
}

alias kudu_build='kudu_make_and_test_func DEBUG'
alias kudu_build_dyn='kudu_make_and_test_func DYNDEBUG'
alias kudu_build_dyn_clang='kudu_make_and_test_func DYNCLANG'
alias kudu_build_clang='kudu_make_and_test_func CLANGDEBUG'
alias kudu_build_asan='kudu_make_and_test_func ASAN'
alias kudu_build_asandebug='kudu_make_and_test_func ASANDEBUG'
alias kudu_build_tsan='kudu_make_and_test_func TSAN'
alias kudu_build_client='kudu_make_and_test_func CLIENT'
alias kudu_build_coverage='kudu_make_and_test_func COVERAGE; (set -x; lcov --capture --directory src --output-file coverage.info && genhtml coverage.info --output-directory out)'
alias kudu_build_heapcheck='kudu_make_and_test_func HEAPCHECK'
alias kudu_build_release='kudu_make_and_test_func RELEASE'

alias kudu_cmake='kudu_run_cmake_func DEBUG'
alias kudu_cmake_dyn='kudu_run_cmake_func DYNDEBUG'
alias kudu_cmake_dyn_clang='kudu_run_cmake_func DYNCLANG'
alias kudu_cmake_clang='kudu_run_cmake_func CLANGDEBUG'
alias kudu_cmake_asan='kudu_run_cmake_func ASAN'
alias kudu_cmake_asandebug='kudu_run_cmake_func ASANDEBUG'
alias kudu_cmake_tsan='kudu_run_cmake_func TSAN'
alias kudu_cmake_client='kudu_run_cmake_func CLIENT'
alias kudu_cmake_release='kudu_run_cmake_func RELEASE'

alias kbt='rm -rf /tmp/kudutest-1000 && date && time ninja -j7 $NINJA_OPTS && ( export TSAN_OPTIONS="$TSAN_OPTIONS second_deadlock_stack=1 suppressions=$(pwd)/build-support/tsan-suppressions.txt history_size=7 external_symbolizer_path=$LLVM_SYMBOLIZER"; unset GLOG_colorlogtostderr; date; time ctest -j7); alert "kbt exited with return code=$?"'
alias skbt='rm -rf /tmp/kudutest-1000 && date && time ninja -j7 $NINJA_OPTS && ( export KUDU_ALLOW_SLOW_TESTS=1; export TSAN_OPTIONS="$TSAN_OPTIONS second_deadlock_stack=1 suppressions=$(pwd)/build-support/tsan-suppressions.txt history_size=7 external_symbolizer_path=$LLVM_SYMBOLIZER"; unset GLOG_colorlogtostderr; date; time ctest -j7); alert "skbt exited with return code=$?"'
#alias hkbt='rm -rf /tmp/kudutest-1000 && kudu_build_func HEAPCHECK && ( export HEAPCHECK=normal; export KUDU_ALLOW_SLOW_TESTS=1; export TSAN_OPTIONS="$TSAN_OPTIONS second_deadlock_stack=1 suppressions=$(pwd)/build-support/tsan-suppressions.txt history_size=7 external_symbolizer_path=$LLVM_SYMBOLIZER"; date; time ctest -j7); alert "hkbt exited with return code=$?"'

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
    time ninja -j7 $NINJA_OPTS $1
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
    time ninja -j7 $NINJA_OPTS $TESTNAME || return $?
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
    export HEAPCHECK=normal
    export ASAN_OPTIONS=abort_on_error=1
    TESTNAME=$1
    echo "KUDU_ALLOW_SLOW_TESTS=$KUDU_ALLOW_SLOW_TESTS"
    export TSAN_OPTIONS="$TSAN_OPTIONS second_deadlock_stack=1 suppressions=$(pwd)/../../build-support/tsan-suppressions.txt history_size=7 external_symbolizer_path=$LLVM_SYMBOLIZER"
    echo "TSAN_OPTIONS=$TSAN_OPTIONS"
    shift
    date
    set -e
    set -x
    time ninja -j7 $NINJA_OPTS $TESTNAME
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

alias kbf="ninja -j12 $NINJA_OPTS" # kudu-build-fast
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

alias n=ninja
alias cls='printf "\033c"'

alias pyhttpd='python -m SimpleHTTPServer'
alias tl="vim ~/todo-list.txt"

# Easy command to run for backups.
alias backup_homedir="mountpoint /media/mpercy/mpercy-backup && rsync -avz /home/mpercy /media/mpercy/mpercy-backup/root/home/"

# Rebase current git branch on master.
rebase_updated_master() {
  (
  set -xe
  if branch=$(git symbolic-ref --short -q HEAD); then
    update master
    git checkout $branch
    git rebase master
  else
    echo not on any branch
    return 1
  fi
  )
}

ntp_reset() {
  set -e
  sudo service ntp stop
  NTP_SERVER="$(grep ^server /etc/ntp.conf | head -1 | awk '{print $2}')"
  echo "Hard resetting clock from NTP server ${NTP_SERVER}..."
  set -x
  sudo ntpdate "$NTP_SERVER"
  set +x
  sudo service ntp start
  set +e
}

alias gist='gist-paste -po'

alias bootstrap_vundle='[ ! -e ~/.vim/bundle/Vundle.vim ] && git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim && vim +PluginInstall +qall'

# TODO: shouldn't this get sourced by the shell automatically somehow anyway?
. ~/.bash_completions
