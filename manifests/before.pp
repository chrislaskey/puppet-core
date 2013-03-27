class core::before {

	# Update package list
	# ==========================================================================

	file { "/etc/apt/sources.list":
		ensure => "present",
		source => $operatingsystem ? {
			Ubuntu => "puppet:///modules/core/apt/ubuntu.sources.list",
			Debian => "puppet:///modules/core/apt/debian.sources.list",
		},
		owner => "root",
		group => "root",
		mode => "0644",
	}

	exec { "apt-get update":
		command => "apt-get update",
		path => "/bin:/sbin:/usr/bin:/usr/sbin",
		refreshonly => "true",
		logoutput => "on_failure",
		subscribe => [
			File["/etc/apt/sources.list"],
		],
	}

}
