#!/bin/bash

set -e

source=$(pwd)
personal="$source/patches/personal"

printf "\n### APPLYING PERSONAL PATCHES ###\n";
sleep 1.0;
for path_personal in $(cd $personal; echo *); do
	tree="$(tr _ / <<<$path_personal | sed -e 's;platform/;;g')"
	printf "\n| $path_personal ###\n";
	pushd $tree

	for patch in $personal/$path_personal/*.patch; do
		# Check if patch is already applied
		if patch -f -p1 --dry-run -R < $patch > /dev/null; then
            printf "### ALREADY APPLIED: $patch \n";
			continue
		fi

		if git apply --check $patch; then
			git am $patch
		elif patch -f -p1 --dry-run < $patch > /dev/null; then
			#This will fail
			git am $patch || true
			patch -f -p1 < $patch
			git add -u
			git am --continue
		else
			printf "### FAILED APPLYING: $patch \n"
		fi
	done

	popd
done

rm -rf $1/patches
