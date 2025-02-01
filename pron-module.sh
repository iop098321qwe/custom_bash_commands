#!/usr/bin/env bash

# This script will contain all of the logic associated with the pron module.
# It should be sourced by the main script if the pron module is enabled.
#
# Part of this should also include building a module system for the CBC script.
# This will allow for the easy addition of new modules in the future.
# Potentially, some of the functions that are already written into the main CBC script should be moved here.
#
# Potential other modules:
# * cbc-pron
#   - this will contain all of the logic for the personal pron module
# * cbc-git
#   - this will contain all of the logic for the git shortcuts module
# * cbc-sorting
#   - this will contain all of the logic for the file sorting module
# * cbc-install
#   - this will contain all of the logic for the software quick-installation module
#
# Some of the functions that are currently in the main script that should be moved here:
#
# * pron
# * pronlist
# * uml
# * phopen
# * phsearch
#
# MANY MORE TO BE ADDED
#
# Consider writing multi-stage functions for the pron module, such as:
#
# * ph open
# * ph search
# * ph list

# Functions

# Aliases
