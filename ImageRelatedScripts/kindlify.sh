#!/bin/bash
###
#from http://www.unwesen.de/2011/08/09/kindle-as-comic-book-reader/
###
# Copyright (C) 2011 by Jens Finkhaeuser <unwesen@users.sourceforge.net>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

##############################################################################
# Constants

# Target dimensions for images
CBZ_TARGET_WIDTH=525
CBZ_TARGET_HEIGHT=640
PDF_TARGET_WIDTH=600
PDF_TARGET_HEIGHT=800

# Precision of floating point calculations
FLOAT_SCALE=5

# If a detected scale of the image differs by more than this from the
# previously detected conversion factor, we assume it to be a double page.
DOUBLE_PAGE_THRESHOLD=0.075

##############################################################################
# Evaluate a floating point number expression.

function float_eval()
{
  local stat=0
  local result=0.0
  if [[ $# -gt 0 ]]; then
    result=$(echo "scale=$FLOAT_SCALE; $*" | bc -q 2>/dev/null)
    stat=$?
    if [[ $stat -eq 0  &&  -z "$result" ]]; then stat=1; fi
  fi
  echo $result
  return $stat
}


##############################################################################
# Evaluate a floating point number conditional expression.

function float_cond()
{
    local cond=0
    if [[ $# -gt 0 ]]; then
        cond=$(echo "$*" | bc -q 2>/dev/null)
        if [[ -z "$cond" ]]; then cond=0; fi
        if [[ "$cond" != 0  &&  "$cond" != 1 ]]; then cond=0; fi
    fi
    local stat=$((cond == 0))
    return $stat
}


##############################################################################
# Bash tweaks
set -e

##############################################################################
# Target/source; parameter parsing
INPUTFILE="$1"
if [ -z "$INPUTFILE" ] ; then
  echo "usage: $(basename $0) <input file> [output file]" >&2
  exit 1
fi

dir=$(dirname "$INPUTFILE")
if [ "$dir" = "." ] ; then
  INPUTFILE="$PWD/$INPUTFILE"
fi


NAME=$(echo $INPUTFILE | sed 's/\(.*\)\.\([^.][^.]*\)/\1/g')
EXT=$(echo $INPUTFILE | sed 's/\(.*\)\.\([^.][^.]*\)/\2/g')

if [ ! -z "$2" ] ; then
  OUTPUTFILE="$2"
  O_NAME=$(echo $OUTPUTFILE | sed 's/\(.*\)\.\([^.][^.]*\)/\1/g')
  O_EXT=$(echo $OUTPUTFILE | sed 's/\(.*\)\.\([^.][^.]*\)/\2/g')
  O_EXT=$(echo "$O_EXT" | tr '[A-Z]' '[a-z]')

  case $O_EXT in
    pdf)
      TARGET_WIDTH=$PDF_TARGET_WIDTH
      TARGET_HEIGHT=$PDF_TARGET_HEIGHT
      ;;
    cbz)
      TARGET_WIDTH=$CBZ_TARGET_WIDTH
      TARGET_HEIGHT=$CBZ_TARGET_HEIGHT
      ;;
    *)
      echo "Output file must be .cbz or .pdf!" >&2
      exit 2
      ;;
  esac
fi

if [ -z "$OUTPUTFILE" ] ; then
  O_NAME="$NAME (Kindle)"
  O_EXT="pdf"
  OUTPUTFILE="$O_NAME.$O_EXT"

  TARGET_WIDTH=$PDF_TARGET_WIDTH
  TARGET_HEIGHT=$PDF_TARGET_HEIGHT
fi


##############################################################################
# Extract existing file
TEMPDIR=$(mktemp -d kindlify.tmp.XXXXXXXXXX --tmpdir)
ORIGDIR="$TEMPDIR/orig"
mkdir -p "$ORIGDIR"

echo "== Extracting archive..."
pushd "$ORIGDIR" >/dev/null
case $EXT in
  cbr|rar)
    unrar x "$INPUTFILE" >/dev/null
    ;;
  cbz|zip)
    unzip "$INPUTFILE" >/dev/null
    ;;
  cbt|tar.gz|tgz)
    tar xfz "$INPUTFILE" >/dev/null
    ;;
esac
popd >/dev/null

FILELIST="$TEMPDIR/filelist"
find "$ORIGDIR" -type f >"$FILELIST"

##############################################################################
# Find conversion factor
CONVERT_FACTOR=

echo "== Scanning files..."
while read infile ; do
  width=$(identify -format "%w" "$infile")
  height=$(identify -format "%h" "$infile")

  w_factor=$(float_eval "$TARGET_WIDTH / $width")
  h_factor=$(float_eval "$TARGET_HEIGHT / $height")
  factor=
  if float_cond "$w_factor > $h_factor" ; then
    factor="$h_factor"
  else
    factor="$w_factor"
  fi

  if [ -z "$CONVERT_FACTOR" ] ; then
    CONVERT_FACTOR="$factor"
  elif float_cond "$factor < $CONVERT_FACTOR" ; then
    jump=$(float_eval "($CONVERT_FACTOR / $factor) - 1.0")

    if float_cond "$jump > $DOUBLE_PAGE_THRESHOLD" ; then
      echo "Double page detected!"
    else
      CONVERT_FACTOR="$factor"
      echo "New conversion factor: $CONVERT_FACTOR"
    fi
    echo "   from file '$(basename "$infile")' of dimensions $width x $height"
  fi
done <"$FILELIST"

##############################################################################
# Convert files
OUTDIR="$TEMPDIR/out"
mkdir -p "$OUTDIR"

echo "== Converting files..."
pushd "$OUTDIR" >/dev/null
while read infile ; do
  outfile="$(echo "$infile" | sed "s:$ORIGDIR:$OUTDIR:g")"
  if [ "$O_EXT" = "pdf" ] ; then
    outfile="$outfile.pdf"
  fi

  dir="$(dirname "$outfile")"
  mkdir -p "$dir"

  width=$(identify -format "%w" "$infile")
  height=$(identify -format "%h" "$infile")

  n_width=$(float_eval "$width * $CONVERT_FACTOR" | cut -d. -f1)
  n_height=$(float_eval "$height * $CONVERT_FACTOR" | cut -d. -f1)

  convert "$infile" -resize "${n_width}x${n_height}!" "$outfile"
done <"$FILELIST"
popd >/dev/null

##############################################################################
# Create new book

echo "== Creating output file..."
case $O_EXT in
  pdf)
    outlist="$TEMPDIR/outlist"
    find "$OUTDIR" -type f | sort -u >"$outlist"
    PDFS=
    while read outfile ; do
      PDFS="$PDFS '$outfile'"
    done <"$outlist"

    tmpfile="$TEMPDIR/tmp.pdf"
    eval gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile="$tmpfile" $PDFS
    mv "$tmpfile" "$OUTPUTFILE"
    ;;
  cbz)
    pushd "$OUTDIR" >/dev/null
    zip -r9 "$OUTPUTFILE" * >/dev/null
    popd >/dev/null
    echo "Done."
    ;;
esac

##############################################################################
# Cleanup
rm -r "$TEMPDIR"
