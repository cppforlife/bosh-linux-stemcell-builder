#!/usr/bin/env bash

set -e

base_dir=$(readlink -nf $(dirname $0)/../..)
source $base_dir/lib/prelude_apply.bash

if [ "${stemcell_operating_system_version}" != "xenial" ]; then
	run_in_chroot $chroot "
		/usr/sbin/usermod -L libuuid
		/usr/sbin/usermod -s /usr/sbin/nologin libuuid
	"
fi
