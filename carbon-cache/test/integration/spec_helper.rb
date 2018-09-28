# frozen_string_literal: true

require 'json'
require 'timeout'

RSpec.configure do |c|
  c.before do
    Timeout::timeout(30) do
      url = 'http://127.0.0.1:9631/services/carbon-cache/default'

      while http(url).status != 200 || \
            JSON.parse(http(url).body)['process']['state'] != 'up'
        sleep(1)
      end
    end
  end
end
