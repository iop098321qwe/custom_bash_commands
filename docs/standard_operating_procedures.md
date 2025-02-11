# Standard Operating Procedures (SOPs)

## Table of Contents

1. [Introduction](#introduction)
2. [Creating New Functions](#creating-new-functions)
3. [Creating New Aliases](#creating-new-aliases)
4. [Testing](#testing)

## Introduction

This document is a guide on how to create new functions and aliases for the custom bash commands script. It will also cover how to test the new functions and aliases to ensure they work as intended.

## Creating New Functions

To create a new function, you will need to add the function to the `custom_bash_commands.sh` script. The function should be added to the end of the script and should be formatted as follows:

```bash
###################################################################################################################################################################
# Function Name
###################################################################################################################################################################

function function_name() {
    # Function description here
    # Function -h help flag description here
    # Function -h help flag code here
    # Function code herec
}
```

The function should be included near relevant functions, and contain commented sections to separate the code from the rest of the script. The function should also include a description of what it does and a help flag description and code for the `-h` flag.

1. Create a new function in the `custom_bash_commands.sh` script.
2. Ensure that a -h help flag is included in the function.
3. Add a description of the function to the script.
4. Add the function to the cbcs command list in the `custom_bash_commands.sh` script.
5. Add the function to the cbcs -h help flag list in the `custom_bash_commands.sh` script.
6. Include a section in the Wiki for the new function with a description and usage instructions.
7. Update the script using the `updatecommands` or `ucbc` command.
8. Test the new function to ensure it works as intended.

## Creating New Aliases

To create a new alias, you will need to add the alias to the `custom_bash_commands.sh` script. The alias should be added to the end of the script and should be formatted as follows:

```bash
 alias alias_name='alias_command'
```

* This alias should be added under the section titled `# Aliases` in the script.
* The alias should be included near relevant aliases.

1. Create a new alias in the `custom_bash_commands.sh` script.
2. Add the alias to the cbcs command list in the `custom_bash_commands.sh` script.
3. Add the alias to the cbcs -h help flag list in the `custom_bash_commands.sh` script.
4. Include a section in the Wiki for the new alias with a description and usage instructions.
5. Update the script using the `updatecommands` or `ucbc` command.
6. Test the new alias to ensure it works as intended.

## Testing

To test the new functions, write a secondary temporary script to test the new alias/function. This script should include the new alias/function and any necessary test cases. Run the script to ensure the new alias/function works as intended.

1. Create a new test script to test the new alias/function.
2. Include the new alias/function in the test script.
3. Add any necessary test cases to the script.
4. Run the test script to ensure the new alias/function works as intended.
5. Make any necessary adjustments to the new alias/function based on the test results.
6. Update the custom_bash_commands.sh script after making any changes.
7. Update the Github repository with the new changes.
8. Update the Wiki with any new information on the alias/function.
9. Run the `updatecommands` or `ucbc` command to update the script.
