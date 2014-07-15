require "tmpdir"

PI_IP = "sideshowcoder.no-ip.info"
PI_USER = "pi"

desc "ship the current project of to the pi"
task :ship_to_pi do
  Dir.mktmpdir do |dir|
    tar_file = "#{dir}/pi_on_couch.tar.gz"
    system "tar -zcvf #{tar_file} ./"
    system "scp #{tar_file} #{PI_USER}@#{PI_IP}:~/"
  end
end
