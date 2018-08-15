# frozen_string_literal: true

pkg_origin = 'socrata'
pkg_name = 'carbon'
pkg_ver = command("ls /hab/pkgs/#{pkg_origin}/#{pkg_name}").stdout.split.last
pkg_build = command("ls /hab/pkgs/#{pkg_origin}/#{pkg_name}/#{pkg_ver}")
            .stdout.split.last
pkg_path = File.join('/hab/pkgs', pkg_origin, pkg_name, pkg_ver, pkg_build)
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
  # 'Django' => '1.5.5',
  # 'django-tagging' => '0.3.6',
  # 'pyparsing' => nil,
  # 'python-memcached' => nil,
  # 'pytz' => nil,
  'Twisted' => '13.1.0',
  'txAMQP' => nil,
  # 'uWSGI' => nil,
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
