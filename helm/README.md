#  K8s Dev role
## Helm package manager

## Play a little

1. Let's inspect a wordpress chart from bitnami repository
```
# Install repo
$ helm repo add bitnami https://charts.bitnami.com/bitnami

# Search for wordpress chart options
$ helm search repo bitnami | grep -i wordpress
bitnami/wordpress                               14.0.4          5.9.3           WordPress is the world's most popular blogging ...
bitnami/wordpress-intel                         1.0.4           5.9.3           WordPress for Intel is the most popular bloggin...

# Reveal available version from a chart option
$ helm search repo bitnami/wordpress --versions
NAME                    CHART VERSION   APP VERSION     DESCRIPTION
bitnami/wordpress       14.0.4          5.9.3           WordPress is the world's most popular blogging ...
bitnami/wordpress       14.0.3          5.9.3           WordPress is the world's most popular blogging ...
bitnami/wordpress       14.0.1          5.9.3           WordPress is the world's most popular blogging ...
...
# Download a specific version of chart
$ helm pull --untar bitnami/wordpress --version 14.0.3
$ ls wordpress/
Chart.lock  Chart.yaml  README.md  charts  ci  templates  values.schema.json  values.yaml

# Reveal dependency list
$ helm dependency list wordpress/
NAME            VERSION REPOSITORY                              STATUS
memcached       6.x.x   https://charts.bitnami.com/bitnami      unpacked
mariadb         11.x.x  https://charts.bitnami.com/bitnami      unpacked
common          1.x.x   https://charts.bitnami.com/bitnami      unpacked
$ cat wordpress/Chart.lock
dependencies:
- name: memcached
  repository: https://charts.bitnami.com/bitnami
  version: 6.0.16
- name: mariadb
  repository: https://charts.bitnami.com/bitnami
  version: 11.0.0
- name: common
  repository: https://charts.bitnami.com/bitnami
  version: 1.13.1
digest: sha256:2f4a756e9aa60183fd8ee7b2747f93b8029000f59752ad9db88ca091a6181cf8
generated: "2022-04-26T02:00:49.129355181Z"

# Download charts this depends on (optional)
$ helm dependency build wordpress/
$ helm dependency list wordpress/
NAME            VERSION REPOSITORY                              STATUS
memcached       6.x.x   https://charts.bitnami.com/bitnami      ok
mariadb         11.x.x  https://charts.bitnami.com/bitnami      ok
common          1.x.x   https://charts.bitnami.com/bitnami      ok
$ ls wordpress/charts/
common  common-1.13.1.tgz  mariadb  mariadb-11.0.0.tgz  memcached  memcached-6.0.16.tgz

# Wath values we can tune with defaults
# https://github.com/bitnami/charts/tree/master/bitnami/wordpress/#installing-the-chart
$ helm show values wordpress/

# Watch values of sub-charts
$ helm show values wordpress/charts/mariadb-11.0.2.tgz

```

2. Let's install it:

```
$ helm install --atomic my-wp --version 14.0.6 \
  --set wordpressUsername=admin \
  --set wordpressPassword=password \
  --set mariadb.auth.rootPassword=secretpassword \
  --set service.type=LoadBalancer \
    bitnami/wordpress

$ helm list
NAME                    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
my-wp                   playground      1               2022-05-11 17:03:37.8476191 +0200 CEST  deployed        wordpress-14.0.6        5.9.3

$ helm get values my-wp
USER-SUPPLIED VALUES:
mariadb:
  auth:
    rootPassword: secretpassword
service:
  type: LoadBalancer
wordpressPassword: password
wordpressUsername: admin
```

3. Let's explore upgrades and rollback
```
$ helm history my-wp
REVISION        UPDATED                         STATUS          CHART                   APP VERSION     DESCRIPTION
1               Wed May 11 17:03:37 2022        deployed        wordpress-14.0.6        5.9.3           Install complete

$ helm search repo bitnami/wordpress --versions | head -3
NAME                    CHART VERSION   APP VERSION     DESCRIPTION
bitnami/wordpress       14.0.7          5.9.3           WordPress is the world's most popular blogging ...
bitnami/wordpress       14.0.6          5.9.3           WordPress is the world's most popular blogging ...

$ helm upgrade --atomic my-wp bitnami/wordpress --version 14.0.7 -f values.yaml

$ helm history my-wp
REVISION        UPDATED                         STATUS          CHART                   APP VERSION     DESCRIPTION
1               Wed May 11 17:23:06 2022        superseded      wordpress-14.0.6        5.9.3           Install complete
2               Wed May 11 17:27:32 2022        deployed        wordpress-14.0.7        5.9.3           Upgrade complete

# Check nothing (basic) impedes rollback
$ helm rollback my-wp 1 --dry-run
Rollback was a success! Happy Helming!
# Run the rollback
$ helm rollback my-wp 1
Rollback was a success! Happy Helming!

# Verify current version
$ helm history my-wp
REVISION        UPDATED                         STATUS          CHART                   APP VERSION     DESCRIPTION
1               Wed May 11 17:23:06 2022        superseded      wordpress-14.0.6        5.9.3           Install complete
2               Wed May 11 17:27:32 2022        superseded      wordpress-14.0.7        5.9.3           Upgrade complete
3               Wed May 11 17:33:02 2022        deployed        wordpress-14.0.6        5.9.3           Rollback to 1

```

4. Clean-up
```
$ helm list
NAME                    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
my-wp                   playground      2               2022-05-11 17:15:44.1135402 +0200 CEST  deployed        wordpress-14.0.7        5.9.3

$ helm uninstall my-wp
release "my-wp" uninstalled
```

