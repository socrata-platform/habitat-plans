# frozen_string_literal: true

title "#{ENV['pkg_origin']}/{ENV['pkg_name']}"

control 'service' do
  impact 1.0
  title 'Service checks'
  desc "Service checks for #{ENV['pkg_origin']}/#{ENV['pkg_name']}"

  describe port(ENV['cfg_cache_line_receiver_port']) do
    it { should be_listening }
    its(:protocols) { should include('tcp') }
    its(:addresses) { should eq(%w[0.0.0.0]) }
    its(:processes) { should eq('python') }
  end

  if ENV['cfg_cache_enable_udp_listener'].to_s.casecmp('true').zero?
    describe port(ENV['cfg_cache_udp_receiver_port']) do
      it { should be_listening }
      its(:protocols) { should include('udp') }
      its(:addresses) { should eq('0.0.0.0') }
      its(:processes) { should eq('python') }
    end
  end

  describe port(ENV['cfg_cache_pickle_receiver_port']) do
    it { should be_listening }
    its(:protocols) { should eq(%w[tcp]) }
    its(:addresses) { should eq(%w[0.0.0.0]) }
    its(:processes) { should eq('python') }
  end

  describe port(ENV['cfg_cache_cache_query_port']) do
    it { should be_listening }
    its(:protocols) { should eq(%w[tcp]) }
    its(:addresses) { should eq(%w[0.0.0.0]) }
    its(:processes) { should eq('python') }
  end

  describe processes("#{ENV['pkg_path']}/bin/python " \
                   "#{ENV['pkg_path']}/bin/carbon-cache.py " \
                   "--config=#{ENV['pkg_svc_config_path']}/carbon.conf " \
                   '--debug start') do
    it { should exist }
    its(:'entries.length') { should eq(1) }
  end

  pid = file(File.join(ENV['pkg_svc_path'], 'PID')).content

  describe file("/proc/#{pid}/limits") do
    its(:content) do
      limit = ENV['cfg_system_file_limit']
      should match(/^Max open files\W+#{limit}\W+#{limit}\W+files\W+$/)
    end
  end

  describe directory(File.join(ENV['pkg_svc_data_path'], 'whisper')) do
    it { should exist }
    its(:owner) { should eq(ENV['pkg_svc_user']) }
    its(:group) { should eq(ENV['pkg_svc_group']) }
    its(:mode) { should cmp('0755') }
  end

  describe file(File.join(ENV['pkg_svc_var_path'], 'carbon-cache-a.pid')) do
    it { should exist }
    its(:owner) { should eq(ENV['pkg_svc_user']) }
    its(:group) { should eq(ENV['pkg_svc_group']) }
    its(:mode) { should cmp('0644') }
    its(:content) { should eq(pid) }
  end

  describe file('/hab/svc/carbon-cache/var/carbon-cache.log') do
    it { should exist }
    its(:owner) { should eq(ENV['pkg_svc_user']) }
    its(:group) { should eq(ENV['pkg_svc_group']) }
    its(:mode) { should cmp('0644') }
    its(:content) { should match(/carbon-cache stuff/) }
  end
end
