#!/bin/bash
#
# Activate the Ruby environment. This script is idempotent and runs silently when not connected to a terminal.


if [ $(basename -- "$0") = 'env.sh' ]; then
    echo "This script should be sourced, not run standalone" >&2
    exit 1
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

    location=$( which "$program" )
    if [ "$location" != "$expected_path" ]; then
        echo "Failed to find expected build in $expected_path; location was $location" >&2
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

here=$( pwd )
trap 'return_here' INT TERM
return_here () {
    cd "$here"
    [ -d "$build_tmp" ] && rm -rf "$build_tmp"
}

in_temp_dir () {
    cmd="$1"; shift
    workdir=$( mktemp --tmpdir -d "$cmd.XXXXXX" )
    trap 'return_here' INT TERM
    "$cmd" "$@"
    return_here
    trap - INT TERM
}

box_home=$(dirname $(abspath "$BASH_SOURCE"))
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

if ! echo "$PATH" | grep --quiet "$build"; then
    puts 'Adding builds to PATH'
    PATH="$build/bin:$PATH"
fi

# Install Ruby.
if ! confirm_build ruby "$build/bin/ruby" 2> /dev/null; then
    puts "Installing Ruby from $ruby_src"

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

# Clean up if everything went okay. (If it didn't go okay, well, you're on your own.)
unset build
unset build_tmp
unset cmd
unset failed
unset gems_src
unset rake_gem
unset ruby_src
unset src

#
# Hook into a possible parent project's Rake system.
#

cd "$box_home/.."
job_hook=$( rake --tasks 2> /dev/null | awk '/ruby_inabox/ {print $2}' )
if [ "$job_hook" ]; then
    puts "Executing $job_hook Rake task in parent project"
    rake "$job_hook"
else
    puts "Not invoking 'ruby_inabox' Rake task in parent directory"
fi
cd "$here"

unset job_hook
unset here

# vim: sts=4 sw=4 et
