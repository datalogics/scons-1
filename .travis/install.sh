#!/usr/bin/env bash
set -x

if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
    echo "OSX"
    brew install python --framework --universal
else
    # dependencies for clang tests
    sudo apt-get -y install clang

    # setup clang for clang tests using local clang installation
    if [ ! -f /usr/local/clang-5.0.0/bin/clang ]; then
        echo "No Clang 5.0.0 trying 7.0.0"
        sudo ln -s /usr/local/clang-7.0.0/bin/clang /usr/bin/clang
        sudo ln -s /usr/local/clang-7.0.0/bin/clang++ /usr/bin/clang++
    else
        echo "Clang 5.0.0"
        sudo ln -s /usr/local/clang-5.0.0/bin/clang /usr/bin/clang
        sudo ln -s /usr/local/clang-5.0.0/bin/clang++ /usr/bin/clang++
    fi

    # dependencies for gdc tests
    sudo apt-get -y install gdc

    # dependencies for fortran tests
    sudo apt-get -y install gfortran

    # dependencies for docbook tests
    sudo apt-get -y install docbook-xml docbook-xsl xsltproc libxml2-dev libxslt-dev fop docbook-xsl-doc-pdf
    # docbook-slides should be added but triggers GH #3393 so left out for now.

    # dependencies for latex tests (try to skip the huge doc pkgs)
    sudo apt-get -y --no-install-recommends install texlive texlive-latex3 biber texmaker ghostscript
    # Should add the following, holding off since it slows down provisioning:
    # texlive-bibtex-extra texlive-latex-extra texlive-font-utils
    # texlive-latex3 no longer exists, failover to texlive-latex-recommended

    # need some things for building dependencies for other tests
    sudo apt-get -y install python-pip python-dev build-essential libpcre3-dev autoconf automake libtool bison subversion git

    # dependencies for D tests
    sudo wget http://master.dl.sourceforge.net/project/d-apt/files/d-apt.list -O /etc/apt/sources.list.d/d-apt.list
    wget -qO - https://dlang.org/d-keyring.gpg | sudo apt-key add -
    sudo apt-get update && sudo apt-get -y --allow-unauthenticated install dmd-bin

    # dependencies for ldc tests
    wget https://github.com/ldc-developers/ldc/releases/download/v1.15.0/ldc2-1.15.0-linux-x86_64.tar.xz
    tar xf ldc2-1.15.0-linux-x86_64.tar.xz
    sudo cp -rf ldc2-1.15.0-linux-x86_64/* /

    ls -l /usr/lib/*python*{so,a}*

    # For now skip swig if py27
    if [[ "$PYVER" == 27 ]]; then
        # dependencies for swig tests
        wget https://github.com/swig/swig/archive/rel-3.0.12.tar.gz
        tar xzf rel-3.0.12.tar.gz
        cd swig-rel-3.0.12 && ./autogen.sh && ./configure --prefix=/usr && make && sudo make install && cd ..
    fi
fi
