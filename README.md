# OpenGrok OS specific files


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
