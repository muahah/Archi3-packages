#!/bin/bash
# This file is part of the SwagArch GNU/Linux distribution
# Copyright (c) 2016 Mike Krüger
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

function make_pkg() {
    makepkg -f -s -c --sign
    gpg-connect-agent /bye
    killall gpg-agent
}

function copyto_upload_dir(){
    mv *.pkg.tar.xz ../upload
    mv *.pkg.tar.xz.sig ../upload
}

function make_loop() {
    mkdir upload
    for dir in */ ;
    do
        dir=${dir%*/}
        if [ "$dir" == "." ] || [ "$dir" == ".." ]; then
            continue;
        fi
	    cd $dir
	    make_pkg
        copyto_upload_dir
        echo "makepkg from "$dir" finished"
        cd ..
    done
}

make_loop
