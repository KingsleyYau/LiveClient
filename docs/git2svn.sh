#!/bin/sh

GIT_URL=$1
SVN_URL=$(echo "$1" | sed s/tree[/][A-Za-z0-9]*/trunk/g)
echo $SVN_URL
CMD="svn co $SVN_URL"
$CMD