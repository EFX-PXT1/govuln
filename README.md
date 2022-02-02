# govuln

Desire to learn how to patch a vulnerability *indirectly* lifted into a Go Lang application
in a manner which satsfies Twistlock scanning.

This is important where indirect libraries are not well maintained.

## Approach

A simple example importing an old version of client-go to trigger x/crypto vulnerability.
Upgrading client-go is not a solution since in the general case of an application to be fixed
where there may be a cascade of api changes as a consequence.

## The Challenge

Currently a twistlock scan will flag

```
+----------------+----------+------+---------------------+------------------------------------+---------------------------------------------+-----------+------------+----------------------------------------------------+
|      CVE       | SEVERITY | CVSS |       PACKAGE       |              VERSION               |                   STATUS                    | PUBLISHED | DISCOVERED |                    DESCRIPTION                     |
+----------------+----------+------+---------------------+------------------------------------+---------------------------------------------+-----------+------------+----------------------------------------------------+
| CVE-2020-29652 | high     | 7.50 | golang.org/x/crypto | v0.0.0-20201002170205-7f63de1d35b0 | fixed in v0.0.0-20201216223049-8b5274cf687f | > 1 years | < 1 hour   | DOCUMENTATION: A null pointer dereference          |
|                |          |      |                     |                                    | > 1 years ago                               |           |            | vulnerability was found in golang. When using the  |
|                |          |      |                     |                                    |                                             |           |            | library\'s ssh server without specifying an option |
|                |          |      |                     |                                    |                                             |           |            | for GSS...                                         |
+----------------+----------+------+---------------------+------------------------------------+---------------------------------------------+-----------+------------+----------------------------------------------------+
```

Explanation of import:

```
go mod why -m golang.org/x/crypto
# golang.org/x/crypto
github.com/EFX-PXT1/govuln
k8s.io/client-go/tools/clientcmd
golang.org/x/crypto/ssh/terminal
```

## Failed Attempts

### replace

Adding a replace *DOES NOT* satisfy Twistlock

```
replace golang.org/x/crypto v0.0.0-20201002170205-7f63de1d35b0 => golang.org/x/crypto v0.0.0-20220131195533-30dcbda58838
```

The hypothesis being that Twistlock does not honour the replace

```
$ go version -m govuln
govuln: go1.17.6
        path    github.com/EFX-PXT1/govuln
        mod     github.com/EFX-PXT1/govuln      (devel)
        dep     github.com/davecgh/go-spew      v1.1.1  h1:vj9j/u1bqnvCEfJOwUhtlOARqs3+rkHYY13jYWTU97c=
        dep     github.com/go-logr/logr v0.4.0  h1:K7/B1jt6fIBQVd4Owv2MqGQClcgf0R266+7C/QjRcLc=
        dep     github.com/gogo/protobuf        v1.3.2  h1:Ov1cvc58UF3b5XjBnZv7+opcTcQFZebYjWzi34vdm4Q=
        dep     github.com/google/go-cmp        v0.5.2  h1:X2ev0eStA3AbceY54o37/0PQ/UWqKEiiO2dKL5OPaFM=
        dep     github.com/google/gofuzz        v1.1.0  h1:Hsa8mG0dQ46ij8Sl2AYJDUv1oA9/d6Vk+3LG99Oe02g=
        dep     github.com/imdario/mergo        v0.3.5  h1:JboBksRwiiAJWvIYJVo46AfV+IAIKZpfrSzVKj42R4Q=
        dep     github.com/json-iterator/go     v1.1.10 h1:Kz6Cvnvv2wGdaG/V8yMvfkmNiXq9Ya2KUv4rouJJr68=
        dep     github.com/modern-go/concurrent v0.0.0-20180306012644-bacd9c7ef1dd      h1:TRLaZ9cD/w8PVh93nsPXa1VrQ6jlwL5oN8l14QlcNfg=
        dep     github.com/modern-go/reflect2   v1.0.1  h1:9f412s+6RmYXLWZSEzVVgPGK7C2PphHj5RJrvfx9AWI=
        dep     github.com/spf13/pflag  v1.0.5  h1:iy+VFUOCP1a+8yFto/drg2CJ5u0yRoB7fZw3DKv/JXA=
        dep     golang.org/x/crypto     v0.0.0-20201002170205-7f63de1d35b0
        =>      golang.org/x/crypto     v0.0.0-20220131195533-30dcbda58838      h1:71vQrMauZZhcTVK6KdYM+rklehEEwb3E+ZhaE5jrPrE=
        dep     golang.org/x/net        v0.0.0-20211112202133-69e39bad7dc2      h1:CIJ76btIcR3eFI5EgSo6k1qKw9KJexJuRLI9G7Hp5wE=
        dep     golang.org/x/oauth2     v0.0.0-20200107190931-bf48bf16ab8d      h1:TzXSXBo42m9gQenoE3b9BGiEpg5IG2JkU5FkPIawgtw=
        dep     golang.org/x/sys        v0.0.0-20210615035016-665e8c7367d1      h1:SrN+KX8Art/Sf4HNj6Zcz06G7VEz+7w9tdXTPOZ7+l4=
        dep     golang.org/x/term       v0.0.0-20201126162022-7de9c90e9dd1      h1:v+OssWQX+hTHEmOBgwxdZxK4zHq3yOs8F9J7mk0PY8E=
        dep     golang.org/x/text       v0.3.6  h1:aRYxNxv6iGQlyVaZmk6ZgYEDa+Jg18DxebPSrd6bg1M=
        dep     golang.org/x/time       v0.0.0-20210220033141-f8bda1e9f3ba      h1:O8mE0/t419eoIwhTFpKVkHiTs/Igowgfkj25AcZrtiE=
        dep     gopkg.in/inf.v0 v0.9.1  h1:73M5CoZyi3ZLMOyDlQh031Cx6N9NDJ2Vvfl76EDAgDc=
        dep     gopkg.in/yaml.v2        v2.4.0  h1:D8xgwECY7CYvx+Y2n4sBz93Jn9JRvxdiyyo8CTfuKaY=
        dep     k8s.io/apimachinery     v0.21.1 h1:Q6XuHGlj2xc+hlMCvqyYfbv3H7SRGn2c8NycxJquDVs=
        dep     k8s.io/client-go        v0.20.15        h1:B6Wvl5yFiHkDZaZ0i5Vju6mGHw4Zo2DzDE8XF378Asc=
        dep     k8s.io/klog/v2  v2.8.0  h1:Q3gmuM9hKEjefWFFYF0Mat+YyFJvsUyYuwyNNJ5C9Ts=
        dep     k8s.io/utils    v0.0.0-20201110183641-67b214c5f920      h1:CbnUZsM497iRC5QMVkHwyl8s2tB3g7yaSHkYPkpgelw=
        dep     sigs.k8s.io/structured-merge-diff/v4    v4.1.2  h1:Hr/htKFmJEbtMgS/UD0N+gtgctAqz81t3nu+sPzynno=
        dep     sigs.k8s.io/yaml        v1.2.0  h1:kr/MCeFWJWTwyaHoR9c8EjH9OumOmoF9YGiZd7lFm/Q=
```

