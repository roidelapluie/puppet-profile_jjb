class profile_jjb(
  String $pipeline,
  String $pipeline_path = '/git',
  String $tmp_path = '/var/tmp/jjb',
) {

  package {
    'git':
      ensure => installed,
  }

  include jjb

  Package['git'] -> Class['jjb::python']

  vcsrepo {
    "${tmp_path}/${pipeline}":
      ensure   => latest,
      provider => 'git',
      source   => "${pipeline_path}/${pipeline}",
  }
  ~>
  exec { "Pipeline $pipeline":
    command     => "jenkins-jobs update ${tmp_path}/${pipeline}",
    path        => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
    refreshonly => true,
    require     => Class['profile_jenkins', 'jjb'],
  }

}
