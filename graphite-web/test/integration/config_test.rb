# frozen_string_literal: true

pkg_origin = ENV['HAB_ORIGIN']
pkg_path = command("hab pkg path #{pkg_origin}/graphite-web").stdout.strip
pkg_svc_config_path = '/hab/svc/graphite-web/config'
pkg_svc_data_path = '/hab/svc/graphite-web/data'
pkg_svc_var_path = '/hab/svc/graphite-web/var'

expected_ls = <<-EXP.gsub(/^ {2}/, '')
  GRAPHITE_ROOT = '#{pkg_path}'
  CONF_DIR = '#{pkg_svc_config_path}'
  STORAGE_DIR = '#{pkg_svc_data_path}'
  CONTENT_DIR = '#{pkg_path}/webapp/content'
  WHISPER_DIR = '/hab/svc/carbon-cache/data/whisper'
  RRD_DIR = '/hab/svc/carbon-cache/data/rrd'
  CERES_DIR = '/hab/svc/carbon-cache/data/ceres'
  LOG_DIR = '#{pkg_svc_var_path}'
  INDEX_FILE = '#{pkg_svc_data_path}/index'
  SECRET_KEY = 'UNSAFE_DEFAULT'
  TIME_ZONE = 'UTC'
  DATABASES = {

    'default': { 'ENGINE': 'django.db.backends.sqlite3', 'NAME': '/hab/svc/graphite-web/data/graphite.db', },
  }

  try:
    from graphite.local_settings_dynamic import *
  except ImportError:
    pass
EXP

describe file(File.join(pkg_svc_config_path, 'local_settings.py')) do
  its(:content) { should eq(expected_ls) }
end

describe file(File.join(pkg_svc_config_path, 'graphTemplates.conf')) do
  its(:content) do
    expected = <<-EXP.gsub(/^ +/, '')
      [default]
      background = black
      fontBold = False
      fontItalic = False
      fontName = Sans
      fontSize = 10
      foreground = white
      lineColors = blue,green,red,purple,brown,yellow,aqua,grey,magenta,pink,gold,rose
      majorLine = white
      minorLine = grey

    EXP
    should eq(expected)
  end
end

describe file(File.join(pkg_svc_config_path, 'graphite.wsgi')) do
  its(:content) do
    expected = <<-EXP.gsub(/^ +/, '')
      import os, sys
      sys.path.append('#{pkg_path}/webapp')
      os.environ['DJANGO_SETTINGS_MODULE'] = 'graphite.settings'

      import django.core.handlers.wsgi

      application = django.core.handlers.wsgi.WSGIHandler()

      # READ THIS
      # Initializing the search index can be very expensive, please include
      # the WSGIImportScript directive pointing to this script in your vhost
      # config to ensure the index is preloaded before any requests are handed
      # to the process.
      from graphite.logger import log
      log.info("graphite.wsgi - pid %d - reloading search index" % os.getpid())
      import graphite.metrics.search
    EXP
    should eq(expected)
  end
end
