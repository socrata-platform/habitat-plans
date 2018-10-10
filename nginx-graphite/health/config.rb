# frozen_string_literal: true

title "#{ENV['pkg_origin']}/{ENV['pkg_name']}"

control 'config' do
  impact 1.0
  title 'Config checks'
  desc "Config checks for #{ENV['pkg_origin']}/#{ENV['pkg_name']}"

  %w[nginx.conf uwsgi_params mime.types].each do |f|
    describe file(File.join(ENV['pkg_svc_config_path'], f)) do
      it { should exist }
      its(:owner) { should eq(ENV['pkg_svc_user']) }
      its(:group) { should eq(ENV['pkg_svc_group']) }
      its(:mode) { should cmp('0740') }
    end
  end
end
