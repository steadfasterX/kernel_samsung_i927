/*
 * Author: Chad Froebel <chadfroebel@gmail.com>
 *
 * This software is licensed under the terms of the GNU General Public
 * License version 2, as published by the Free Software Foundation, and
 * may be copied, distributed, and modified under those terms.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 */

#include <linux/kobject.h>
#include <linux/sysfs.h>
#include <linux/cpuoc.h>

int cpu_overclock;

/* sysfs interface */
static ssize_t cpu_overclock_show(struct kobject *kobj, struct kobj_attribute *attr, char *buf)
{
return sprintf(buf, "%d\n", cpu_overclock);
}

static ssize_t cpu_overclock_store(struct kobject *kobj, struct kobj_attribute *attr, const char *buf, size_t count)
{
sscanf(buf, "%du", &cpu_overclock);
return count;
}

static struct kobj_attribute cpu_overclock_attribute =
__ATTR(cpu_overclock, 0666, cpu_overclock_show, cpu_overclock_store);

static struct attribute *attrs[] = {
&cpu_overclock_attribute.attr,
NULL,
};

static struct attribute_group attr_group = {
.attrs = attrs,
};

static struct kobject *cpu_overclock_kobj;

int cpu_overclock_init(void)
{
	int retval;

	

        cpu_overclock_kobj = kobject_create_and_add("cpu_oc", kernel_kobj);
        if (!cpu_overclock_kobj) {
                return -ENOMEM;
        }
        retval = sysfs_create_group(cpu_overclock_kobj, &attr_group);
        if (retval)
                kobject_put(cpu_overclock_kobj);
        return retval;
	cpu_overclock = retval;
}
/* end sysfs interface */

void cpu_overclock_exit(void)
{
	kobject_put(cpu_overclock_kobj);
}

module_init(cpu_overclock_init);
module_exit(cpu_overclock_exit);
