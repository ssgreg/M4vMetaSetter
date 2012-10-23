#! /bin/bash

# configuration
pathToSublerCLI=~/Documents/SublerCLI/SublerCLI
maskVideoToConvert="*.m4v"


# metadata builder

function MakeMetadata()
{
  local metaTemplate=""
  metaTemplate+=$(MetaMediaKind "TV Show")
  metaTemplate+=$(MetaTvShow "$1")
  metaTemplate+=$(MetaTvSeason "$2")
  metaTemplate+=$(MetaArtwork "$3")
  echo "$metaTemplate"
}


# metadata primitives

function MetaMediaKind()
{
  printf "{Media Kind:%s}" "$1"
}

function MetaTvShow()
{
  printf "{TV Show:%s}" "$1"
}

function MetaTvSeason()
{
  printf "{TV Season:%s}" "$1"
}

function MetaArtwork()
{
  printf "{Artwork:%s}" "$1"
}

function Convert()
{
  local file="$1"
  local tmpfile="$file".tmp
  local metadata="$2"

  "$pathToSublerCLI" -source "$file" -dest "$tmpfile" -metadata "$metadata" >> subler.log || exit $?
  rm -f "$file"
  mv "$tmpfile" "$file"
}

function BatchJob()
{
  local metadata=$(MakeMetadata "$@")
  echo "Meta: $metadata"

  while read file
  do
    if [ "$file" != "." ]; then
      echo "Converting: $file"
      Convert "$file" "$metadata" || exit $?
    fi
  done
}

function PrintUsage()
{
  echo "Usage: "
}

function Main()
{
  if [ "$#" != 3 ]; then
    echo "Usage:"
    echo "metasetter TvShowName SeasonNumber ArtworkPath"
    echo "Example:"
    echo "metasetter \"House M.D.\" 1 \"\\Users\\greg\\Pictures\\covers\\housemd 1.png\""
    exit
  fi
  find . -name "$maskVideoToConvert" -maxdepth 1 | BatchJob "$@"
}


# entry point
Main "$@"
