ARG BASE_IMAGE
FROM ${BASE_IMAGE}
MAINTAINER cht.andy@gmail.com
ARG ANSIBLE_VERSION
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN set -eux \
  && echo "######### apt install supervisor ##########" \
  && apt-get update \
  && apt-get install --assume-yes supervisor bash-completion \ 
  && echo "######### apt install vim ##########" \
  && apt-get install vim -y \
  && echo \
"set fileencodings=ucs-bom,utf-8,big5,gb18030,euc-jp,euc-kr,latin1 \n\
set fileencoding=utf-8 \n\
set encoding=utf-8" >> /etc/vim/vimrc \
  && echo "######### install ansible ##########" \
  && apt-get install --assume-yes software-properties-common  \
  && apt-add-repository ppa:ansible/ansible-${ANSIBLE_VERSION} \
  && apt-get update \
  && apt-get install --assume-yes ansible \
  && rm -rf /var/lib/apt/lists/* && apt-get clean

ENTRYPOINT ["/usr/bin/supervisord","-c","/etc/supervisor/conf.d/supervisord.conf"]
