# Habitat package: inspec

## Description

A minimal installation of Inspec for use with Habitat service health checks. Unlike the [chef/inspec](https://app.habitat.sh/#/pkgs/chef/inspec) package, this one includes just enough to run locally in an attempt to shave of as many of the nearly-a-gigabyte-worth of dependencies the other package pulls in.

Writing robust health checks in Bash is often painful and writing robust smoke tests for a plan often feels like duplicating that effort. Habitat should be able to use Inspec tests as health checks!

## Usage

Write a set of Inspec tests for your service package and put them in a `health` directory. Note that the test files are not processed as Habitat templates, so any package info will have to be passed in as environment variables.

```ruby
title "#{ENV['pkg_origin']}/{ENV['pkg_name']}"

control 'service' do
  impact 1.0
  title 'Service checks'
  desc "Service checks for #{ENV['pkg_name']}"

  describe file("#{ENV['pkg_svc_var_path']}/#{ENV['pkg_name']}.pid") do
    it { should exist }
  end

  describe port(ENV['cfg_port']) do
    it { should be_listening }
  end
end
```

Add this package to your dependencies and copy the test files over as part of the install step.

```shell
pkg_deps=("socrata/inspec")

do_install() {
  cp -rp health "${pkg_prefix}"
}
```

In your `health_check` hook, set any environment variables needed and run Inspec, making sure that Inspec won't try to write any files to its root-owned package directory.

```shell
#!/bin/sh

export pkg_origin="{{pkg.origin}}"
export pkg_name="{{pkg.name}}"
export pkg_svc_var_path="{{pkg.svc_var_path}}"
export cfg_port="{{cfg.port}}"

{{pkgPathFor "socrata/inspec"}}/bin/inspec exec {{pkg.path}}/health \
  --vendor-cache={{pkg.svc_var_path}}/inspec/cache \
  --no-create-lockfile

if [ $? != 0 ];
  exit 2
else
  exit 0
fi
```

Note that, because Inspec tests are purely pass/fail, there is no way to set separate thresholds for warning/critical/unknown.
