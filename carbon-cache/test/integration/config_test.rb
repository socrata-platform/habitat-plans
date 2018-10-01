# frozen_string_literal: true

pkg_svc_config_path = '/hab/svc/carbon-cache/config'

describe file(File.join(pkg_svc_config_path, 'carbon.conf')) do
  its(:content) do
    expected = <<-EXP.gsub(/^ +/, '')
      [cache]
      LOCAL_DATA_DIR = /hab/svc/carbon-cache/data/whisper
      WHITELISTS_DIR = /hab/svc/carbon-cache/data/lists
      CONF_DIR = /hab/svc/carbon-cache/config
      PID_DIR = /hab/svc/carbon-cache/var
      CACHE_QUERY_PORT = 7002
      ENABLE_UDP_LISTENER = True
      LINE_RECEIVER_PORT = 2003
      LOG_CACHE_HITS = False
      LOG_UPDATES = False
      MAX_CREATES_PER_MINUTE = 200
      MAX_UPDATES_PER_SECOND = 100
      PICKLE_RECEIVER_PORT = 2004
      STORAGE_DIR = /hab/svc/carbon-cache/data
      UDP_RECEIVER_PORT = 2003

    EXP
    should eq(expected)
  end
end

describe file(File.join(pkg_svc_config_path, 'storage-schemas.conf')) do
  its(:content) do
    expected = <<-EXP.gsub(/^ +/, '')
      [500_carbon]
      PATTERN = ^carbon\\.
      RETENTIONS = 60s:90d
      [999_default_1min_for_1day]
      PATTERN = .*
      RETENTIONS = 60s:1d,5m:14d,1h:365d

    EXP
    should eq(expected)
  end
end
