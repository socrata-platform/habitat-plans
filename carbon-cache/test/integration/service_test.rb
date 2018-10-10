# frozen_string_literal: true

pkg_origin = ENV['HAB_ORIGIN']
carbon_pkg_path = command('hab pkg path socrata/carbon').stdout.strip

describe command('hab sup status') do
  its(:exit_status) { should eq(0) }
  its(:stdout) do
    exp = Regexp.new("^#{pkg_origin}/carbon-cache/[0-9]+\\.[0-9]+\\.[0-9]+/" \
                     '[0-9]+\W+standalone\W+up\W+up\W+[0-9]+\W+[0-9]+\W+' \
                     'carbon-cache.default$')
    should match(exp)
  end
end

describe command("hab svc status #{pkg_origin}/carbon-cache") do
  its(:exit_status) { should eq(0) }
end

describe http('http://127.0.0.1:9631/services/carbon-cache/default/health') do
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

      ulimit -n 1024

      exec #{carbon_pkg_path}/bin/python \\
        #{carbon_pkg_path}/bin/carbon-cache.py \\
        --config=/hab/svc/carbon-cache/config/carbon.conf \\
        --debug \\
        start
    EXP
    should eq(exp)
  end
end
