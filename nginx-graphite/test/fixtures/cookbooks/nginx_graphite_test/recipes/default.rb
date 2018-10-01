# frozen_string_literal: true

origin = node['hab']['origin']
plan = node['hab']['plan']

include_recipe 'hab_test'

hab_service 'socrata/carbon-cache'

hab_service 'socrata/graphite-web' do
  bind 'carbon-cache:carbon-cache.default'
end

hab_service "#{origin}/#{plan}" do
  bind 'graphite-web:graphite-web.default'
end

ruby_block "Wait for #{origin}/#{plan} to start" do
  block do
    svc = Chef::HTTP.new('http://127.0.0.1:9631')
                    .get("/services/#{plan}/default")
    raise unless JSON.parse(svc)['process']['state'] == 'up'
  end
  retries 30
  retry_delay 1
end
