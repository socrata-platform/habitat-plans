# frozen_string_literal: true

conf = '/hab/svc/carbon-cache/config'

describe file(File.join(conf, 'carbon.conf')) do
  its(:content) do
    expected = <<-EXP.gsub(/^ +/, '')
      [cache]
      LOCAL_DATA_DIR = /hab/svc/carbon-cache/data/whisper
      WHITELISTS_DIR = /hab/svc/carbon-cache/data/lists
      CONF_DIR = /hab/svc/carbon-cache/config
      PID_DIR = /hab/svc/carbon-cache/var
      MAX_UPDATES_PER_SECOND = 100
      MAX_CREATES_PER_MINUTE = 200
      LINE_RECEIVER_PORT = 2003
      UDP_RECEIVER_PORT = 2003
      PICKLE_RECEIVER_PORT = 2004
      ENABLE_UDP_LISTENER = True
      CACHE_QUERY_PORT = 7002
      LOG_UPDATES = False
      LOG_CACHE_HITS = False
    EXP
    should eq(expected)
  end
end

describe file(File.join(conf, 'storage-schemas.conf')) do
  its(:content) do
    expected = <<-EXP.gsub(/^ +/, '')
      [500_carbon]
      PATTERN = ^carbon\.
      RETENTIONS = 60s:90d

      [500_core_60s_6days_15min_year]
      PATTERN = ^core\.
      RETENTIONS = 60s:1d,15m:7d,1h:365d

      [500_metrics_default]
      PATTERN = ^metrics\.
      RETENTIONS = 60s:1d,15m:7d,1h:365d

      [999_default_1min_for_1day]
      PATTERN = .*
      RETENTIONS = 60s:1d,5m:14d,1h:365d
    end
  end
end
