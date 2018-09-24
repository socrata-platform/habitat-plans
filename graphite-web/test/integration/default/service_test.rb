# frozen_string_literal: true

pkg_origin = ENV['HAB_ORIGIN']
pkg_path = command("hab pkg path #{pkg_origin}/graphite-web").stdout
svc_pid = file('/hab/svc/graphite-web/PID').content
ip_addr = file('/etc/hosts').content.lines.last.split.first

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

describe command('/hab/svc/carbon-cache/hooks/health_check') do
  its(:exit_status) { should eq(0) }
  its(:stdout) { should eq('OK: All health checks are passing') }
end

describe processes('{uwsgi} graphite-web') do
  it { should exist }
  its(:'entries.length') { should eq(9)
end

processes('{uwsgi} graphite-web').pids.each do |p|
  describe file("/proc/#{p}/limits") do
    its(:content) do
      should match(/^Max open files\W+1024\W+1024\W+files\W+$/)
    end
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
        --carbon #{ip_addr}:2003 \
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

describe port(8000) do
  it { should be_listening }
  its(:protocols) { should eq(%w[tcp]) }
  its(:addresses) { should eq('0.0.0.0') }
  its(:processes) { should eq('graphite-web') }
end

%w[info.log exception.log].each do |f|
  describe file(File.join('/hab/svc/graphite-web/var', f)) do
    it { should exist }
    its(:owner) { should eq('hab') }
    its(:group) { should eq('hab') }
    its(:mode) { should eq('0644') }
  end
end
