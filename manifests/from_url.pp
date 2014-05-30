define deb::from_url (
  $package_name = '',
  $url,
  $version,
  $tmp_dir      = '/tmp'
) {

  $real_package_name = $package_name?{
    ''      => $name,
    default => $package_name,
  }

  $filename = inline_template("<%= @url.split('/').at(-1) %>")

  Exec{
    path  => $::path
  }

  exec {"check ${real_package_name}":
    command => 'true',
    unless  => "dpkg -l | grep ${real_package_name}",
    notify  => Exec["${real_package_name} download"]
  }

  exec {"${real_package_name} download":
    command     => "wget --output-document=${tmp_dir}/${filename} ${url}",
    creates     => "${tmp_dir}/${filename}",
    refreshonly => true
  }

  package {$real_package_name :
    ensure      => present,
    provider    => dpkg,
    source      => "${tmp_dir}/${filename}",
    require     => Exec["${real_package_name} download"]
  }
}

deb::from_url{'virtualbox-4.3':
  url => 'http://download.virtualbox.org/virtualbox/4.3.12/virtualbox-4.3_4.3.12-93733~Ubuntu~precise_amd64.deb',
  version => '4.3.12-93733~Ubuntu~precise'
}
