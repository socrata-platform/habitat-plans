# frozen_string_literal: true

title "#{ENV['pkg_origin']}/{ENV['pkg_name']}"

control 'config' do
  impact 1.0
  title 'Config checks'
  desc "Config checks for #{ENV['pkg_origin']}/#{ENV['pkg_name']}"

  describe file(File.join(ENV['pkg_svc_config_path'], 'carbon.conf')) do
    it { should exist }
    its(:owner) { should eq(ENV['pkg_svc_user']) }
    its(:group) { should eq(ENV['pkg_svc_group']) }
    its(:mode) { should cmp('0740') }
  end

  describe ini(File.join(ENV['pkg_svc_config_path'], 'carbon.conf')) do
    its(:'cache.USER') { should eq(ENV['pkg_svc_user']) }
  end
end

describe file(File.join(ENV['pkg_svc_config_path'], 'storage-schemas.conf')) do
  it { should exist }
  its(:owner) { should eq(ENV['pkg_svc_user']) }
  its(:group) { should eq(ENV['pkg_svc_group']) }
  its(:mode) { should cmp('0740') }
end
