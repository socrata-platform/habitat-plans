# frozen_string_literal: true

title "#{ENV['pkg_origin']}/{ENV['pkg_name']}"

control 'service' do
  impact 1.0
  title 'Service checks'
  desc "Service checks for #{ENV['pkg_origin']}/#{ENV['pkg_name']}"

  describe port(ENV['cfg_master_port']) do
    it { should be_listening }
    its(:protocols) { should eq(%w[tcp]) }
    its(:addresses) { should eq(%w[0.0.0.0]) }
    its(:processes) { should eq(%w[nginx]) }
  end

  master_proc = "nginx: master process #{ENV['nginx_pkg_path']}/bin/nginx " \
                "-c #{ENV['pkg_svc_config_path']}/nginx.conf"

  describe processes(master_proc) do
    it { should exist }
    its(:'entries.length') { should eq(1) }
  end

  master_pid = file(File.join(ENV['pkg_svc_path'], 'PID')).content

  describe file("/proc/#{master_pid}/limits") do
    its(:content) do
      limit = ENV['cfg_master_file_limit']
      should match(/^Max open files\W+#{limit}\W+#{limit}\W+files\W+$/)
    end
  end

  worker_procs = 'nginx: worker process'

  describe processes(worker_procs) do
    it { should exist }
    its(:'entries.length') { should eq(ENV['cfg_workers_processes'].to_i) }
  end

  processes(worker_procs).pids.each do |p|
    describe file("/proc/#{p}/limits") do
      its(:content) do
        limit = ENV['cfg_workers_file_limit']
        should match(/^Max open files\W+#{limit}\W+#{limit}\W+files\W+$/)
      end
    end
  end

  %w[access.log error.log http-error.log].each do |f|
    describe file(File.join(ENV['pkg_svc_var_path'], f)) do
      it { should exist }
      its(:owner) { should eq(ENV['pkg_svc_user']) }
      its(:group) { should eq(ENV['pkg_svc_group']) }
      its(:mode) { should cmp('0644') }
    end
  end
end
