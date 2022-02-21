#!/usr/bin/env bash

set -eu

cd /

apply_reqs() {
    name="/requirements-${1}.txt"
    pip install --no-cache-dir -r "${name}"
    rm -f "${name}"
}

find_venvs(){
    for i in $(find -name 'requirements-venv-*.txt'); do
        # Get a venv name with removing of suffix and prefix
        name="${i%%.txt}"
        name="${name##./requirements-venv-}"
        echo "$name"
    done
}

apply_reqs "base"

export venv_home="/adcm/venv"
mkdir -p "${venv_home}"

for v in $(find_venvs); do
    virtualenv --system-site-packages "${venv_home}/${v}"
    source "${venv_home}/${v}/bin/activate"
    apply_reqs "venv-${v}"
done
