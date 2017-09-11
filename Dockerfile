FROM huangwx/gcc5-i686-elf

COPY ./bin /usr/src/app/bin
COPY ./raw /usr/src/app/raw

WORKDIR /usr/src/app
