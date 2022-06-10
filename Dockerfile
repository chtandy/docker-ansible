ARG BASE_IMAGE
FROM ${BASE_IMAGE}
MAINTAINER cht.andy@gmail.com

ARG DEBIAN_FRONTEND=noninteractive
ARG TZ=Asia/Taipei

## 變更預設的dash 為bash
RUN set -eux \
  && echo "######### dash > bash ##########" \
  && mv /bin/sh /bin/sh.old && ln -s /bin/bash /bin/sh

## 安裝locales 與預設語系
RUN set -eux \
  && echo "######### apt install locales and timezone ##########" \
  && apt-get update && apt-get install --assume-yes locales tzdata bash-completion \
  && rm -rf /var/lib/apt/lists/* && apt-get clean \
  && locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8 \
  && ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone

## 安裝supervisor
RUN set -eux \
  && echo "######### apt install supervisor ##########" \
  && apt-get update && apt-get install --assume-yes supervisor bash-completion \ 
  && rm -rf /var/lib/apt/lists/* && apt-get clean \ 
  && { \
     echo "[supervisord]"; \
     echo "nodaemon=true"; \
     echo "logfile=/dev/null"; \
     echo "logfile_maxbytes=0"; \
     echo "pidfile=/tmp/supervisord.pid"; \
     } > /etc/supervisor/conf.d/supervisord.conf

# 安裝 vim 並設置 /etc/vim/vimrc
RUN set -eux \
  && echo "######### apt install vim ##########" \
  && apt-get update && apt-get install vim -y \
  && rm -rf /var/lib/apt/lists/* && apt-get clean \
  && { \
     echo "set paste"; \
     echo "syntax on"; \ 
     echo "colorscheme torte"; \
     echo "set t_Co=256"; \
     echo "set nohlsearch"; \
     echo "set fileencodings=ucs-bom,utf-8,big5,gb18030,euc-jp,euc-kr,latin1"; \
     echo "set fileencoding=utf-8"; \
     echo "set encoding=utf-8"; \
     } >> /etc/vim/vimrc 

ARG ANSIBLE_VERSION
RUN set -eux \
  && echo "######### install ansible ##########" \
  && apt-get update && apt-get install --assume-yes software-properties-common  \
  && apt-add-repository --yes ppa:ansible/ansible-${ANSIBLE_VERSION} \
  && apt-get update \
  && apt-get install --assume-yes ansible \
  && rm -rf /var/lib/apt/lists/* && apt-get clean

WORKDIR /data
ENTRYPOINT ["/usr/bin/supervisord","-c","/etc/supervisor/conf.d/supervisord.conf"]
