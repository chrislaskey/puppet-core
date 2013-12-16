class core {

	# Module classes
	# ==========================================================================

	class{ "core::params": }

	# Resource defaults
	# ==========================================================================

	Package {
		ensure => "present",
	}

	# Packages
	# ==========================================================================

	# Listed separately instead of an array so individual options can be set
	# per package

	package { "acpi": }

	package { "bash":
		ensure => "latest",
	}

	package { "bash-completion":
		ensure => "latest",
	}

	package { "bzip2": }

	package { "fail2ban": }

	package { "git":
		ensure => "latest",
	}

	package { "grep":
		name => [
			"grep",
			$operatingsystem ? {
				/(Ubuntu|Debian)/ => "ack-grep",
				/(CentOS|RedHat|Scientific)/ => "ack",
				default => "",
			},
		],
	}

	package { "gzip": }

	package { "htop": }

	package { "iftop": }

	package { "logwatch": }

	package { "nmap": }

	package { "ntp":
		name => $operatingsystem ? {
			/(Ubuntu|Debian)/ => "ntpdate",
			/(CentOS|RedHat|Scientific)/ => "ntp",
			default => "",
		},
	}

	if ! defined( Package["perl"] ){
		package { "perl":
			ensure => "latest",
		 }
	}

	package { "pv": }

	if ! defined( Package["ruby"] ){
		package { "ruby":
			ensure => "latest",
		 }
	}

	package { "rsync": }

	package { "sqlite":
		name => $operatingsystem ? {
			/(Ubuntu|Debian)/ => "sqlite3",
			/(CentOS|RedHat|Scientific)/ => "sqlite",
			default => "",
		},
	}

	package { "sudo": }

	package { "tcpdump": }

	package { "tcsh": }

	package { "tmux":
		ensure => "latest",
	}

	package { "unzip": }

	package { "vim":
		name => $operatingsystem ? {
					/(Ubuntu|Debian)/ => "vim",
					/(CentOS|RedHat|Scientific)/ => "vim-enhanced",
					default => "",
				},
		ensure => "latest",
	}

	package { "wget": }

	package { "zsh": }

	# Stdlib ensure packages
	# --------------------------------------------------------------------------
	# Use Puppet Stdlib module method "ensure_packages" to prevent "package
	# already defined" conflicts with other modules.

	ensure_packages(["curl", "make", "python"])

	# Distribution specific packages
	# --------------------------------------------------------------------------

	if $operatingsystem =~ /(Ubuntu|Debian)/ {

		package { "apt":
			name => [
				"apt",
				"apt-file",
				"python-software-properties",
			],
		}

		if ! defined( Package["iptables-persistent"] ){
			package { "iptables-persistent": }
		}

		package { "mailutils": }

		package { "mosh":
			ensure => "latest",
		}

	}

	if $operatingsystem != Debian {
		package { "mercurial": }
	}

	# Host file entries
	# ==========================================================================

	host { "puppet":
		ensure => "present",
		target => "/etc/hosts",
		ip => "$::serverip", #puppetmaster ip
		host_aliases => [ $::servername ], #puppetmaster fqdn
	}

	# Files
	# ==========================================================================
	# Note: the "files" dir is ommitted when using puppet:///.

	file { "/etc/shadow":
		ensure => "present",
		owner => "root",
		group => "shadow",
		mode => "0640",
	}

	file { "/etc/gshadow":
		ensure => "present",
		owner => "root",
		group => "shadow",
		mode => "0640",
	}

	file { "/etc/default/puppet":
		ensure => "present",
		source => "puppet:///modules/core/puppet/etc-default-puppet",
		owner => "root",
		group => "root",
		mode => "0644",
	}

	file { "/etc/puppet/puppet.conf":
		ensure => "present",
		source => "puppet:///modules/core/puppet/puppet.conf",
		owner => "root",
		group => "root",
		mode => "0644",
		# notify => Service["puppet"],
	}

	if ! defined( File["/data"] ){
		file { "/data":
			ensure => "directory",
			owner => "root",
			group => "puppet",
			mode => "0775",
		}
	}

	if ! defined( File["/data/puppet"] ){
		file { "/data/puppet":
			ensure => "directory",
			owner => "root",
			group => "puppet",
			mode => "0700",
			require => [
				File["/data"],
			],
		}
	}

	# Services
	# ==========================================================================

	# service { "puppet":
	# 	ensure => "running",
	# 	enable => true,
  	# }

	# Groups
	# ==========================================================================

	group { "sudo":
		ensure => "present",
	}

}
