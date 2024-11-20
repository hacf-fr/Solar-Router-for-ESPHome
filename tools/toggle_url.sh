#!/bin/bash
pushd $(dirname $0)  > /dev/null
if grep "# url: https:" ../*.yaml > /dev/null; then
    sed -i 's/# url: https:/  url: https:/' ../*.yaml
    echo "Using sources from GitHub"
else
    sed -i 's/  url: https:/# url: https:/' ../*.yaml
    echo "Using local sources"
fi
popd > /dev/null