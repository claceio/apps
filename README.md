# Clace Applications

Clace is a web server which makes self-hosting Hypermedia driven web applications easy. See https://clace.io/ for details.

https://github.com/claceio/clace is the main Clace repository. This `apps` repository contains Hypermedia driven web apps which can be installed on a Clace server.

To install Clace, run:

```
curl -L https://clace.io/install.sh | sh
# Note down the generated password
source $HOME/clhome/bin/clace.env
clace server start &
```

After Clace service is started, an app can be installed by running:

```
clace app create --approve /utils/bookmarks https://github.com/claceio/apps/utils/bookmarks/
clace app create --approve /system/disk_usage https://github.com/claceio/apps/system/disk_usage
clace app create --approve /system/memory_usage https://github.com/claceio/apps/system/memory_usage
```

The app should be available at https://localhost:25223/utils/bookmarks. Use `admin` as the username and the password displayed when the Clace server was installed.

To update existing apps, run

```
clace app reload --promote /utils/bookmarks # reload one app from latest code in GitHub
clace app reload --promote all # reload all apps from latest code in GitHub
```

See [lifecycle](https://clace.io/docs/applications/lifecycle/) for details on app lifecycle. If application requires new [permissions](https://clace.io/docs/applications/appsecurity/), approve by running `clace app approve /utils/bookmarks` or add `--approve` to the reload command.

# Application Listing

|     App Name     |                  Install Url                  |                        Description                         |             System Requirements             | Demo                                     |
| :--------------: | :-------------------------------------------: | :--------------------------------------------------------: | :-----------------------------------------: | :--------------------------------------- |
| Bookmark Manager |   `github.com/claceio/apps/utils/bookmarks`   | A bookmark manager app, using sqlite for data persistenace |                All platforms                |                                          |
|    Disk Usage    |  `github.com/claceio/apps/system/disk_usage`  |         Disk space usage monitor, with drill down          | Linux, OSX, Windows with WSL. Uses `df` cli | https://utils.demo.clace.io/disk_usage   |
|   Memory Usage   | `github.com/claceio/apps/system/memory_usage` |      Memory usage monitor, grouped by parent process       | Linux, OSX, Windows with WSL. Uses `ps` cli | https://utils.demo.clace.io/memory_usage |
