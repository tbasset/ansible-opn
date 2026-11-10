#!/bin/bash

ssh $1 -t "watch -n5 virsh list --all --table --title"
