class deb {

  if !defined(Package['wget']) {
    package {'wget':
      ensure  => latest
    }
  }

}
