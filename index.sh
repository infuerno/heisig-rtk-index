#!/bin/bash
# Copyright (C) 2020 Aleksa Sarai <cyphar@cyphar.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

set -Eeuxo pipefail

WORKDIR="$(mktemp -d -t "heisig-rtk-index")"

FINALDIR="$WORKDIR/heisig-rtk-index"
mkdir -p "$FINALDIR"

# Remove any existing KANJIDIC2 copy
rm -f "kanjidic2.xml.gz"

# Generate the index
python ./scripts/index_primitives.py \
	--input primitives/INPUT.csv \
	--output "$WORKDIR/primitive_index" \
	primitives/

# Complete index
python ./scripts/index.py \
	--kanji kanji/KANJI_INDEX.csv \
	--primitives "$WORKDIR/primitive_index/PRIMITIVE_INDEX.csv" \
	--output "$FINALDIR/INDEX_VOL1.csv"

# Minimal index
python ./scripts/index.py \
	--filter MINIMAL_SET.txt \
	--kanji kanji/KANJI_INDEX.csv \
	--primitives "$WORKDIR/primitive_index/PRIMITIVE_INDEX.csv" \
	--output "$FINALDIR/INDEX_MINIMAL.csv"

# Move the media to $FINALDIR
rm -f "$WORKDIR/primitive_index/PRIMITIVE_INDEX.csv"
#mv "$WORKDIR/primitive_index/PRIMITIVE_INDEX.csv" "$FINALDIR/PRIMITIVE_INDEX.csv"
mv "$WORKDIR/primitive_index" "$FINALDIR/media"

# Make the zipfile
pushd "$WORKDIR"
ARCHIVENAME="$(basename "$FINALDIR")"
zip -9r "$ARCHIVENAME" "$ARCHIVENAME"
popd

echo "[+] Created $ARCHIVENAME.zip."
mv "$WORKDIR/$ARCHIVENAME.zip" .
