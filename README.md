# Clace Applications

Clace is a web server which makes self-hosting Hypermedia driven web applications easy. See https://clace.io/ for details.

https://github.com/claceio/clace is the main Clace repository. This `apps` repository contains Hypermedia driven web apps which can be installed on a Clace server.

To [install Clace](https://clace.io/docs/installation/), run:

```
curl -L https://clace.io/install.sh | sh
# Note down the generated password
source $HOME/clhome/bin/clace.env
clace server start &
```

After Clace service is started, an app can be installed by running:

```
clace app create --approve https://github.com/claceio/apps/utils/bookmarks/ /bookmarks
clace app create --approve https://github.com/claceio/apps/system/disk_usage /system/disk_usage
clace app create --approve https://github.com/claceio/apps/system/memory_usage /system/memory_usage
```

The apps will be available at the requested url, like https://localhost:25223/bookmarks. Use `admin` as the username and the password displayed when the Clace server was installed. To disable password auth for the ap, add the `--auth none` option to the `app create` command. To change existing app auth, run `clace app update-settings auth none /bookmarks`.

To reload existing apps with any code changes from GitHub, run

```
clace app reload --promote /bookmarks # reload one app from latest code in GitHub
clace app reload --promote all # reload all apps from latest code in GitHub
```

See [lifecycle](https://clace.io/docs/applications/lifecycle/) for details on app lifecycle. If application requires new [permissions](https://clace.io/docs/applications/appsecurity/), approve by running `clace app approve /utils/bookmarks` or add `--approve` to the reload command.

# Application Listing

|     App Name     |                  Install Url                  |                        Description                         |             System Requirements             | Demo                                  |
| :--------------: | :-------------------------------------------: | :--------------------------------------------------------: | :-----------------------------------------: | :------------------------------------ |
| Bookmark Manager |   `github.com/claceio/apps/utils/bookmarks`   | A bookmark manager app, using sqlite for data persistenace |                All platforms                | https://utils.demo.clace.io/bookmarks |
|    Disk Usage    |  `github.com/claceio/apps/system/disk_usage`  |         Disk space usage monitor, with drill down          |                All platforms                | https://du.demo.clace.io/             |
|   Memory Usage   | `github.com/claceio/apps/system/memory_usage` |      Memory usage monitor, grouped by parent process       | Linux, OSX, Windows with WSL. Uses `ps` cli | https://memory.demo.clace.io/         |
