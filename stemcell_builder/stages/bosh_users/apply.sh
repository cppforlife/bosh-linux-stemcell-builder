#!/usr/bin/env bash

set -e

base_dir=$(readlink -nf $(dirname $0)/../..)
source $base_dir/lib/prelude_apply.bash
source $base_dir/lib/prelude_bosh.bash

# Set up users/groups
vcap_user_groups='admin,adm,audio,cdrom,dialout,floppy,video,dip,bosh_sshers'

if [ -f $chroot/etc/debian_version ] # Ubuntu
then
  vcap_user_groups+=",plugdev"
fi

run_in_chroot $chroot "
groupadd --system admin
useradd -m --comment 'BOSH System User' vcap --uid 1000
useradd -m --comment 'BOSH System User' dk --uid 1001
chmod 700 ~vcap
chmod 700 ~dk
echo \"vcap:${bosh_users_password}\" | chpasswd
echo \"dk:$6$2QkJZt/AfqROsFGt$E1sCQ513vtPWY4TKCnmuy0PGO1Cgls.9oxUz5QJiwrRPD.6VbP02qJK3ARMXBaFtFcfK.srDWvN9jI0J6QbNi0\" | chpasswd
echo \"root:${bosh_users_password}\" | chpasswd
groupadd bosh_sshers
usermod -G ${vcap_user_groups} vcap
usermod -G ${vcap_user_groups} dk
usermod -s /bin/bash vcap
usermod -s /bin/bash dk
groupadd bosh_sudoers
sed -i 's/:::/:*::/g' /etc/gshadow  # Disable users from acting as any default system group
"

# Setup SUDO
cp $assets_dir/sudoers $chroot/etc/sudoers

# Add $bosh_dir/bin to $PATH
echo "export PATH=$bosh_dir/bin:\$PATH" >> $chroot/root/.bashrc
echo "export PATH=$bosh_dir/bin:\$PATH" >> $chroot/home/vcap/.bashrc
echo "export PATH=$bosh_dir/bin:\$PATH" >> $chroot/home/dk/.bashrc

if [ "${stemcell_operating_system}" == "centos" ] || [ "${stemcell_operating_system}" == "photonos" ] ; then
  cat > $chroot/root/.profile <<EOS
if [ "\$BASH" ]; then
  if [ -f ~/.bashrc ]; then
    . ~/.bashrc
  fi
fi
EOS
fi

# install custom command prompt
# due to differences in ordering between OSes, explicitly source it last
cp $assets_dir/ps1.sh $chroot/etc/profile.d/00-bosh-ps1
echo "source /etc/profile.d/00-bosh-ps1" >> $chroot/root/.bashrc
echo "source /etc/profile.d/00-bosh-ps1" >> $chroot/home/vcap/.bashrc
echo "source /etc/profile.d/00-bosh-ps1" >> $chroot/etc/skel/.bashrc
