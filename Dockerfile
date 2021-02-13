FROM ubuntu

ARG USERNAME="someone"
ARG Home="/var"
ARG DocumentRoot="${Home}/www"
ARG CGI_DIR="${DocumentRoot}/2021"

RUN useradd -m ${USERNAME}

RUN apt update && \
    apt install -y tzdata && \
    apt install -y apache2

ARG CONF="/etc/apache2/apache2.conf"

RUN echo '# CGI Directory' >> ${CONF};\
    echo "<Directory ${CGI_DIR}>" >> ${CONF};\
    echo "AllowOverride None" >> ${CONF};\
    echo "Options ExecCGI" >> ${CONF};\
    echo "Require all granted" >> ${CONF};\
    echo "</Directory>" >> ${CONF};\
    echo "<FilesMatch \.cgi$>" >> ${CONF};\
    echo "SetHandler cgi-script" >> ${CONF};\
    echo "</FilesMatch>" >> ${CONF}

# 000-default.confを書き換え
RUN a2dissite 000-default.conf
RUN sed -e "s%/var/www/html%${DocumentRoot}%" /etc/apache2/sites-available/000-default.conf > /tmp/_000-default.conf
RUN mv /tmp/_000-default.conf /etc/apache2/sites-available/000-default.conf
RUN a2ensite 000-default.conf

# cgiを有効化
RUN a2enmod cgi
# mod_rewriteを有効化
RUN a2enmod rewrite

RUN apt install -y git
RUN apt install -y python3 python3-pip
RUN pip3 install -U pip &&\
    pip install flask
RUN pip install pillow

COPY --chown=www-data:www-data . ${DocumentRoot} 
WORKDIR ${CGI_DIR}

ARG hoge=piyo
RUN git clone https://github.com/pelab2021/filter.git
RUN chmod 755 filter/index.cgi

EXPOSE 80
CMD ["apachectl", "-D", "FOREGROUND"]