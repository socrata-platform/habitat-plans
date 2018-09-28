# frozen_string_literal: true

require_relative 'spec_helper'

describe directory('/opt/graphite') do
  it { should_not exist }
end
