#!/usr/bin/python
import sys
import os
import shutil

cwl_build_path = sys.argv[1]
cwl_setup_path = sys.argv[2]
if not os.path.isdir(cwl_build_path):
	print "Error "+cwl_setup_path + " is not a valid path"
if not os.path.isdir(cwl_setup_path):
	print "Error "+cwl_build_path + " is not a valid path"
program_name_dirs = os.listdir(cwl_build_path)
for single_program_name_dir in program_name_dirs:	
	program_name_path = os.path.join(cwl_build_path,single_program_name_dir)
	if not os.path.isdir(program_name_path):
		continue
	program_version_dirs = os.listdir(program_name_path)
	for single_program_version_dir in program_version_dirs:
		program_version_path = os.path.join(program_name_path,single_program_version_dir)
		if not os.path.isdir(program_version_path):
			continue
		program_cwl_files = os.listdir(program_version_path)
		for single_program_cwl_file in program_cwl_files:
			program_cwl_path = os.path.join(program_version_path,single_program_cwl_file)
			if not os.path.isfile(program_cwl_path):
				continue
			cwl_setup_name_output = os.path.join(cwl_setup_path,single_program_name_dir)
			cwl_setup_version_output = os.path.join(cwl_setup_name_output,single_program_version_dir)
			if os.path.isdir(cwl_setup_version_output):
				shutil.rmtree(cwl_setup_version_output)
			elif not os.path.isdir(cwl_setup_name_output):
				os.makedirs(cwl_setup_name_output)
			os.makedirs(cwl_setup_version_output)
			cwl_output_file_path = os.path.join(cwl_setup_version_output,single_program_cwl_file)
			shutil.copyfile(program_cwl_path,cwl_output_file_path)