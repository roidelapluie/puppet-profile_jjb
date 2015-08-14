class profile_jjb(
  String $pipeline,
  String $pipeline_path = '/git',
  String $tmp_path = '/var/tmp/jjb',
) {

  package {
    'git':
      ensure => installed,
  }

  package{
    'ruby-devel':
      ensure => installed,
  } ->
  package{
    'rubygems':
      ensure => installed,
  } ->
  package {
    'fpm':
      ensure   => installed,
      provider => 'gem',
  }

  include jjb

  Package['git'] -> Class['jjb::python']

  Package['git'] -> Exec["Pipeline $pipeline"]
  Package['fpm'] -> Exec["Pipeline $pipeline"]
  vcsrepo {
    "${tmp_path}/${pipeline}":
      ensure   => latest,
      provider => 'git',
      source   => "${pipeline_path}/${pipeline}",
  }
  ~>
  exec { "Pipeline $pipeline":
    command     => "jenkins-jobs update -r ${tmp_path}/${pipeline}",
    path        => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
    refreshonly => true,
    tries       => 90,
    try_sleep   => 1,
    require     => [Class['profile_jenkins', 'jjb'], Class['jenkins::service']],
  }

}
