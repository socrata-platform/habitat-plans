# frozen_string_literal: true

title "#{ENV['pkg_origin']}/{ENV['pkg_name']}"

control 'service' do
  impact 1.0
  title 'Service checks'
  desc "Service checks for #{ENV['pkg_origin']}/#{ENV['pkg_name']}"

  describe processes('{uwsgi} graphite-web') do
    it { should exist }
    its(:'entries.length') { should eq(ENV['cfg_system_workers'].to_i + 1) }
  end

  processes('{uwsgi} graphite-web').pids.each do |p|
    describe file("/proc/#{p}/limits") do
      its(:content) do
        limit = ENV['cfg_system_file_limit']
        should match(/^Max open files\W+#{limit}\W+#{limit}\W+files\W+$/)
    end
  end

  describe port(ENV['cfg_system_port']) do
    it { should be_listening }
    its(:protocols) { should eq(%w[tcp]) }
    its(:addresses) { should eq('0.0.0.0') }
    its(:processes) { should eq('graphite-web') }
  end

  %w[info.log exception.log].each do |f|
    describe file(File.join(ENV['pkg_svc_var_path'], f)) do
      it { should exist }
      its(:owner) { should eq(ENV['pkg_svc_user']) }
      its(:group) { should eq(ENV['pkg_svc_group']) }
      its(:mode) { should eq('0644') }
    end
  end
end
