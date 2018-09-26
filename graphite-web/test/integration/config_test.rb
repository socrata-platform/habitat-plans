# frozen_string_literal: true

conf = '/hab/svc/graphite-web/config'

describe file(File.join(conf, 'local_settings.py')) do
  its(:content) do
    expected = <<-EXP.gsub(/^ +/, '')
      SECRET_KEY = 'TODO_how_much_do_we_need_this'
      TIME_ZONE = 'UTC'
      CONF_DIR = '/opt/graphite/conf'
      STORAGE_DIR = '/data/graphite'
      DATABASES = {'default': {'NAME': '/data/graphite/graphite.db', 'ENGINE': 'django.db.backends.sqlite3'}}

      try:
        from graphite.local_settings_dynamic import *
      except ImportError:
        pass
    EXP
    should eq(expected)
  end
end

describe file(File.join(conf, 'graphTemplates.conf')) do
  its(:content) do
    expected = <<-EXP.gsub(/^ +/, '')
      [default]
      background = black
      foreground = white
      majorLine = white
      minorLine = grey
      lineColors = blue,green,red,purple,brown,yellow,aqua,grey,magenta,pink,gold,rose
      fontName = Sans
      fontSize = 10
      fontBold = False
      fontItalic = False
    EXP
    should eq(expected)
  end
end

describe file(File.join(conf, 'graphite.wsgi')) do
  its(:content) do
    expected = <<-EXP.gsub(/^ +/, '')
      import os, sys
      sys.path.append('/opt/graphite/webapp')
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
