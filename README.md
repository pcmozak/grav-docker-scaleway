# grav-docker-scaleway
Dockerfile for scaleway ARM based servers.

## Read the Dockerfile before building!
With a simple edit in the Dockerfile you can make it work for x64.
Just comment out `FROM armbuild/phusion-baseimage` and uncomment `#FROM phusion/baseimage:0.9.15` so the header of the Dockerfile looks like this:

```
# build for arm
#FROM armbuild/phusion-baseimage 
# build for x64
FROM phusion/baseimage:0.9.15
```

Credits go mostly to ahumaro: https://github.com/ahumaro/Grav-PHP-Nginx
