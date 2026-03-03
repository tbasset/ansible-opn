# vars

#wgetopt="-q -c --show-progress --progress=bar:force:noscroll --bind-address=172.28.236.2"
wgetopt="-q -c --show-progress --progress=bar:force:noscroll --bind-address=192.168.133.247"

# Glance upload images

#VERSION=$(curl -s http://download.cirros-cloud.net/version/released)
#wget $wgetopt http://download.cirros-cloud.net/$VERSION/cirros-$VERSION-x86_64-disk.img
# openstack image create --container-format bare --disk-format qcow2 --file ./cirros-$VERSION-x86_64-disk.img \
#  Cirros

#wget $wgetopt http://download.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud.latest.x86_64.qcow2
# openstack image create --container-format bare --disk-format qcow2 --file ./Rocky-9-GenericCloud.latest.x86_64.qcow2 \
#   --property hw_disk_bus=scsi \
#   --property hw_scsi_model=virtio-scsi \
#   --property hw_qemu_guest_agent=yes \
#   Rocky-Linux-9

#wget $wgetopt https://download.rockylinux.org/pub/rocky/8/images/Rocky-8-GenericCloud.latest.x86_64.qcow2
# openstack image create --container-format bare --disk-format qcow2 --file ./Rocky-8-GenericCloud.latest.x86_64.qcow2 \
#   --property hw_disk_bus=scsi \
#   --property hw_scsi_model=virtio-scsi \
#   --property hw_qemu_guest_agent=yes \
#   Rocky-Linux-8

wget $wgetopt https://repo.almalinux.org/almalinux/9/cloud/x86_64/images/AlmaLinux-9-GenericCloud-latest.x86_64.qcow2
# openstack image create --container-format bare --disk-format qcow2 --file ./AlmaLinux-9-GenericCloud-latest.x86_64.qcow2 \
#   --property hw_disk_bus=scsi \
#   --property hw_scsi_model=virtio-scsi \
#   --property hw_qemu_guest_agent=yes \
#   AlmaLinux-9

wget $wgetopt https://repo.almalinux.org/almalinux/8/cloud/x86_64/images/AlmaLinux-8-GenericCloud-latest.x86_64.qcow2
# openstack image create --container-format bare --disk-format qcow2 --file ./AlmaLinux-8-GenericCloud-latest.x86_64.qcow2 \
#   --property hw_disk_bus=scsi \
#   --property hw_scsi_model=virtio-scsi \
#   --property hw_qemu_guest_agent=yes \
# AlmaLinux-8

wget $wgetopt https://download.fedoraproject.org/pub/fedora/linux/releases/39/Cloud/x86_64/images/Fedora-Cloud-Base-39-1.5.x86_64.qcow2
# openstack image create --container-format bare --disk-format qcow2 --file ./Fedora-Cloud-Base-39-1.5.x86_64.qcow2 \
#   --property hw_disk_bus=scsi \
#   --property hw_scsi_model=virtio-scsi \
#   --property hw_qemu_guest_agent=yes \
# Fedora-39

wget $wgetopt https://cloud.centos.org/centos/8-stream/x86_64/images/CentOS-Stream-GenericCloud-8-latest.x86_64.qcow2
# glance image-create --name CentOS-Stream-8 --container-format bare --disk-format qcow2 --file ./CentOS-Stream-GenericCloud-8-latest.x86_64.qcow2

wget $wgetopt https://cloud.centos.org/centos/9-stream/x86_64/images/CentOS-Stream-GenericCloud-9-latest.x86_64.qcow2
# glance image-create --name CentOS-Stream-9 --container-format bare --disk-format qcow2 --file ./CentOS-Stream-GenericCloud-9-latest.x86_64.qcow2

wget $wgetopt http://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2
# glance image-create --name CentOS-7 --container-format bare --disk-format qcow2 --file ./CentOS-7-x86_64-GenericCloud.qcow2

wget $wgetopt http://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
# glance image-create --name Ubuntu-22.04 --container-format bare --disk-format qcow2 --file ./jammy-server-cloudimg-amd64.img

wget $wgetopt http://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img
# glance image-create --name Ubuntu-20.04 --container-format bare --disk-format qcow2 --file ./focal-server-cloudimg-amd64.img

wget $wgetopt http://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img
# glance image-create --name Ubuntu-18.04 --container-format bare --disk-format qcow2 --file ./bionic-server-cloudimg-amd64.img
 
wget $wgetopt https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2
# glance image-create --name Debian-12 --container-format bare --disk-format qcow2 --file ./debian-12-generic-amd64.qcow2    

wget $wgetopt https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-generic-amd64.qcow2
# glance image-create --name Debian-11 --container-format bare --disk-format qcow2 --file debian-11-generic-amd64.qcow2

wget $wgetopt https://cloud.debian.org/images/cloud/buster/latest/debian-10-generic-amd64.qcow2
# glance image-create --name Debian-10 --container-format bare --disk-format qcow2 --file debian-10-generic-amd64.qcow2

wget $wgetopt http://cdimage.debian.org/cdimage/openstack/current-9/debian-9-openstack-amd64.qcow2
# glance image-create --name Debian-9 --container-format bare --disk-format qcow2 --file debian-9-openstack-amd64.qcow2

wget $wgetopt https://stable.release.core-os.net/amd64-usr/current/coreos_production_openstack_image.img.bz2
# bunzip2 coreos_production_openstack_image.img.bz2
# openstack image create --container-format bare --disk-format qcow2 --property os_distro=coreos --file coreos_production_openstack_image.img \
#  CoreOS

wget $wgetopt https://linuximages.de/openstack/arch/arch-openstack-LATEST-image-bootstrap.qcow2
# openstack image create --container-format bare --disk-format qcow2 --file arch-openstack-LATEST-image-bootstrap.qcow2 \
#  Arch-Linux

wget $wgetopt https://linuximages.de/openstack/gentoo/gentoo-openstack-LATEST-image-bootstrap.qcow2
# openstack image create --container-format bare --disk-format qcow2 --file gentoo-openstack-LATEST-image-bootstrap.qcow2 \
#  Gentoo

wget $wgetopt https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_openstack_image.img.bz2
# bunzip2 flatcar_production_openstack_image.img.bz2
# openstack image create --public --container-format bare --disk-format qcow2 --file flatcar_production_openstack_image.img \
#  Flatcar-Container-Linux

# # Download image from https://cloudbase.it/windows-cloud-images/#download
# gunzip -cd windows_server_2012_r2_standard_eval_kvm_20170321.qcow2.gz
# openstack image create --container-format bare --disk-format qcow2 --file windows_server_2012_r2_standard_eval_kvm_20170321.qcow2 \
#  Windows-Server-2012-R2-Std

wget $wgetopt https://download.freebsd.org/ftp/releases/VM-IMAGES/13.2-RELEASE/amd64/Latest/FreeBSD-13.2-RELEASE-amd64.qcow2.xz
# unxz FreeBSD-13.2-RELEASE-amd64.qcow2.xz
# openstack image create --container-format bare --disk-format qcow2 --file FreeBSD-13.2-RELEASE-amd64.qcow2 \
#  FreeBSD-13

wget $wgetopt https://download.freebsd.org/ftp/releases/VM-IMAGES/12.4-RELEASE/amd64/Latest/FreeBSD-12.4-RELEASE-amd64.qcow2.xz
# unxz FreeBSD-12.4-RELEASE-amd64.qcow2.xz
# openstack image create --container-format bare --disk-format qcow2 --file FreeBSD-12.4-RELEASE-amd64.qcow2 \
#  FreeBSD-12

# openstack image list

# IMAGE_IDS=`openstack image list | egrep '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}' -o`
# for i in ${IMAGE_IDS[@]}; do
#     openstack image set --public $i
#     openstack image set --protected $i
# done

