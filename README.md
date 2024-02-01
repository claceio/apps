# Clace Applications

Clace is a web server which makes self-hosting web applications easy. See https://clace.io/ for details.

https://github.com/claceio/clace is the main Clace repository. This apps repository contains Hypermedia driven web apps which can be installed on a Clace server.

To install Clace, run:

```
curl -L https://clace.io/install.sh | sh
# Note down the generated password
source $HOME/clhome/bin/clace.env
clace server start &
```

After that, any app can be installed by running:

```
 clace app create --approve /utils/bookmarks github.com/claceio/apps/utils/bookmarks/
```

The app should be available at https://localhost:25223/utils/bookmarks. Use `admin` as the username and the password displayed when the Clace server was installed.
