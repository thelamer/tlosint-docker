#! /bin/bash
/usr/bin/apt list --installed 2>/dev/null | grep -v 'Listing...' | sort
