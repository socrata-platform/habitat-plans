# frozen_string_literal: true

pkg_origin = ENV['HAB_ORIGIN']
pkg_path = command("hab pkg path #{pkg_origin}/graphite-web").stdout.strip
ip_addr = file('/etc/hosts').content.lines.last.split.first

describe command('hab sup status') do
  its(:exit_status) { should eq(0) }
  its(:stdout) do
    exp = Regexp.new("^#{pkg_origin}/graphite-web/[0-9]+\\.[0-9]+\\.[0-9]+/" \
                     '[0-9]+\W+standalone\W+up\W+up\W+[0-9]+\W+[0-9]+\W+' \
                     'graphite-web.default$')
    should match(exp)
  end
  its(:stdout) do
    exp = Regexp.new('^socrata/carbon-cache/[0-9]+\\.[0-9]+\\.[0-9]+/' \
                     '[0-9]+\W+standalone\W+up\W+up\W+[0-9]+\W+[0-9]+\W+' \
                     'carbon-cache.default$')
    should match(exp)
  end
end

describe command('hab svc status socrata/carbon-cache') do
  its(:exit_status) { should eq(0) }
end

describe command("hab svc status #{pkg_origin}/graphite-web") do
  its(:exit_status) { should eq(0) }
end

describe http('http://127.0.0.1:9631/services/graphite-web/default/health') do
  its(:body) { should include('"status":"OK"') }
end

expected_run = <<-EXP.gsub(/^ {2}/, '')
  #!/bin/sh

  exec 2>&1

  ulimit -n 1024

  # The build-index script in pre-1.0 graphite-web uses environment variables
  # only and doesn't respect the settings in local_settings.py.
  export GRAPHITE_ROOT="#{pkg_path}"
  export GRAPHITE_STORAGE_DIR="/hab/svc/graphite-web/data"
  export WHISPER_DIR="/hab/svc/carbon-cache/data/whisper"

  exec #{pkg_path}/bin/uwsgi \\
    --processes 8 \\
    --carbon #{ip_addr}:2003 \\
    --pythonpath /hab/svc/graphite-web/config \\
    --pythonpath #{pkg_path}/lib \\
    --pythonpath #{pkg_path}/webapp/graphite \\
    --wsgi-file /hab/svc/graphite-web/config/graphite.wsgi \\
    --no-orphans \\
    --master \\
    --procname graphite-web \\
    --die-on-term \\
    --socket :8000
EXP

describe file('/hab/svc/graphite-web/hooks/run') do
  it { should exist }
  its(:owner) { should eq('root') }
  its(:group) { should eq('root') }
  its(:mode) { should cmp('0755') }
  its(:content) { should eq(expected_run) }
end
