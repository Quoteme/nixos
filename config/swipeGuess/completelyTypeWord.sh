#!/usr/bin/env bash

type=wtype
while read -r word; do
	echo "${word#?}"
	test "${word#?}" && $type "${word#?}"
done
