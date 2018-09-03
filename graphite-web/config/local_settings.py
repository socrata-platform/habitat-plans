GRAPHITE_ROOT = '{{pkg.svc_path}}'
CONF_DIR = '{{pkg.svc_config_path}}'
STORAGE_DIR = '{{pkg.svc_data_path}}'
WHISPER_DIR = '{{bind.carbon_cache.members.first.svc_data_path}}/whisper'
RRD_DIR = '{{bind.carbon_cache.members.first.svc_data_path}}/rrd'
CERES_DIR = '{{bind.carbon_cache.members.first.svc_data_path}}/ceres'
LOG_DIR = '{{pkg.svc_path}}/logs'
INDEX_FILE = '{{pkg.svc_data_path}}/index'
{{#each cfg.web ~}}
{{toUppercase @key}} = '{{this}}'
{{/each ~}}

DATABASES = {
{{#each cfg.databases ~}}
  '@key': {
    {{#each this ~}}
    '{{toUpperCase @key}}': '{{this}}',
    {{/each ~}}
  },
{{/each ~}}
}

try:
  from graphite.local_settings_dynamic import *
except ImportError:
  pass
