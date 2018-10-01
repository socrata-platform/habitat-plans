GRAPHITE_ROOT = '{{pkg.path}}'
CONF_DIR = '{{pkg.svc_config_path}}'
STORAGE_DIR = '{{pkg.svc_data_path}}'
CONTENT_DIR = '{{pkg.path}}/webapp/content'
{{#with bind.carbon-cache.first as |carbon| ~}}
WHISPER_DIR = '{{carbon.cfg.storage_dir}}/whisper'
RRD_DIR = '{{carbon.cfg.storage_dir}}/rrd'
CERES_DIR = '{{carbon.cfg.storage_dir}}/ceres'
{{/with ~}}
LOG_DIR = '{{pkg.svc_var_path}}'
INDEX_FILE = '{{pkg.svc_data_path}}/index'
{{#each cfg.web ~}}
{{toUppercase @key}} = '{{this}}'
{{/each ~}}

DATABASES = {
{{#each cfg.databases }}
  '{{@key}}': { {{#each this }}'{{toUppercase @key}}': '{{this}}', {{/each }}},
{{/each ~}}
}

try:
  from graphite.local_settings_dynamic import *
except ImportError:
  pass
