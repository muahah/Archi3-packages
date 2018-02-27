#!/bin/bash
# This file is part of the Archi3 GNU/Linux distribution
# Copyright (c) 2016 Mike Krüger, 2017 Launay Gaby
# 
# This program is free software: you can redistribute it and/or modify  
# it under the terms of the GNU General Public License as published by  
# the Free Software Foundation, version 3.
#
# This program is distributed in the hope that it will be useful, but 
# WITHOUT ANY WARRANTY; without even the implied warranty of 
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU 
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License 
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#

cur_dir=$(pwd)
release_dir=$cur_dir/release
packages_git_file=$cur_dir/packages/git-packages
packages_snap_dir=$cur_dir/tmp
packages_local_dir=$cur_dir/packages/packages_local

function update_git_snapshots() {
    rm -Rrf "$packages_snap_dir"
    mkdir -p "$packages_snap_dir"
    cd "$packages_snap_dir"
    while read url; do
        echo ""
        echo "+++ Cloning $url +++"
        git clone "$url";
    done < "$packages_git_file"
    for dir in */ ;
    do
        dir=${dir%*/}
        if [ "$dir" == "." ] || [ "$dir" == ".." ]; then
            continue;
        fi
            cd "$dir"
        cd ..
    done
    cd ..
    }

function copy_local_snapshots() {
    mkdir -p "$packages_snap_dir"
    echo ""
    echo "+++ Copying local packages +++"
    cp -r $packages_local_dir/* $packages_snap_dir
    }
    
function build_packages() {
    rm -rf "$release_dir"
    mkdir -p "$release_dir"
    for dir in $packages_snap_dir/* ;
    do
	echo ""
        echo "+++ Building $dir +++"
        dir=${dir%*/}
        if [ "$dir" == "." ] || [ "$dir" == ".." ] ; then
            continue;
        fi
	cd "$dir"
	makepkg -f -s --nosign
        mv *.pkg.tar.xz "$release_dir"
        cd "$cur_dir"
    done
}

function sign_packages(){
    cd "$release_dir"
    for f in *.pkg.tar.xz
    do
        echo "Signing $f file..."
        gpg --detach-sign --no-armor $f
    done
    cd $cur_dir
}

function create_repo() {
    echo "\n+++ Updating database"
    cd "$release_dir"
    repo-add archi3repo.db.tar.gz *.pkg.tar.xz
    rm archi3repo.db
    rm archi3repo.files
    cp archi3repo.db.tar.gz archi3repo.db
    cp archi3repo.files.tar.gz archi3repo.files
}

function clean() {
    rm -rf "$packages_snap_dir"
}

update_git_snapshots
copy_local_snapshots
build_packages
#sign_packages
create_repo
clean
