# This Dockerfile imports from cancerit:pcap-core so that projects that depend
# on cgpVcf will have both cgpBigWig and PCAP-core already available. However,
# its important to note that PCAP-core is not a cgpVCF dependency.
# cgpVcf image without PCAP-core is 585MB, with PCAP-core is 871MB.

# The cancerit:pcap-core container includes the environment variable OPT,
# this is reused here to install cgpVcf.
# As such there is no need to update PATH and PERL5LIB.

# Locale is also set to:
# ENV LC_ALL en_US.UTF-8
# ENV LANG en_US.UTF-8

# cgpVcf system dependencies are:
# curl              | Missing in pcap-core
# build-essential
# libgnutls-dev
FROM cancerit/pcap-core:4.0.5

# Set maintainer labels.
LABEL maintainer Keiran M. Raine <kr2@sanger.ac.uk>

# Add repo.
COPY . /code

# The only system dependency missing from PCAP-core image is curl.
RUN \
    apt-get -yqq update --fix-missing && \
    apt-get -yqq install curl && \
    apt-get clean

# Install package.
RUN \
    cd /code && \
    ./setup.sh $OPT && \
    cd ~ && \
    rm -rf /code

# Set volume to data as per:
# https://github.com/BD2KGenomics/cgl-docker-lib
VOLUME /data
WORKDIR /data
