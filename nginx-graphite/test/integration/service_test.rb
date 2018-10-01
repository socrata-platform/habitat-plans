# frozen_string_literal: true

pkg_origin = ENV['HAB_ORIGIN']
nginx_pkg_path = command('hab pkg path core/nginx').stdout

describe command('hab sup status') do
  its(:exit_status) { should eq(0) }
  its(:stdout) do
    exp = Regexp.new("^#{pkg_origin}/nginx-graphite/[0-9]+\\.[0-9]+\\.[0-9]+/" \
                     '[0-9]+\W+standalone\W+up\W+up\W+[0-9]+\W+[0-9]+\W+' \
                     'graphite-web.default$')
    should match(exp)
  end
  %w[graphite-web carbon-cache].each do |svc|
    its(:stdout) do
      exp = Regexp.new("^socrata/#{svc}/[0-9]+\\.[0-9]+\\.[0-9]+/" \
                     '[0-9]+\W+standalone\W+up\W+up\W+[0-9]+\W+[0-9]+\W+' \
                     "#{svc}.default$")
      should match(exp)
    end
  end
end

describe command("hab svc status #{pkg_origin}/nginx-graphite") do
  its(:exit_status) { should eq(0) }
end

%w[graphite-web carbon-cache].each do |svc|
  describe command("hab svc status socrata/#{svc}") do
    its(:exit_status) { should eq(0) }
  end
end

describe http('http://127.0.0.1:9631/services/nginx-graphite/default/health') do
  its(:body) { should include('"status":"OK"') }
end

describe file('/hab/svc/carbon-cache/hooks/run') do
  it { should exist }
  its(:owner) { should eq('root') }
  its(:group) { should eq('root') }
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
