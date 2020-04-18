FROM centos:7

ENV HOME=/src
RUN mkdir -p ${HOME} && \
    useradd -u 1001 -r -g 0 -d ${HOME} -s /sbin/nologin \
            -c "COBOL Application User" default
WORKDIR ${HOME}

ENV GMP_VERSION=6.0.0
ENV GNU_COBOL=1.1

RUN yum install -y libtool ncurses ncurses-devel ncurses-libs make && \
        yum install -y libdb-devel libdbi libdbi-devel libtool-ltdl libtool-ltdl-devel db4 db4-devel wget

RUN chown -R 1001:0 ${HOME} && \
    find ${HOME} -type d -exec chmod g+ws {} \;

RUN mkdir -p /src/cobol

RUN cd /src && wget https://ftp.gnu.org/gnu/gmp/gmp-${GMP_VERSION}a.tar.xz && \
    tar xf gmp-${GMP_VERSION}a.tar.xz && \
    cd gmp-${GMP_VERSION} && ./configure ; make ; make check ; make install

RUN cd /src && wget http://sourceforge.net/projects/open-cobol/files/gnu-cobol/${GNU_COBOL}/gnu-cobol-${GNU_COBOL}.tar.gz && \
    tar xvzf gnu-cobol-${GNU_COBOL}.tar.gz && \
    cd gnu-cobol-${GNU_COBOL} && ./configure ; make ; make check ; make install

COPY ./plus5numbers.cbl /src/cobol/
COPY ./watcher-cobol.sh /src/

RUN cd /src/cobol && cobc -free -x -o plus5numbers-exe plus5numbers.cbl

ENV LD_LIBRARY_PATH /usr/local/lib:$LD_LIBRARY_PATH


USER 1001
CMD ["/src/watcher-cobol.sh"]
