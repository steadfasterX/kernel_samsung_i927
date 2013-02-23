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
#include <linux/gpuctl.h>

int set_gpu_freq;

/* sysfs interface */
static ssize_t set_gpu_freq_show(struct kobject *kobj, struct kobj_attribute *attr, char *buf)
{
return sprintf(buf, "%d\n", set_gpu_freq);
}

static ssize_t set_gpu_freq_store(struct kobject *kobj, struct kobj_attribute *attr, const char *buf, size_t count)
{
sscanf(buf, "%du", &set_gpu_freq);
return count;
}

static struct kobj_attribute set_gpu_freq_attribute =
__ATTR(set_gpu_freq, 0666, set_gpu_freq_show, set_gpu_freq_store);

static struct attribute *attrs[] = {
&set_gpu_freq_attribute.attr,
NULL,
};

static struct attribute_group attr_group = {
.attrs = attrs,
};

static struct kobject *set_gpu_freq_kobj;

int set_gpu_freq_init(void)
{
	int retval;

	set_gpu_freq = 0;

        set_gpu_freq_kobj = kobject_create_and_add("gpu_freq", kernel_kobj);
        if (!set_gpu_freq_kobj) {
                return -ENOMEM;
        }
        retval = sysfs_create_group(set_gpu_freq_kobj, &attr_group);
        if (retval)
                kobject_put(set_gpu_freq_kobj);
        return retval;
}
/* end sysfs interface */

void set_gpu_freq_exit(void)
{
	kobject_put(set_gpu_freq_kobj);
}

module_init(set_gpu_freq_init);
module_exit(set_gpu_freq_exit);
