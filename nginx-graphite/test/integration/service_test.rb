# frozen_string_literal: true

pkg_origin = ENV['HAB_ORIGIN']
pkg_path = command("hab pkg path #{pkg_origin}/nginx-graphite").stdout
nginx_pkg_path = command('hab pkg path core/nginx').stdout
svc_pid = file('/hab/svc/nginx-graphite/PID').content

describe command('hab sup status') do
  its(:exit_status) { should eq(0) }
  its(:stdout) do
    exp = Regexp.new("^#{pkg_origin}/nginx-graphite/[0-9]+\\.[0-9+\\.[0-9]+/" \
                     '[0-9]+\W+standalone\W+up\W+[0-9]+\W+[0-9]+\W+' \
                     'nginx-graphite.default$')
    should match(exp)
  end
end

describe command("hab svc status #{pkg_origin}/nginx-graphite") do
  its(:exit_status) { should eq(0) }
end

describe command('/hab/svc/carbon-cache/hooks/health_check') do
  its(:exit_status) { should eq(0) }
end

describe file('/hab/svc/carbon-cache/hooks/run') do
  it { should exist }
  its(:owner) { should eq('hab') }
  its(:group) { should eq('hab') }
  its(:mode) { should cmp('0755') }
  its(:content) do
    exp = <<-EXP.gsub(/^ {6}/, '')
      #!/bin/sh

      exec 2>&1

      ulimit -n 10000

      exec #{nginx_pkg_path}/bin/nginx \
        -c /hab/svc/nginx-graphite/config/nginx.conf
    EXP
    should eq(exp)
  end
end
