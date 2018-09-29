# frozen_string_literal: true

source 'https://supermarket.chef.io'

cookbook 'hab_test', path: 'test/fixtures/cookbooks/hab_test'

Dir.glob('*/test/fixtures/cookbooks/*').each do |d|
  cookbook File.basename(d), path: d
end
