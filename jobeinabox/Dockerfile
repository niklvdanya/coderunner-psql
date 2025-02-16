# Jobe-in-a-box: a Dockerized Jobe server with PostgreSQL

FROM docker.io/ubuntu:24.04

# https://github.com/opencontainers/image-spec/blob/master/annotations.md
LABEL \
    org.opencontainers.image.authors="richard.lobb@canterbury.ac.nz,j.hoedjes@hva.nl,d.h.bowes@herts.ac.uk" \
    org.opencontainers.image.title="JobeInABox" \
    org.opencontainers.image.description="JobeInABox" \
    org.opencontainers.image.documentation="https://github.com/trampgeek/jobeinabox" \
    org.opencontainers.image.source="https://github.com/trampgeek/jobeinabox"

ARG TZ=Pacific/Auckland
# Set up the (apache) environment variables
ENV APACHE_RUN_USER=www-data
ENV APACHE_RUN_GROUP=www-data
ENV APACHE_LOG_DIR=/var/log/apache2
ENV APACHE_LOCK_DIR=/var/lock/apache2
ENV APACHE_PID_FILE=/var/run/apache2.pid
ENV LANG=C.UTF-8

# PostgreSQL environment variables
ENV POSTGRES_DB=jobe_db
ENV POSTGRES_USER=jobe_user
ENV POSTGRES_PASSWORD=jobe_password

# Copy apache virtual host file for later use
COPY 000-jobe.conf /
# Copy test script
COPY container-test.sh /

# Install required packages and Jobe environment
RUN --mount=type=secret,id=api_keys \
    export API_KEYS=`cat /run/secrets/api_keys | tr '\n' ' '` && \
    ln -snf /usr/share/zoneinfo/"$TZ" /etc/localtime && \
    echo "$TZ" > /etc/timezone && \
    apt-get update && \
    apt-get --no-install-recommends install -yq \
        acl \
        apache2 \
        build-essential \
        fp-compiler \
        git \
        libapache2-mod-php \
        nano \
        nodejs \
        octave \
        default-jdk \
        php \
        php-cli \
        php-mbstring \
        php-intl \
        python3 \
        python3-pip \
        python3-setuptools \
        pylint \
        sqlite3 \
        postgresql \
        postgresql-client \
        sudo \
        tzdata \
        unzip && \
    pylint --reports=no --score=n --generate-rcfile > /etc/pylintrc && \
    ln -sf /proc/self/fd/1 /var/log/apache2/access.log && \
    ln -sf /proc/self/fd/1 /var/log/apache2/error.log && \
    sed -i "s/export LANG=C/export LANG=$LANG/" /etc/apache2/envvars && \
    sed -i '1 i ServerName localhost' /etc/apache2/apache2.conf && \
    sed -i 's/ServerTokens\ OS/ServerTokens \Prod/g' /etc/apache2/conf-enabled/security.conf && \
    sed -i 's/ServerSignature\ On/ServerSignature \Off/g' /etc/apache2/conf-enabled/security.conf && \
    rm /etc/apache2/sites-enabled/000-default.conf && \
    mv /000-jobe.conf /etc/apache2/sites-enabled/ && \
    mkdir -p /var/crash && \
    chmod 777 /var/crash && \
    echo '<!DOCTYPE html><html lang="en"><title>Jobe</title><h1>Jobe</h1></html>' > /var/www/html/index.html && \
    git clone https://github.com/trampgeek/jobe.git /var/www/html/jobe && \
    apache2ctl start && \
    cd /var/www/html/jobe && \
    if [ ! -z "${API_KEYS}" ]; then \
        sed -i 's/$require_api_keys = false/$require_api_keys = true/' /var/www/html/jobe/app/Config/Jobe.php && \
        sed -i "s/'2AAA7A.*/$API_KEYS/" /var/www/html/jobe/app/Config/Jobe.php \
    ; fi && \
    /usr/bin/python3 /var/www/html/jobe/install --max_uid=500 && \
    chown -R ${APACHE_RUN_USER}:${APACHE_RUN_GROUP} /var/www/html && \
    apt-get -y autoremove --purge && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/*

# Configure PostgreSQL
RUN service postgresql start && \
    su - postgres -c "psql -c \"CREATE USER ${POSTGRES_USER} WITH PASSWORD '${POSTGRES_PASSWORD}';\"" && \
    su - postgres -c "psql -c \"CREATE DATABASE ${POSTGRES_DB} OWNER ${POSTGRES_USER};\"" && \
    su - postgres -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE ${POSTGRES_DB} TO ${POSTGRES_USER};\"" && \
    su - postgres -c "psql -d ${POSTGRES_DB} -c \"CREATE TABLE IF NOT EXISTS employees (id SERIAL PRIMARY KEY, name VARCHAR(100), salary INTEGER);\"" && \
    su - postgres -c "psql -d ${POSTGRES_DB} -c \"INSERT INTO employees (name, salary) VALUES ('John Doe', 3500), ('Jane Smith', 5000), ('Alice Johnson', 2500), ('Bob Brown', 4000), ('Charlie White', 6000);\"" && \
    su - postgres -c "psql -d ${POSTGRES_DB} -c \"GRANT ALL PRIVILEGES ON TABLE employees TO ${POSTGRES_USER};\"" && \
    service postgresql stop

# Expose apache
EXPOSE 80

# Healthcheck every minute, minimaltest.py should complete within 2 seconds
HEALTHCHECK --interval=1m --timeout=2s \
    CMD /usr/bin/python3 /var/www/html/jobe/minimaltest.py || exit 1

# Start apache and PostgreSQL
CMD service postgresql start && /usr/sbin/apache2ctl -D FOREGROUND
