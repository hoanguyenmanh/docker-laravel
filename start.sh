#!/bin/bash

PHP_VERSION="7.3"

# enable xdebug if ENV variable SYS_XDEBUG_ENABLED == 1
_init_xdebug() {
  local _xdebug_enableb=0
  [[ -n "${SYS_XDEBUG_ENABLED:-}" ]]   && _xdebug_enableb=$SYS_XDEBUG_ENABLED

  echo ":: initializing xdebug config (_xdebug_enableb=${_xdebug_enableb})"

  if [[ $_xdebug_enableb == 1 ]] ; then
    echo -e "zend_extension=xdebug.so\nxdebug.remote_enable = on" > /etc/php/${PHP_VERSION}/mods-available/xdebug.ini
    ln -svf /etc/php/${PHP_VERSION}/mods-available/xdebug.ini /etc/php/${PHP_VERSION}/cli/conf.d/20-xdebug.ini
    ln -svf /etc/php/${PHP_VERSION}/mods-available/xdebug.ini /etc/php/${PHP_VERSION}/fpm/conf.d/20-xdebug.ini
  fi
}

# enable opcache if ENV variable APP_ENV|ENV = production or SYS_OPCACHE_ENABLED == 1
_init_opcache() {
  local _opcache_enabled=0
  [[ -n "${SYS_OPCACHE_ENABLED:-}" ]] && _opcache_enabled=$SYS_OPCACHE_ENABLED
  [[ "${APP_ENV:-}" == "production" ]] && _opcache_enabled=1
  [[ "${ENV:-}" == "production" ]] && _opcache_enabled=1

  echo ":: initializing opcache config (_opcache_enabled=${_opcache_enabled})"

  if [[ $_opcache_enabled == 1 ]] ; then
    phpenmod opcache
  fi
}


# if ENV variable SYS_IS_WORKER == 1
# -> only start worker process (dont start nginx, php-fpm)
_init_worker() {
  local _is_worker=${SYS_IS_WORKER:-0}
  echo ":: initializing worker config (_is_worker=${_is_worker})"

  if [[ $_is_worker == 1 ]] ; then
    sed -i 's#autostart=.*#autostart=false#g' /etc/supervisord.conf  # dont start nginx, php-fpm
    # include worker config
    [[ -d /etc/supervisor.d ]] || mkdir -v /etc/supervisor.d
    grep -q include /etc/supervisord.conf \
    || echo -e "[include]\nfiles = /etc/supervisor.d/*.conf\n" >> /etc/supervisord.conf
  fi
}

exec_supervisord() {
    echo 'Start supervisord'
    exec /usr/bin/supervisord -n -c /etc/supervisord.conf
}

# Run helper function if passed as parameters
# Otherwise start supervisord
if [[ -n "$@" ]]; then
  $@
else
  _init_xdebug  # for corveralls.io ...
  _init_opcache
  _init_worker
  exec_supervisord
fi
