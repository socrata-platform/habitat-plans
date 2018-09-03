# frozen_string_literal: true

pkg_origin = ENV['HAB_ORIGIN']

describe command('hab sup status') do
  its(:exit_status) { should eq(0) }
  its(:stdout) do
    exp = Regexp.new('^socrata/carbon-cache/[0-9]+\\.[0-9+\\.[0-9]+/' \
                     '[0-9]+\W+standalone\W+up\W+[0-9]+\W+[0-9]+\W+' \
                     'carbon-cache.default$')
    should match(exp)
  end
end

describe port(2003) do
  it { should be_listening }
  its(:protocols) { should eq(%w[udp tcp]) }
  its(:addresses) { should eq('0.0.0.0') }
  its(:processes) { should eq('python2.7') }
end

describe port(2004) do
  it { should be_listening }
  its(:protocols) { should eq(%w[tcp]) }
  its(:addresses) { should eq('0.0.0.0') }
  its(:processes) { should eq('python2.7') }
end

describe port(7002) do
  it { should be_listening }
  its(:protocols) { should eq(%w[tcp]) }
  its(:addresses) { should eq('0.0.0.0') }
  its(:processes) { should eq('python2.7') }
end

describe command("hab svc status #{pkg_origin}/carbon-cache") do
  its(:exit_status) { should eq(0) }
end
