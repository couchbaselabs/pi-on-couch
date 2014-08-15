require "tmpdir"
require "rake/clean"

CLOBBER << "data" # cleanup the couchbase lite data

desc "run sync_gateway with the default config"
task :sync_gateway do
  system "sync_gateway config/sync_gateway_config.json"
end

desc "ship the current project of to the pi"
task :ship_to_pi, [:host, :username] do |t, args|
  Dir.mktmpdir do |dir|
    tar_file = "#{dir}/pi_on_couch.tar.gz"
    system "tar -zcvf #{tar_file} ./"
    system "scp #{tar_file} #{args[:username]}@#{args[:host]}:~/"
  end
end

