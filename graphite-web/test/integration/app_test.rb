# frozen_string_literal: true

pkg_origin = ENV['HAB_ORIGIN']
pkg_path = command("hab pkg path #{pkg_origin}/carbon").stdout
pip_path = File.join(pkg_path, 'bin/pip')

describe directory('/opt/graphite') do
  it { should_not exist }
end

describe pip('graphite-web', pip_path) do
  it { should_not be_installed }
end

describe command("PYTHONPATH=#{pkg_path}/webapp #{pip_path} show graphite-web") do
  its(:exit_status) { should eq(0) }
  its(:stdout) { should match(/^Version: 0\.9\.12$/) }
  its(:stdout) { should match(%r{^Location: #{pkg_path}/lib$}) }
end

{
  'Django' => '1.5.5',
  'django-tagging' => '0.3.6',
  'pyparsing' => nil,
  'python-memcached' => nil,
  'pytz' => nil,
'Twisted' => '13.1.0',
'txAMQP' => nil,
  'uWSGI' => nil,
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

%w[content graphite].each do |d|
  describe directory(File.join(pkg_path, d)) do
    it { should exist }
    its(:owner) { should eq('root') }
    its(:group) { should eq('root') }
    its(:mode) { should cmp('0755') }
  end
end
