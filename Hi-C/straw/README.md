# Straw C++ for `.hic` files

This directory contains the vendored C++ implementation of [`aidenlab/straw`](https://github.com/aidenlab/straw) at commit `82fba9cf7f323a432bad4ac9a33d1ee65de00a47`.

`straw` reads raw or normalized contact records from Juicer `.hic` files at resolutions already stored in the input file.

## Requirements

- A C++14 compiler such as `g++`
- POSIX threads
- libcurl development headers and library
- zlib development headers and library
- Python 3 for the metadata example below

On Ubuntu or Debian:

```bash
sudo apt-get update
sudo apt-get install -y g++ libcurl4-openssl-dev zlib1g-dev
```

## Build

```bash
cd ~/PreprocessDB/Hi-C/straw
./build.sh
```

The executable is created at `~/PreprocessDB/Hi-C/straw/build/straw`.

If curl headers are outside the compiler's default search path, specify the directory containing `curl/curl.h`:

```bash
CURL_INCLUDE_DIR="$HOME/miniforge3/include" ./build.sh
```

Optionally add the executable to the current shell's `PATH`:

```bash
export PATH="$HOME/PreprocessDB/Hi-C/straw/build:$PATH"
```

## List resolutions stored in a `.hic` file

This `straw` command requires a bin size but has no metadata-listing subcommand. The following Python 3 command reads only the `.hic` header and prints its format version, genome, chromosome names, and stored base-pair resolutions.

Set `HIC` to the file to inspect:

```bash
HIC=/path/to/sample.hic python3 - <<'PY'
import os
import struct

path = os.environ["HIC"]

with open(path, "rb") as handle:
    def read_c_string():
        value = bytearray()
        while True:
            byte = handle.read(1)
            if not byte:
                raise EOFError("Unexpected end of .hic header")
            if byte == b"\0":
                return value.decode("utf-8")
            value.extend(byte)

    magic = read_c_string()
    if magic != "HIC":
        raise SystemExit(f"Not a .hic file: magic string is {magic!r}")

    version = struct.unpack("<i", handle.read(4))[0]
    handle.read(8)  # master index position
    genome = read_c_string()

    if version > 8:
        handle.read(16)  # normalization-vector index position and length

    attribute_count = struct.unpack("<i", handle.read(4))[0]
    for _ in range(attribute_count):
        read_c_string()  # key
        read_c_string()  # value

    chromosome_count = struct.unpack("<i", handle.read(4))[0]
    chromosomes = []
    for _ in range(chromosome_count):
        name = read_c_string()
        length_bytes = 8 if version > 8 else 4
        length_format = "<q" if version > 8 else "<i"
        length = struct.unpack(length_format, handle.read(length_bytes))[0]
        chromosomes.append((name, length))

    resolution_count = struct.unpack("<i", handle.read(4))[0]
    resolutions = [
        struct.unpack("<i", handle.read(4))[0]
        for _ in range(resolution_count)
    ]

print(f"file: {path}")
print(f"hic_version: {version}")
print(f"genome: {genome}")
print("BP_resolutions:", " ".join(map(str, resolutions)))
print("chromosomes:", " ".join(name for name, _ in chromosomes))
PY
```

Example:

```text
BP_resolutions: 2500000 500000 100000 50000 25000 10000 5000 2000
```

Choose one of the listed values exactly when calling `straw`. A resolution not stored in the file cannot be extracted directly.

## Extract contacts

General syntax:

```text
straw [observed|oe|expected] NORMALIZATION INPUT.hic CHR1 CHR2 UNIT BINSIZE
```

Common values:

- `NORMALIZATION`: `NONE`, `VC`, `VC_SQRT`, or `KR`
- `UNIT`: usually `BP`; use `FRAG` only when fragment-resolution data exist
- `BINSIZE`: one of the resolutions reported from the `.hic` header

Extract intrachromosomal KR-normalized contacts at 2 kb:

```bash
straw observed KR sample.hic 1 1 BP 2000 > sample.hic.KR.chr1
```

If chromosome names in the file include `chr`, use them exactly:

```bash
straw observed KR sample.hic chr1 chr1 BP 2000 > sample.hic.KR.chr1
```

Extract a genomic interval:

```bash
straw observed KR sample.hic 1:1000000:2000000 1:1000000:2000000 BP 10000
```

Output has three tab-delimited columns:

```text
bin1_start    bin2_start    contact_value
```

## Extract every canonical chromosome

Use the wrapper in the parent directory. When chromosome names inside the file are `1`, `2`, ..., `X`, and `Y` (no `chr` prefix):

```bash
cd /path/to/output/workdir
CHROM_PREFIX= bash ~/PreprocessDB/Hi-C/split_hic_KR.sh \
    sample.hic 2k 2000 4 \
    ~/PreprocessDB/Hi-C/straw/build/straw
```

When names inside the file are `chr1`, `chr2`, ..., omit `CHROM_PREFIX=`:

```bash
bash ~/PreprocessDB/Hi-C/split_hic_KR.sh \
    sample.hic 2k 2000 4 \
    ~/PreprocessDB/Hi-C/straw/build/straw
```

The wrapper writes intrachromosomal KR-normalized files for chromosomes 1-22, X, and Y.

## Troubleshooting

### `curl/curl.h: No such file or directory`

Install the libcurl development package or provide its include directory:

```bash
CURL_INCLUDE_DIR="$HOME/miniforge3/include" ./build.sh
```

### Chromosome not found

Check the `chromosomes:` line from the metadata command. Use chromosome names exactly as stored, including or excluding `chr`.

### Requested resolution is absent

Run the metadata command and select an integer printed after `BP_resolutions:`.

### KR normalization vector is absent

A `.hic` file can contain a contact matrix at a resolution without KR vectors for every chromosome at that resolution. Try `NONE` to confirm that the matrix exists, or add normalization vectors using the appropriate Juicer tools.
