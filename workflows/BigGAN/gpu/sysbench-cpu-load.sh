#!/bin/bash

for i in {1..100}
do
	sysbench --test=cpu --cpu-max-prime=20000 --num-threads=64 run 
done