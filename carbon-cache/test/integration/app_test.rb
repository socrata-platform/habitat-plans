# frozen_string_literal: true

describe directory('/opt/graphite') do
  it { should_not exist }
end
