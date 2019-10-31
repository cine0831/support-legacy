#!/bin/bash

_PYTHON_EXEC="/bin/python3.6"
_PYTHON_HOME="/usr/local/python3.6"
_VIRTUAL_ENV="/home/py3.6_venv_ansible"
_DOWNLOAD_DIR="/home/src/flask"
_STORE="http://ims.powdersnow.kr/uwsgi/"
_SOURCE=('Flask-1.0.2.tar.gz'
    'Flask-Session-0.3.1.tar.gz'
	'Flask-Cors-3.0.6.tar.gz'
    'itsdangerous-0.24.tar.gz'
    'MarkupSafe-1.0.tar.gz'
    'Werkzeug-0.14.1.tar.gz'
    'Jinja2-2.10.tar.gz'
    'PyJWT-1.6.0.tar.gz'
    'six-1.11.0.tar.gz'
    'py-healthcheck-1.7.0.tar.gz'
    'python-memcached-1.59.tar.gz'
    'certifi-2018.4.16.tar.gz'
    'urllib3-1.22.tar.gz'
    'idna-2.6.tar.gz'
    'chardet-3.0.4.tar.gz'
    'click-6.7.tar.gz'
    'requests-2.18.4.tar.gz'
    'argparse-1.4.0.tar.gz'
    'simplejson-3.15.0.tar.gz'
    'uwsgitop-0.10.tar.gz'
    'uwsgi-2.0.17.tar.gz')

# installing a python virtualenv
if [ ! -d $_VIRTUAL_ENV ]
then
    ${_PYTHON_HOME}${_PYTHON_EXEC} -m virtualenv --python=${_PYTHON_HOME}${_PYTHON_EXEC} ${_VIRTUAL_ENV}
fi

# makes a source download directory
if [ ! -d $_DOWNLOAD_DIR ]
then
    mkdir -pv $_DOWNLOAD_DIR
fi

# source downloading and extracting
for i in "${_SOURCE[@]}"
do
    wget -N -P ${_DOWNLOAD_DIR} ${_STORE}${i}
    tar -zxpf ${_DOWNLOAD_DIR}/${i} -C ${_DOWNLOAD_DIR}
done

# check version for CentOS 4 and installing inotify-tools (requirement under CentOS 5)
_VER=`cat /etc/redhat-release | grep 'release 4'`
if [ -n "$_VER" ]
then
    rpm -ivh http://ims.powdersnow.kr/uwsgi/inotify-tools-3.13-1.el4.rf.x86_64.rpm
    rpm -ivh http://ims.powdersnow.kr/uwsgi/inotify-tools-devel-3.13-1.el4.rf.x86_64.rpm
    ln -sf /usr/include/inotifytools/*.h /usr/include/sys/
    cp -pfv ${_DOWNLOAD_DIR}/uwsgi-2.0.17/core/utils.c{,.bak.sm_20180619}
    wget -O ${_DOWNLOAD_DIR}/uwsgi-2.0.17/core/utils.c ${_STORE}/uwsgi-2.0.17_cnt4_utils.c
fi

# getting source directory groups
_SOURCE_DIR_1=($(ls -l $_DOWNLOAD_DIR  | grep '^d' | awk '{print $9}' | egrep -v 'Jinja2|Flask|py-healthcheck|requests|uwsgi|python-memcached' | sort | while read line; do echo $line; done))
_SOURCE_DIR_2=($(ls -l $_DOWNLOAD_DIR  | grep '^d' | awk '{print $9}' | egrep 'Jinja2|py-healthcheck|requests|uwsgi|python-memcached' | sort -r | while read line; do echo $line; done))
_SOURCE_DIR_3=($(ls -l $_DOWNLOAD_DIR  | grep '^d' | awk '{print $9}' | grep 'Flask' | sort | while read line; do echo $line; done))

# installing dependency list
for x in "${_SOURCE_DIR_1[@]}"
do
    echo "--------------------------------------------------------------"
    echo "Installing $x python extension module"
    echo "--------------------------------------------------------------"
    cd "${_DOWNLOAD_DIR}/$x"
    ${_VIRTUAL_ENV}${_PYTHON_EXEC} setup.py build
    ${_VIRTUAL_ENV}${_PYTHON_EXEC} setup.py install
    echo -e "\n\n\n"
    sleep 2
done

# installing requirement list without Flask libraries
for y in "${_SOURCE_DIR_2[@]}"
do
    echo "--------------------------------------------------------------"
    echo "Installing $y python extension module"
    echo "--------------------------------------------------------------"
    cd "${_DOWNLOAD_DIR}/$y"
    ${_VIRTUAL_ENV}${_PYTHON_EXEC} setup.py build
    ${_VIRTUAL_ENV}${_PYTHON_EXEC} setup.py install
    echo -e "\n\n\n"
    sleep 2
done    

# installing requirement Flask libries
for j in "${_SOURCE_DIR_3[@]}"
do
    echo "--------------------------------------------------------------"
    echo "Installing $j python extension module"
    echo "--------------------------------------------------------------"
    cd "${_DOWNLOAD_DIR}/$j"
    ${_VIRTUAL_ENV}${_PYTHON_EXEC} setup.py build
    ${_VIRTUAL_ENV}${_PYTHON_EXEC} setup.py install
    echo -e "\n\n\n"
    sleep 2
done
