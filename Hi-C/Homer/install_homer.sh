#!/bin/bash
# Install HOMER to /mnt/Storage3/ifar/tools/homer/
# Run once. Requires perl and wget.

HOMER_DIR=/mnt/Storage3/ifar/tools/homer

cd $HOMER_DIR

echo "[$(date)] Downloading HOMER installer..."
wget -q http://homer.ucsd.edu/homer/configureHomer.pl -O configureHomer.pl

echo "[$(date)] Installing HOMER..."
perl configureHomer.pl -install

echo "[$(date)] Installing hg38 genome..."
perl configureHomer.pl -install hg38

echo "[$(date)] Done. Add to PATH:"
echo "  export PATH=$HOMER_DIR/bin:\$PATH"
