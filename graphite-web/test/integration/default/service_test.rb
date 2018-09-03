# frozen_string_literal: true

pkg_origin = ENV['HAB_ORIGIN']
pkg_path = command("hab pkg path #{pkg_origin}/carbon-cache").stdout
svc_pid = file('/hab/svc/graphite-web/PID').content

describe command('hab sup status') do
  its(:exit_status) { should eq(0) }
  its(:stdout) do
    exp = Regexp.new("^#{pkg_origin}/graphite-web/[0-9]+\\.[0-9+\\.[0-9]+/" \
                     '[0-9]+\W+standalone\W+up\W+[0-9]+\W+[0-9]+\W+' \
                     'graphite-web.default$')
    should match(exp)
  end
end

describe command("hab svc status #{pkg_origin}/graphite-web") do
  its(:exit_status) { should eq(0) }
end

describe processes("#{pkg_path}/bin/uwsgi

  it { should exist }
  its(:'entries.length') { should eq(1)
end

describe file("/proc/#{pid}/limits") do
  its(:content) do
    should match(/^Max open files\W+1024\W+1024\W+files\W+$/)
  end
end

describe file('/hab/svc/graphite-web/hooks/run') do
  it { should exist }
  its(:owner) { should eq('root') }
  its(:group) { should eq('hab') }
  its(:mode) { should cmp('0755') }
  its(:content) do
    exp = <<-EXP.gsub(/^ {6}/, '')
      #!/bin/sh

      exec 2>&1

      ulimit -n 1024

      exec #{pkg_path}/bin/uwsgi \
        --processes 8 \
        --plugins carbon \
        --carbon 127.0.0.1::2003 \
        --pythonpath #{pkg_path}/lib \
        --pythonpath #{pkg_path}/webapp/graphite \
        --wsgi-file /hab/svc/graphite-web/conf/graphite.wsgi \
        --no-orphans \
        --master \
        --procname graphite-web \
        --die-on-term \
        --socket /hab/svc/graphite-web/var/uwsgi.sock
    EXP
    should eq(exp)
  end
end

describe file('/hab/svc/graphite-web/var/uwsgi.sock') do
  it { should exist }
  it { should be_socket }
  its(:owner) { should eq('root') }
  its(:group) { should eq('hab') }
  its(:mode) { should cmp('0755') }
end
