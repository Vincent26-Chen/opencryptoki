#!/bin/bash
#
# COPYRIGHT (c) International Business Machines Corp. 2008-2017
#
# This program is provided under the terms of the Common Public License,
# version 1.0 (CPL-1.0). Any use, reproduction or distribution for this software
# constitutes recipient's acceptance of CPL-1.0 terms which can be found
# in the file LICENSE file or at https://opensource.org/licenses/cpl1.0.php
#
#
# NAME
#	ocktests.sh
#
# DESCRIPTION
#	Simple Bash script that checks the enviroment in which the ock-tests will run
#	and starts them.
#
# ALGORITHM
#	None.
#
# USAGE
#
# HISTORY
#	Rajiv Andrade <srajiv@linux.vnet.ibm.com>
#
# RESTRICTIONS
#	None.
##

LOGGING=0
TESTDIR=`dirname $0`
LOGFILE="$TESTDIR/ock-tests.log"
ERR_SUMMARY="$TESTDIR/ock-tests.err"
PKCONF="/usr/local/etc/opencryptoki/opencryptoki.conf"
PKCSCONFBIN="/usr/local/sbin/pkcsconf"
TESTCONF="$TESTDIR/ock-tests.config"
TOKTYPE=""
NONEED_TOKEN_INIT=0

#
# This is the list of the tests we'll be running once everything is initialized
#
# The order of these tests matters. login/login leaves the token with its USER
# PIN locked, leaving the token unusable until someone manually deletes
# $OCKDIR/$TOKEN/*. Manually deleting this dir is pre-req for starting the
# automated tests anyway, so this is OK.
#
# login/login MUST come last if it appears in this list
#
OCK_TESTS="crypto/*tests"
OCK_TESTS+=" pkcs11/attribute pkcs11/copyobjects pkcs11/destroyobjects"
OCK_TESTS+=" pkcs11/findobjects pkcs11/generate_keypair"
OCK_TESTS+=" pkcs11/get_interface pkcs11/getobjectsize"
#OCK_TESTS+=" misc_tests/fork"
OCK_TESTS+=" misc_tests/obj_mgmt_tests"
OCK_TESTS+=" misc_tests/obj_mgmt_lock_tests misc_tests/reencrypt"
OCK_TEST=""
OCK_BENCHS="pkcs11/*bench"


###
## run_tests() - run tests for a specific slot,
##               following $OCK_TEST order
## $1 - the slot
###
run_tests()
{
    echo "***** Will run the following tests for slot $1: $(ls -U $OCK_TESTS)"
    for j in $( ls -U $OCK_TESTS ); do
        echo "** Now executing '$j'"
        $j -slot $1 $NO_STOP 2>&1
        RES=$?
		if [ $RES -ne 0 ]; then
			echo "ERROR: Testcase $j failed to execute."
			#exit $RES
		fi
    done
}

###
## run_benchs() - run benchmarks for a specific slot,
##                following $OCK_BENCH order
## $1 - the slot
###
run_benchs()
{
    echo "***** Will run the following benchmarks for slot $1: $(ls -U $OCK_BENCHS)"
    for i in $( ls -U $OCK_BENCHS ); do
        echo "** Now executing '$i"
        $i -slot $1 $NO_STOP 2>&1
    done
}

while getopts s:f:l:hc:n arg; do
    case $arg in
        n)
            NO_STOP="-nostop"
            ;;
    esac
done

run_tests 0

exit 0
