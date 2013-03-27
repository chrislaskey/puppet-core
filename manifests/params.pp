class core::params{
	
	# Example
	# ==========================================================================
	# Params can be used to centralize OS checks. For example:
	# 
	# case $operatingsystem {
	#	Solaris: {
	#		$ssh_package_name = "openssh"
	#		# More variables here...
	#	}
	#	/(Ubuntu|Debian)/: {
	#		$ssh_package_name = "openssh-server"
	#	}
	#	/(CentOS|RedHat|Fedora)/: {
	#		$ssh_package_name = "openssh-server"
	#	}
	# }
	#
	# Then simply use $ssh_package_name variable in other classes:
	#
	# package { "ssh":
	#	name => $core::params::ssh_package_name,
	#	ensure => "installed",
	# }
	#
	# Notice the use of variable namespacing $ubuntu::params::varname
	
}
