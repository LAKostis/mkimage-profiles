use/server: sub/rootfs use/services
	@$(call add_feature)

use/server/base: use/server use/firmware/server \
	use/net-ssh use/syslinux/timeout/600 use/grub/timeout/60
	@$(call set,BOOTVGA,)
	@$(call add,THE_LISTS,server-base)
	@$(call add,THE_KMODULES,e1000e igb)
	@$(call add,STAGE1_KMODULES,e1000e)
	@$(call add,INSTALL2_PACKAGES,installer-feature-server-raid-fixup-stage2)

use/server/mini: use/server/base use/services/lvm2-disable
	@$(call add,THE_LISTS,\
		$(call tags,base && (network || security || pkg)))
	@$(call add,THE_LISTS,$(call tags,extra && (server || network)))
	@$(call add,MAIN_LISTS,osec)
	@$(call add,DEFAULT_SERVICES_DISABLE,messagebus)

use/server/ovz-base: use/server
	@$(call set,STAGE1_KFLAVOURS,std-def)
	@$(call set,KFLAVOURS,std-def ovz-el)
	@$(call add,BASE_PACKAGES,lftp wget hdparm)
	@$(call add,BASE_LISTS,$(call tags,base openvz))

use/server/ovz: use/server/ovz-base
	@$(call add,MAIN_KMODULES,ipset ipt-netflow)
	@$(call add,MAIN_KMODULES,xtables-addons)	# t6/branch
	@$(call add,MAIN_KMODULES,drbd9 kvm)
	@$(call add,MAIN_KMODULES,staging)
	@$(call add,BASE_LISTS,$(call tags,server openvz))

use/server/virt: use/server use/kernel
	@$(call add,BASE_PACKAGES,openssh)
	@$(call set,STAGE1_KFLAVOURS,std-def)
	@$(call set,KFLAVOURS,std-def)
	@$(call add,THE_KMODULES,kvm)

# NB: examine zabbix-preinstall package, initialization is NOT automatic!
use/server/zabbix: use/server use/services use/control
	@$(call add,THE_LISTS,$(call tags,server zabbix))
	@$(call add,DEFAULT_SERVICES_ENABLE,zabbix_mysql zabbix_agentd)
	@$(call add,DEFAULT_SERVICES_ENABLE,httpd2 mysqld postfix)
	@$(call add,CONTROL,postfix:server)

use/server/groups/tools: use/server
	@$(call add,MAIN_GROUPS,tools/diag tools/ipmi tools/monitoring)
	@$(call add,MAIN_GROUPS,tools/tuning)

use/server/groups/services: use/server
	@$(call add,BASE_KMODULES,kvm)
	@$(call add,MAIN_GROUPS,server/dhcp server/dns server/mail)
	@$(call add,MAIN_GROUPS,server/apache2 server/nginx)
	@$(call add,MAIN_GROUPS,server/mariadb server/pgsql)
	@$(call add,MAIN_GROUPS,server/php7)
	@$(call add,MAIN_GROUPS,server/ftp server/rsync)
	@$(call add,MAIN_GROUPS,server/kvm)
	@$(call add,DEFAULT_SERVICES_ENABLE,libvirtd)
	@$(call add,DEFAULT_SERVICES_DISABLE,php7-fpm)

use/server/groups/base: use/server/groups/tools use/server/groups/services; @:
