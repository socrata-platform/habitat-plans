# frozen_string_literal: true

origin = node['hab']['origin']
plan = node['hab']['plan']

apt_update 'default'
package 'curl'
# package %w[iproute2 net-tools]
# directory '/run/sshd'

hab_install 'default'
hab_sup 'default'

execute "Generate a stub signing key for #{origin}" do
  command "hab origin key generate #{origin}"
  not_if "hab origin key export #{origin}"
end

execute "Build #{origin}/#{plan}" do
  command "hab pkg build #{plan}"
  cwd '/tmp/habitat-plans'
  environment HAB_ORIGIN: origin
  live_stream true
end

execute "Install #{origin}/#{plan}" do
  command(
    lazy do
      file = File.read('/tmp/habitat-plans/results/last_build.env')
                 .match(/^pkg_artifact=(.*)$/)[1]
      "hab pkg install /tmp/habitat-plans/results/#{file}"
    end
  )
  live_stream true
end
