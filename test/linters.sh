#!/bin/sh -e

map() {
    local result=0
    while read -r line; do
        # shellcheck disable=SC2068
        $@ "$line" || result=1
    done;
    return $result
}

map_ansible() {
    local result=0
    while read -r line; do
        # shellcheck disable=SC2068
        $@ "$line" || if [[ $? == 2 ]]; then
                         result=1
                        fi
    done;
    return $result
}

run_with_args(){
    local args=""
    while read -r line; do
        args="${args} ${line}"
    done;
    if [[ -n "${args}" ]]; then
        # shellcheck disable=SC2068,SC2046,SC2086
        $@ ${args}
        return $?
    else
        return 0
    fi
}

find_subdirs(){
    find "${1}" -mindepth 1 -maxdepth 1 -type d | grep -v '.git'
}

##################################################
#                       Ansible-lint
##################################################
ansible_lint_roles(){
    find_subdirs "${1}/roles" | map_ansible ansible-lint || return 1
    return 0
}

ansible_lint_playbooks(){
    find "${1}" -mindepth 1 -maxdepth 1 -name '*.y*ml' | grep -E -v 'config.y[a]?ml' | map_ansible ansible-lint || return 1
    return 0
}

recursive_ansible(){
    if [ -d "${1}/roles" ]; then
        local result=0
        ansible_lint_roles "${1}" || result=1
        ansible_lint_playbooks "${1}" || result=1
        return $result
    else
        local result=0
        find_subdirs "${1}"| map recursive_ansible || result=1
        ansible_lint_playbooks "${1}" || result=1
        return $result
    fi
}

do_ansible(){
    # We should run ansible-lint in a place were .ansible-lint
    # file present. See https://docs.ansible.com/ansible-lint/configuring/configuring.html#configuration-file
    ansible-lint --version
    export ANSIBLE_LIBRARY="${PWD}"
    # without ANSIBLE_LIBRARY custom modules invocation linting fails with "The error appears to be in '<unicode string>':"
    recursive_ansible "$1"
}

##################################################
#                          Pylint
##################################################

# Pylint is a sort of shit. We need to find all "modules" for that and all
# single *.py files
recursive_pylint(){

    if [ -f "${1}/__init__.py" ]; then
        echo "${1}"
    else
        find "${1}" -mindepth 1 -maxdepth 1 -name '*.py'
        find_subdirs "${1}"| map recursive_pylint
    fi
}

do_pylint(){
    # shellcheck disable=SC2230
    $(which pylint) --version
    # shellcheck disable=SC2046,SC2230
    recursive_pylint "${1}" | run_with_args $(which pylint) --output-format=parseable --ignore=conf.py
}

##################################################
#                          Flake8
##################################################
do_flake8(){
    flake8 --version
    if [ -e "./.flake8" ]; then
        flake8 "${1}"
    else
        flake8 --exclude=.git,__pycache__,docs/source/conf.py,old,build,dist "${1}"
    fi
}

##################################################
#                          flake8-pytest-style
##################################################
do_flake8_pytest_style(){
    pip install flake8-pytest-style
    flake8 --version
    if [ -e "./.flake8" ]; then
        flake8 "${1}"
    else
        flake8 --exclude=.git,__pycache__,docs/source/conf.py,old,build,dist "${1}"
    fi
}

##################################################
#                          Black
##################################################
do_black(){
    black --version
    black --check --diff --exclude '\.git|__pycache__|docs/source/conf\.py|old|build|dist' "${1}"
}

##################################################
#                          Pep8
##################################################
do_pep8(){
    # shellcheck disable=SC2230
    $(which pycodestyle) --version
    # shellcheck disable=SC2230
    $(which pycodestyle) --ignore=E501,E722,E402,W503,W504 "${1}"
}

##################################################
#                          Shellcheck
##################################################
do_shellcheck(){
    shellcheck --version
    # shellcheck disable=SC2046
    find "${1}" -name "*.sh" | grep -v '.git' | run_with_args shellcheck --format=gcc -s bash -f checkstyle -e SC2006,SC2044
}

##################################################
#                          YAMLlint
##################################################
do_yamllint(){
    yamllint --version
    yamllint --format=parsable -d "{extends: default, rules: {line-length: {max: 180}}}" "${1}"
}

folder="."
base="."

# Prepare
while getopts ":f:b::" opt
do
	  case $opt in
        f) folder="$OPTARG"
            ;;
        b) base="$OPTARG"
            ;;
        *) echo "Incorrect options"
           exit 1
           ;;
	  esac
done
shift $(( OPTIND - 1 ))
cd "$base"

source /adcm/venv/default/bin/activate

for req in requirements.txt requirements-test.txt tests/requirements.txt; do
    [ -f "${req}" ] && pip3 install --quiet -r "${req}"
done

for i in "$@"; do
    action="do_${i}"
    "${action}" "$folder"
done
