FROM perl:5.36

WORKDIR "/src"

RUN cpanm Carmel --notest

CMD carmel install && carmel exec -- perl main.pl