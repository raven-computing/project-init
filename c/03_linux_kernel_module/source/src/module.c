${{VAR_COPYRIGHT_HEADER}}

/*
 * ${{VAR_PROJECT_NAME}}
 * ${{VAR_PROJECT_DESCRIPTION}}
 *
 * ${{VAR_KERNEL_MODULE_NAME}}.c - Example module description.
 *
 * What is the purpose of this module?
 */

#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/init.h>

MODULE_LICENSE("${{VAR_PROJECT_LICENSE}}");
MODULE_AUTHOR("${{VAR_PROJECT_ORGANISATION_NAME}}");
MODULE_DESCRIPTION("${{VAR_PROJECT_DESCRIPTION}}");

static int __init init_${{VAR_KERNEL_MODULE_NAME}}_mod(void){
    pr_info("${{VAR_PROJECT_SLOGAN_STRING}}\n");
    return 0;
}

static void __exit cleanup_${{VAR_KERNEL_MODULE_NAME}}_mod(void){
    pr_info("Module ${{VAR_KERNEL_MODULE_NAME}} uninstalled\n");
}

module_init(init_${{VAR_KERNEL_MODULE_NAME}}_mod);
module_exit(cleanup_${{VAR_KERNEL_MODULE_NAME}}_mod);
