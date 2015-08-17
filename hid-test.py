#!/usr/bin/env python

import hidapi
import binascii
import time

hidapi.hid_init()
    
print 'Loaded hidapi library from: {:s}\n'.format(hidapi.hid_lib_path())

devices = hidapi.hid_enumerate(0x0483, 0x5750)
if len(devices) == 0:
    print "No dev attached"
    exit(1)

device = hidapi.hid_open(0x0483, 0x5750)


import random
while True:
    result = hidapi.hid_read(device, 4)
    state = binascii.hexlify(result)
    print "#%d: %s"  % (len(result), state)

hidapi.hid_close(device)
