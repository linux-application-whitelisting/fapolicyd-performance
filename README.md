# fapolicyd-performance

# how to use

```
$ sudo dnf install fapolicyd cmake gcc
```

* Put
```
allow all all
```
* at the beginning of the /etc/fapolicyd/fapolicyd.rules

```
$ cmake .
$ cd src
$ sudo ./benchmark
```
