⚠️ This repo is obsolete.  It was developed using a version of Couchbase Lite that reached end of life years ago.

# Pi on Couch
Demo Couchbase Lite and the syncing capabilities, running on MacOS and Raspbian
(Raspberry Pi). The app is developed using jRuby and Couchbase Lite Java.

## Setup
Install [jRuby](http://jruby.org/) and the pi\_on\_couch script with the URL as
sync gateway as the argument.

```bash
$ jruby bin/pi_on_couch http://127.0.0.1:4984/db
```

Couchbase Lite Native has been precompield for MacOS and Raspbian, so it should
work out of the box, otherwise you need to compile [Couchbase Lite Java
Native](https://github.com/couchbase/couchbase-lite-java-native) and load it
according to your platform.

```ruby
# load native jars for platform
if RbConfig::CONFIG["target_cpu"] =~ /x86/ && RbConfig::CONFIG["host_os"] =~ /darwin/
  require "vendor/macosx/couchbase-lite-java-native.jar"
elsif RbConfig::CONFIG["target_cpu"] =~ /arm/
  require "vendor/linux_arm/couchbase-lite-java-native.jar"
end
```

## App

Send a message, sync with remote and receive on all connected devices.

<img src="https://farm6.staticflickr.com/5031/14411058895_c9be89a60d.jpg"
width="500" height="391" alt="pi-on-couch">
