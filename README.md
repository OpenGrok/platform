# OpenGrok OS specific files

## Creating Solaris packages

Solaris packages can be created via:

- SVR4:

```
/usr/bin/pkgmk -o -d build -r . -v ${version} -f solaris/pkgdef/prototype
/usr/bin/pkgtrans -s build OSOLopengrok-${version}.pkg OSOLopengrok
```

- IPS:

```
solaris/ips/create.sh -v ${version}
```

## Using SMF service (Solaris) to maintain OpenGrok indexes

If you installed OpenGrok from the OSOLopengrok package, it will work out of
the box. Should you need to configure it (e.g. because of non-default `SRC_ROOT`
or `DATA_ROOT` paths) it is done via the `opengrok` property group of the
service like this:

```bash
svccfg -s opengrok setprop opengrok/srcdir="/absolute/path/to/your/sourcetree"
svccfg -s opengrok setprop opengrok/maxmemory="2048"
```

Then make the service start the indexing, at this point it would be nice if
the web application is already running.

Now enable the service:

```bash
svcadm enable -rs opengrok
```

Note that this will enable tomcat service as dependency.

When the service starts indexing for first time, it's already enabled and
depending on tomcat, so at this point the web application should be
already running.

Note that indexing is not done when the opengrok service is disabled.

To rebuild the index later (e.g. after source code changed) just run:

```bash
svcadm refresh opengrok
```

The service makes it possible to supply part of the configuration via the
`opengrok/readonly_config` service property which is set to
`/etc/opengrok/readonly_configuration.xml` by default.

Note: before removing the package please disable the service.
If you don't do it, it will not be removed automatically.
In such case please remove it manually.


