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

  #exec {"check ${real_package_name}":
  #  command => 'true',
  #  unless  => "dpkg -l ${real_package_name} | tail -n1 | awk '{print \$3}' | egrep -i '^${version}$'",
  #  notify  => Exec["${real_package_name} download"]
  #}

  exec {"${real_package_name} download":
    command     => "wget --output-document=${tmp_dir}/${filename} ${url}",
    creates     => "${tmp_dir}/${filename}",
    unless      => "dpkg -l ${real_package_name} | tail -n1 | awk '{print \$3}' | egrep -i '^${version}$'",
  }

  package {$real_package_name :
    ensure      => present,
    provider    => dpkg,
    source      => "${tmp_dir}/${filename}",
    require     => Exec["${real_package_name} download"],
    notify	    => Exec["rm ${real_package_name} deb"]
  }

  exec {"rm ${real_package_name} deb":
    command 	=> "rm ${tmp_dir}/${filename}",
    refreshonly => true
  }
}
