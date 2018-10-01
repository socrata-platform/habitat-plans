# frozen_string_literal: true

pkg_origin = ENV['HAB_ORIGIN']
pkg_path = command("hab pkg path #{pkg_origin}/carbon").stdout.strip
pip_path = File.join(pkg_path, 'bin/pip')

describe directory('/opt/graphite') do
  it { should_not exist }
end

describe pip('carbon', pip_path) do
  it { should_not be_installed }
end

describe command("PYTHONPATH=#{pkg_path}/lib #{pip_path} show carbon") do
  its(:exit_status) { should eq(0) }
  its(:stdout) { should match(/^Version: 0\.9\.12$/) }
  its(:stdout) { should match(%r{^Location: #{pkg_path}/lib$}) }
end

{
  'Twisted' => '13.1.0',
  'txAMQP' => nil,
  'whisper' => nil,
  'zope.interface' => nil
}.each do |pkg, ver|
  describe pip(pkg, pip_path) do
    it { should be_installed }
    its(:version) { should eq(ver) } unless ver.nil?
  end

  describe command("#{pip_path} show #{pkg}") do
    its(:exit_status) { should eq(0) }
    its(:stdout) do
      should match(%r{^Location: #{pkg_path}/lib/python2\.7/site-packages$})
    end
  end
end

describe command("#{pkg_path}/bin/carbon-client.py --help") do
  its(:exit_status) { should eq(0) }
  its(:stdout) { should match(/^Usage: carbon-client\.py/) }
end
