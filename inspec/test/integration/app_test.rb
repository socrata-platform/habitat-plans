# frozen_string_literal: true

pkg_origin = ENV['HAB_ORIGIN']
pkg_path = command("hab pkg path #{pkg_origin}/inspec").stdout.strip

describe command("#{pkg_path}/bin/inspec --help") do
  its(:exit_status) { should eq(0) }
  its(:stdout) { should match(/^Commands:/) }
end
