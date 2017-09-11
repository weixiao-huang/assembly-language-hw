FROM huangwx/gcc5-i686-elf

COPY ./bin /usr/src/app/bin
COPY ./raw /usr/src/app/raw
COPY ./bomb /usr/src/app/bomb

WORKDIR /usr/src/app