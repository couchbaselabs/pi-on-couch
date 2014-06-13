# Pi on Couch
Demo Couchbase Lite and the syncing capabilities, running on MacOS and Raspbian
(Raspberry Pi). The app is developed using jRuby and Couchbase Lite Java.

## Setup
Install [jRuby](http://jruby.org/) and run app.rb

```bash
$ jruby app.rb
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

If you want to point the sync to your own server, setup sync-gateway and cahnge
the SYNC\_URL in the app.rb

## App

Send a message, sync with remote and receive on all connected devices.

<img src="https://farm6.staticflickr.com/5031/14411058895_c9be89a60d_s.jpg"
width="400" height="400" alt="pi-on-couch">

