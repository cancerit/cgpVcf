# Installation

    ./setup.sh /path/to/installation

`/path/to/installation` is where you want the `bin`, `lib` folders to be created. The following tools will be installed: `cgpVcf`, `vcftools`, and `samtools`.

⚠️ *This distribution will only works on `*NIX` type systems.*

# System Dependencies

<!-- we should not duplicate this info -->
* Ubuntu 16.04:

        apt-get update && \
        apt-get -y install \
            build-essential \
            curl \
            libgnutls-dev && \
        apt-get clean

    See [`Dockerfile`](Dockerfile).
