#!/bin/sh
#list libs required for DWT on Ubuntu
cat libs-list | xargs  apt list -a --installed

