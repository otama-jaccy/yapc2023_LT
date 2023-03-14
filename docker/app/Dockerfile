FROM perl:5.36

WORKDIR "/src"

RUN cpanm URI
RUN cpanm HTTP::Tiny
RUN cpanm JSON
RUN cpanm HTML::TagParser
RUN cpanm URI::Fetch
RUN cpanm HTML::TreeBuilder::XPath

CMD perl main.pl