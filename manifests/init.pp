class core {

	# Module classes
	# ==========================================================================

	class{ "core::params": }

	# Class defaults
	# ==========================================================================

	# Package defaults example:
	#	Package { ensure => present, }
	#
	#	Makes individual package declarations:
	#		package { sudo: }
	#
	#	Equivalent to:
	#		package { sudo: ensure => present}

	# File defaults example:
	#	File {
	#		mode  => "0644",
	#		owner => "root",
	#		group => "root",
	#	 }

	# TODO: Multiverse is not being updated prior to installing packages. Works
	# on second run. This "Package" level require may not work as expected

	Package {
		ensure => "present",
		require => [
			Exec["apt-get-update-after-adding-multiverse-source"],
		],
	}

	# Packages
	# ==========================================================================

	# Example of OS-independent packages:
	#	package { "ssh":
	#		name => $operatingsystem ? {
	#			/(Ubuntu|Debian)/ => "openssh-server",
	#			Solaris => "openssh",
	#			default => "ssh",
	#		}
	#		ensure => "installed",
	#	}
	# Note: default line is optional. Will be set to nil if no matches are
	# found and no default is supplied.
	#
	# This is good for the occaisional check. See params class for an
	# alternate example that centralizes OS checks.

	# Listed separately instead of an array so individual options can be set
	# per package

	package { "apt":
		name => [
			"apt",
			"apt-file",
			"python-software-properties",
		],
		require => [], # Prevent circular dependency (see Package above)
	}

	package { "acpi": }

	package { "bash":
		ensure => "latest",
	}

	package { "bash-completion":
		ensure => "latest",
	}

	package { "bzip2": }

	package { "curl": }

	package { "etckeeper": }

	package { "fail2ban": }

	package { "git":
		ensure => "latest",
	}

	package { "grep":
		name => [
			"grep",
			"ack-grep",
		],
	}

	package { "gzip": }

	package { "htop": }

	package { "iftop": }

	if ! defined( Package["iptables-persistent"] ){
		package { "iptables-persistent": }
	}

	package { "logwatch": }

	package { "make": }

	package { "mailutils": }

	package { "mercurial": }

	if $operatingsystem == "Ubuntu" {
		package { "mosh":
			ensure => "latest",
		}
	}

	package { "nmap": }

	package { "ntpdate": }

	if ! defined( Package["perl"] ){
		package { "perl": 
			ensure => "latest",
		 }
	}

	package { "puppet": }

	package { "pv": }

	if ! defined( Package["python"] ){
		package { "python":
			ensure => "latest",
		 }
	}

	if ! defined( Package["ruby"] ){
		package { "ruby": 
			ensure => "latest",
		 }
	}

	package { "rsync": }

	package { "ssh":
		name => [
			"openssh-client",
			"openssh-server",
		],
	}

	package { "sqlite3": }

	package { "sudo": }

	package { "tcpdump": }

	package { "tcsh": }

	package { "tmux":
		ensure => "latest",
	}

	package { "vim":
		ensure => "latest",
	}

	package { "wget": }

	package { "zsh": }

	# Service
	# ==========================================================================

	service { "puppet":
		ensure => running,
		enable => true,
		subscribe => [
			File["puppet"],
			Package["puppet"],
		],
	}

	service { "ssh":
		ensure => running,
		enable => true,
		pattern => "sshd",
		require => [
			Package["ssh"],
		],
	}

	# Host file entries
	# ==========================================================================

	# host { "localhost.localdomain":
	#	ensure => "present",
	#	target => "/etc/hosts",
	#	ip => "127.0.0.1",
	#	host_aliases => ["localhost","puppet"],
	# }

	if $puppetmaster_ip != "" {
		host { "puppet":
			ensure => "present",
			target => "/etc/hosts",
			ip => "$puppetmaster_ip",
			host_aliases => [ $puppetmaster_fqdn ],
		}
	}

	# Files
	# ==========================================================================
	# Note: the "files" dir is ommitted when using puppet:///.

	# Note about sudo:
	# Ubuntu relies on a "sudo" group instead of managing the /etc/sudoers
	# entry. Changes to the /etc/sudoers file still work, but the distro
	# preferred method would be to use puppet group {} declarations.
	#
	# Instead of adding a custom sudoers file as outlined below.
	# file { "/etc/sudoers":
	#	owner => "root",
	#	group => "root",
	#	mode => "0440",
	#	source => puppet:///modules/ubuntu/sudoers",
	#	require => Package["sudo"],
	# }

	file { "/etc/apt/sources.list":
		ensure => "present",
		source => $operatingsystem ? {
			Ubuntu => "puppet:///modules/core/apt/ubuntu.sources.list",
			Debian => "puppet:///modules/core/apt/debian.sources.list",
		},
		owner => "root",
		group => "root",
		mode => "0644",
		require => [
			Package["apt"],
		],
	}

	file { "/etc/ssh/sshd_config":
		ensure => "present",
		source => "puppet:///modules/core/ssh/sshd_config",
		owner => "root",
		group => "root",
		mode => "0640",
	}

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

	file { "puppet":
		path => "/etc/puppet/puppet.conf",
		ensure => "present",
		owner => "root",
		group => "root",
		mode => "0664",
		require => [
			Package["puppet"],
		],
	}

	file { "/etc/default/puppet":
		ensure => "present",
		source => "puppet:///modules/core/puppet/etc-default-puppet",
		owner => "root",
		group => "root",
		mode => "0644",
		require => [
			Package["puppet"],
		],
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

	# Execs
	# ==========================================================================

	exec { "ssh-service-restart":
		command => "service ssh restart",
		path => "/bin:/sbin:/usr/bin:/usr/sbin",
		user => "root",
		group => "root",
		refreshonly => "true",
		logoutput => "on_failure",
		subscribe => [
			File["/etc/ssh/sshd_config"],
		],
	}

	exec { "apt-get-update-after-adding-multiverse-source":
		command => "apt-get update",
		path => "/bin:/sbin:/usr/bin:/usr/sbin",
		user => "root",
		group => "root",
		refreshonly => "true",
		logoutput => "on_failure",
		subscribe => [
			File["/etc/apt/sources.list"],
		],
	}

	# Users
	# ==========================================================================

	# user { "daemon":
	#	home => "/sbin",
	#	password_min_age => "0",
	#	ensure => "present",
	#	uid => "2",
	#	shell => "/sbin/nologin",
	#	password_max_age => "99999",
	#	password => "*",
	#	gid => "2",
	#	groups => ["bin","daemon","adm","lp"],
	#	comment => "daemon"
	# }

	# Groups
	# ==========================================================================

	group { "sudo":
		ensure => "present",
	}

	if $operatingsystem == "Debian" {
		group { "admin":
			ensure => "present",
		}
	}

}
