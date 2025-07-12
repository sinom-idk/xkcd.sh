#!/bin/bash
# xkcd.sh — XKCD comics from the terminal
#
# Description:
#   Display XKCD comics in the terminal using timg.
#
# Dependencies:
#   - curl
#   - jq
#   - timg
#
# Usage:
#   ./xkcd.sh -l         # latest comic
#   ./xkcd.sh -n xyzt    # specific comic
#   ./xkcd.sh -r         # random comic
#   ./xkcd.sh -h         # help
#
# Credits:
#   All content belongs to XKCD (https://xkcd.com)

# Check Dependencies
if ! command -v curl jq timg >/dev/null 2>&1 ; then
  echo "Dependencies required are curl, jq and timg"
fi

# Flags
l_flag=''
r_flag=''
h_flag=''
n_flag=''

# Help
print_usage() {
  echo "-l for latest"
  echo "-n xyzt for a specific comic"
  echo "-r for random"
  echo "-h for help"
  echo "requires timg and jq :/"
}

# No flags
if [ $# -eq 0 ]; then
  print_usage
  exit 0
fi

# Check arguments
no_arg() {
  if [[ -z "$n_flag" ]]; then
    print_usage
    exit 1
  fi
}

# Check flags
while getopts 'lrhn:' flag; do
  case "${flag}" in
    l) url=$(curl -Ls -o /dev/null -w '%{url_effective}' https://xkcd.com/) ;;
    r) url=$(curl -Ls -o /dev/null -w '%{url_effective}' https://c.xkcd.com/random/comic/) ;;
    h) print_usage; exit 0;;
    n) n_flag="${OPTARG}"; no_arg; url=$(curl -Ls -o /dev/null -w '%{url_effective}' https://xkcd.com/"${OPTARG}") ;;
    \?) print_usage; exit 1 ;;
  esac
done

# Append /info.0.json to get comic metadata
json=$(curl -s "${url}info.0.json")

# Get the image URL and comic number
title=$(echo "$json" | jq -r .safe_title)
number=$(echo "$json" | jq -r .num)

# Get the date of the comic (why are they all spread out in the json anyway?)
day=$(echo "$json" | jq -r .day)
month=$(echo "$json" | jq -r .month)
year=$(echo "$json" | jq -r .year)

# Get image url and alt text
img_url=$(echo "$json" | jq -r .img)
alt=$(echo "$json" | jq -r .alt)


echo "$title ($number)"
timg "$img_url"
echo "$alt"
echo "$day/$month/$year"
echo "source: $url"
