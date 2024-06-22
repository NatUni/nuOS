#!/usr/bin/false
NUOS_VER=0.0.12.99a0
# Copyright (c) 2008-2024 Chad Jacob Milios and Crop Circle Systems.
# All rights reserved.
# This Source Code Form is subject to the terms of the Simplified BSD License.
# Official updates and community support available at https://nuos.org .
. ${NUOS_CODE:=/usr/nuos}/lib/nu_system.sh


## It is assumed the jail system service is available and configured:
# enable_svc jail

## This script creates a jailed instance of the Forgejo application.
## Example:
#
# : ${J=maga-fj}
# : ${FJ_SITE='MAGA.ventures'}
# : ${FJ_TAGLINE='Making America Great Again, bit by bit'}

: ${J=diy-fj}
: ${FJ_SITE='Repo.DIY'}
: ${FJ_TAGLINE='All your codebase are belong to...YOU!'}

: ${FJ_DB_USER=$J}
: ${FJ_DB_NAME=$J}


app=forgejo       # There is no need to change this.
fjv=7             # The specific version of Forgejo, major part.
dbj=pgsql         # This jail should be up and running already, somehow.
pgv=15            # The specific version of PostgreSQL, major part.
pmj=postmaster    # This jail should be configured to run Postfix MTA.

if [ -d /usr/local/share/$app -a ! -d ${fj_jd:=/var/jail/${J:=$app}} ]; then

    [ x${fjv} = x7 ] || error 78 'Forgejo 7.x is assumed'

    fj_enc_key=`cat /root/.$J.db.key || { umask 277; nu_randpw -b 32 | tee /root/.$J.db.key; }`

    fj_conf=$fj_jd/usr/local/etc/$app/conf/app.ini

    : ${FJ_SITE:='nuOS.work'}
    : ${FJ_TAGLINE:='Prosper, free from industry overlords'}

    : ${FJ_DB_USER:=$J}
    : ${FJ_DB_NAME:=$J}
    : ${FJ_DB_PASS:=`nu_randpw -b 32`}

    lower_case -s FJ_SITE
    fj_title="$FJ_SITE: $FJ_TAGLINE"
    fj_mail_from="\"$FJ_SITE Webserver\" <www-noreply@$FJ_SITE_lc>"

    nu_jail -t vnet -m -x -u fj$fjv -j $J -q

    chown root:git $fj_conf
    chmod 640 $fj_conf

    {
        sed -e '/^$/,${d;q;}' $fj_conf.sample
        printf %s "WORK_PATH = /usr/local/share/$app"
        sed -ne "/^\$/,\${/^APP_NAME /s|= .*|= $fj_title|;/^JWT_SECRET /s|= .*|= `nu_randpw -b 32`|;/^INTERNAL_TOKEN /s|= .*|= `nu_randpw -b 32`|;/^SECRET_KEY /s|= .*|= $fj_enc_key|;/^HTTP_ADDR /s/= .*/= 0.0.0.0/;/^ROOT_URL /s|= .*|= https://$FJ_SITE_lc/|;/^SSH_DOMAIN /s/= .*/= $FJ_SITE_lc/;p;}" $fj_conf.sample
    } >| $fj_conf

    install -m 0644 $fj_jd/usr/local/share/postfix/mailer.conf.postfix $fj_jd/usr/local/etc/mail/mailer.conf
    echo /var/jail/$pmj/var/spool/postfix/maildrop $fj_jd/var/spool/postfix/maildrop nullfs rw >| /etc/fstab.$J
    echo /var/jail/$pmj/var/spool/postfix/public $fj_jd/var/spool/postfix/public nullfs rw >> /etc/fstab.$J

    if srsly ${GENESIS_DROP_FORGEJO_DB-}; then
        jexec $dbj su -l postgres -c 'psql -v ON_ERROR_STOP=1' <<EOF
DO
$$BEGIN
IF EXISTS (SELECT FROM pg_roles WHERE rolname = '$FJ_DB_USER') THEN
    EXECUTE 'REVOKE ALL ON SCHEMA public FROM $FJ_DB_USER';
END IF;
END$$;
DROP DATABASE IF EXISTS $FJ_DB_NAME;
DROP ROLE IF EXISTS $FJ_DB_USER;
EOF
    fi

    jexec $dbj su -l postgres -c 'psql -v ON_ERROR_STOP=1' <<EOF
CREATE ROLE $FJ_DB_USER WITH LOGIN ${GENESIS_FORGEJO_NETWORK_DB:+ENCRYPTED }PASSWORD '$FJ_DB_PASS' NOINHERIT VALID UNTIL 'infinity';
CREATE DATABASE $FJ_DB_NAME WITH OWNER $FJ_DB_USER TEMPLATE template0 ENCODING UTF8 LC_COLLATE 'en_US.UTF-8' LC_CTYPE 'en_US.UTF-8';
\c $FJ_DB_NAME;
GRANT ALL ON SCHEMA public TO $FJ_DB_USER;
EOF

    if srsly ${GENESIS_FORGEJO_NETWORK_DB-}; then
        db_type=host
        db_client_host=`getent hosts $J.jail | head -n 1 | cut -w -f 1`/32
        db_meth=scram-sha-256
    else
        local_fj_db=y
        db_type=local
        db_client_host=
        db_meth=password
    fi

    sed -e "/^#/!{/\<$FJ_DB_NAME\>/d;}" /var/jail/$dbj/var/db/postgres/data$pgv/pg_hba.conf | sed -e '${/^$/d;}' > /var/jail/$dbj/var/db/postgres/data$pgv/pg_hba.conf.new
    cat >> /var/jail/$dbj/var/db/postgres/data$pgv/pg_hba.conf.new <<EOF

$db_type${GENESIS_FORGEJO_NETWORK_DB:+ }   $FJ_DB_NAME         $FJ_DB_USER         $db_client_host${local_fj_db:+              }          $db_meth
EOF
    mv /var/jail/$dbj/var/db/postgres/data$pgv/pg_hba.conf.new /var/jail/$dbj/var/db/postgres/data$pgv/pg_hba.conf

    jexec $dbj su -l postgres -c 'psql -v ON_ERROR_STOP=1' <<'EOF'
SELECT pg_reload_conf();
EOF

    mkdir $fj_jd/var/run/pgsql
    echo /var/jail/$dbj/var/run/pgsql $fj_jd/var/run/pgsql nullfs ro >> /etc/fstab.$J

    cat >> $fj_conf <<EOF

[database]
DB_TYPE = postgres
HOST = ${local_fj_db:+/var/run/pgsql}${GENESIS_FORGEJO_NETWORK_DB:+$dbj.jail}
NAME = $FJ_DB_NAME
USER = $FJ_DB_USER
PASSWD = $FJ_DB_PASS
SCHEMA =
SSL_MODE=${local_fj_db:+disable}${GENESIS_FORGEJO_NETWORK_DB:+verify-full}

[service]
ENABLE_CAPTCHA = true
REQUIRE_SIGNIN_VIEW = true
REGISTER_EMAIL_CONFIRM = true
ENABLE_NOTIFY_MAIL = true
ALLOW_ONLY_INTERNAL_REGISTRATION = true
DEFAULT_KEEP_EMAIL_PRIVATE = true

[mailer]
ENABLED = true
PROTOCOL = sendmail
FROM = $fj_mail_from
EOF


    enable_svc -C $fj_jd $app

    sysrc -f /etc/rc.conf.d/jail jail_list+=$J
    service jail start $J

fi

