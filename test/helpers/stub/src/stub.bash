#!/bin/bash

BATS_TEST_DIRNAME="/vagrant/test/mock"

export PATH="$BATS_TEST_DIRNAME/stub:$PATH"

stub() {
    if [ ! -d $BATS_TEST_DIRNAME/stub ]; then
        mkdir -p $BATS_TEST_DIRNAME/stub
    fi
    echo $2 > $BATS_TEST_DIRNAME/stub/$1
    chmod +x $BATS_TEST_DIRNAME/stub/$1
}

unstubs() {
    rm -rf $BATS_TEST_DIRNAME/stub
}