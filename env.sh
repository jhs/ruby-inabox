#!/bin/bash
#
# Activate the Ruby environment. This script is idempotent and runs silently when not connected to a terminal.

original_under="$_"

this_file="$BASH_SOURCE"
if [ -z "$this_file" ]; then
    this_file="$0"
fi

# Since this script sets the environment, it must be sourced. Running it in a subshell is pointless.
# Detection confirmed to work for ./env.sh, . env.sh, source env.sh, $SHELL env.sh for all of:
#  * Bash
#  * Zsh
#  * Dash
if [ $(basename -- "$0") = 'env.sh' ]; then
    err="This script must be sourced, not run standalone"

    if [ "$ZSH_NAME" ]; then
        # Re-confirm for Zsh since the above test does not work.
        if [ "$original_under" != "$0" ]; then
            echo "$err" >&2
            exit 1
        fi
    else
        echo "$err" >&2
        exit 1
    fi
fi

abspath ()
{
    if [ `uname` = 'Darwin' ]; then
        ruby -e "puts File.expand_path('$1')"
    else
        readlink -f "$1"
    fi
}

puts ()
{
    if [ -t 2 ]; then
        echo "$*" >&2
    fi
}

confirm_build ()
{
    program="$1"
    expected_path="$2"
    expected_version="$3"

    location=$( /usr/bin/which "$program" )
    if [ "$location" != "$expected_path" ]; then
        echo "Failed to find expected build in $expected_path; location was $location" >&2
        #echo "PATH: $PATH"
        #echo "path: $path"
        return 1
    else
        if ! "$location" --version > /dev/null; then
            echo "Failed to run build: $location" >&2
            return 1
        else
            if [ -z "$expected_version" ]; then
                # No version equivalence test.
                puts "Confirmed build: $location"
            else
                actual_version=$( $location --version | perl -ne 'print "$1" if(/([\d\.]+)/)' )
                if [ "$actual_version" != "$expected_version" ]; then
                    echo "$location $actual_version is not version $expected_version" >&2
                    return 1
                else
                    puts "Confirmed build $expected_version: $location"
                fi
            fi
        fi
    fi

    unset actual_version program expected_path expected_version location
}

here="$( pwd )"
trap 'return_here' INT TERM
return_here () {
    cd "$here"
    [ -d "$workdir" ] && rm -rf "$workdir"
}

in_temp_dir () {
    cmd="$1"; shift
    template="$cmd.XXXXXX"
    if mktemp -V 2> /dev/null | grep --quiet coreutils; then
        workdir=$( mktemp --tmpdir -d "$template" )
    else
        workdir=$( mktemp -d -t "$template" )	# -d before -t works on Darwin and old Ubuntu.
    fi

    puts "Doing $cmd in $workdir"
    trap 'return_here' INT TERM
    "$cmd" "$@"
    return_here
    trap - INT TERM
}

# Idempotently insert a directory into the search path.
insert_in_path () {
    desired="$1"
    if [ ! -d "$desired" ]; then
        mkdir -p "$desired"
    fi

    desired=$(abspath "$desired")

    if ! echo "$PATH" | grep --quiet "$desired"; then
        puts "Adding to PATH: $desired"
        PATH="$desired:$PATH"
    fi
}

main () {
    box_home=$(dirname $(abspath "$this_file"))
    build="$box_home/build"

    ruby_src=$( perl -e "print [ sort(<$box_home/components/ruby-*>) ] -> [-1]" )   # Change this to specify your preferred Ruby version.
    gems_src=$( echo "$box_home/components"/rubygems-* )
    rake_gem=$( echo "$box_home/components"/rake-*.gem )

    # Just double-checking.
    for src in "$ruby_src" "$gems_src" "$rake_gem"; do
        if [ ! -d "$src" -a ! -f "$src" ]; then
            echo "Cannot find source: $src" >&2
            return 1
        fi
    done

    insert_in_path "$build/bin"

    # Install Ruby.
    if ! confirm_build ruby "$build/bin/ruby" 2> /dev/null; then
        puts "Installing Ruby from $ruby_src"

        for req in gcc make bison; do
            if ! "$req" --version > /dev/null 2> /dev/null; then
                echo "Cannot run $req" >&2
                return 1
            fi
        done

        ruby_build () {
            cd "$workdir"
            "$ruby_src/configure" "--prefix=$build" && make && make install || return 1
        }
        in_temp_dir ruby_build
        unset ruby_build
    fi

    confirm_build ruby "$build/bin/ruby" || return 1

    # Install RubyGems.
    if ! confirm_build gem "$build/bin/gem" 2> /dev/null; then
        cd "$gems_src"
        ruby setup.rb --no-rdoc --no-ri
        cd "$here"
    fi

    confirm_build gem "$build/bin/gem" || return 1

    # Install Rake.
    if ! confirm_build rake "$build/bin/rake" 0.8.7 2> /dev/null; then
        gem install "$rake_gem"
    fi

    confirm_build rake "$build/bin/rake" 0.8.7 || return 1
}

# Hook into a possible parent project's Rake system.
rake_hook () {
    if [ -z "$project_parent" ]; then
        project_parent="$box_home/.."
    fi

    if [ "$include_parent_build" ]; then
        insert_in_path "$project_parent/build/bin"
    fi

    cd "$project_parent"
    job_hook=$( rake --silent --tasks 2> /dev/null | awk '/ruby_inabox/ {print $2}' )
    if [ "$job_hook" ]; then
        if [ -z "$skip_rake" ]; then
            puts "Executing $job_hook Rake task in parent project"
            rake $extra_rake_args "$job_hook"
        else
            puts "Skipping $job_hook Rake task in parent project"
        fi
    else
        puts "No 'ruby_inabox' Rake task found in parent directory"
    fi
    cd "$here"
}

main && rake_hook

# Clean up if everything went okay. (If it didn't go okay, well, you're on your own.)
trap - INT TERM

unset abspath
unset confirm_build
unset in_temp_dir
unset main
unset original_under
unset puts
unset rake_hook
unset return_here
unset this_file
unset build
unset workdir
unset cmd
unset failed
unset gems_src
unset rake_gem
unset ruby_src
unset src
unset job_hook
unset here

# vim: sts=4 sw=4 et
