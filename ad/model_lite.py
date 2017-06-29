#!/usr/bin/python
import sys

lite_model = open(sys.argv[2], 'w')
for line in open(sys.argv[1], 'r'):
	if not line:
                break
        else:
		if line.split('\t')[1] != '0':
			lite_model.write(line)

lite_model.close()
		

                
	
