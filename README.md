# docker-exec-as-user

### TL;DR

## Build
#### Example of `Dockerfile` for `alpine` base image:
```dockerfile
FROM alpine # or any image based on "alpine"
COPY --from=dacrystal/exec-as-user /bin/su-exec.alpain /bin/su-exec
COPY --from=dacrystal/exec-as-user /docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
```

#### Example of `Dockerfile` for other `Linux` base image:
```dockerfile
FROM ubuntu #centos or debian etc..
COPY --from=dacrystal/exec-as-user /bin/su-exec.linux64 /bin/su-exec
COPY --from=dacrystal/exec-as-user /docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
```


## Usage 

```sh
docker run [OPTIONS...] [-e USER=user] -e AS_USER=<UID>[:<GID>] <EXEC_AS_USER_BASE_IMAGE> [CMD...]
```

To run as current user:
```sh
docker run [OPTIONS...] -e USER=$(id -un) -e AS_USER=$(id -u):$(id -g) <EXEC_AS_USER_BASE_IMAGE> [CMD...]
```

Note: `USER` variable is default to `"user"`

----

### How?
Simply the `ENTRYPOINT` script will create a real user corresponding to `AS_USER` and switch to it using `su-exec`. Yes, that's it!

### Why not using `--user`?

`--user` option does not create a real user. That is to say:
- `user` does not exist in `/ets/passwd`. Some software fail if user is does not exist.
- `user` user is home-less. Again some software fail if user does not have a `${HOME}`!
- `user` is name-less. Same bla bla bla...


### Why one need to switch user in the first place?!
Due to the same reasons that `one` is reading this crap! 

- My main user-case is for container(a build or CLI wrapper) that generate files on a mounted volume (`-v $PWD:/my-mount`). This will ensure the files have the right permissions. 