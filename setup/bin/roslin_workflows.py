#!/usr/bin/env python3

import os, sys
from builtins import super

ROSLIN_CORE_BIN_PATH = os.environ['ROSLIN_CORE_BIN_PATH']
sys.path.append(ROSLIN_CORE_BIN_PATH)

from track_utils import log, RoslinWorkflow, SingleCWLWorkflow
from core_utils  import run_command_realtime, add_record_argument
import copy
import dill
import glob

def get_varriant_workflow_outputs(output_config, workflow_output_path):
	output_config["bam"] = [{"patterns": ["*.bam","*.bai"], "input_folder": workflow_output_path}]
	output_config["vcf"] = [{"patterns": ["*.vcf","*.norm.vcf.gz","*.norm.vcf.gz.tbi","*.mutect.txt","*.combined-variants.vcf.gz","*.combined-variants.vcf.gz.tbi"], "input_folder": workflow_output_path}]
	output_config["maf"] = [{"patterns": ["*.maf","*.portal.txt"], "input_folder": workflow_output_path}]
	output_config["qc"] =  [{"patterns": ["*_QC_Report.pdf","consolidated_metrics_data/*"], "input_folder": workflow_output_path}]
	output_config["facets"] = [{"patterns": ["*_hisens.CNCF.png","*_hisens.cncf.txt","*_hisens.out","*_hisens.Rdata","*_hisens.seg","*_purity.CNCF.png","*_purity.cncf.txt","*_purity.out","*_purity.Rdata","*_purity.seg","*dat.gz"], "input_folder": workflow_output_path}]
	return output_config

#-------------------- Workflows --------------------

class VariantWorkflow(SingleCWLWorkflow):

	def configure(self):
		super().configure('VariantWorkflow','','project-workflow.cwl',[],[])

	def configure_sv(self):
		super().configure('VariantWorkflowSV','','project-workflow-sv.cwl',[],[])

	def get_outputs(self,workflow_output_folder):
		workflow_output_path = os.path.join("outputs",workflow_output_folder)
		output_config = super().get_outputs(workflow_output_folder)
		output_config = get_varriant_workflow_outputs(output_config, workflow_output_path)
		return output_config

	def run_pipeline(self):
		return super().run_pipeline(run_analysis=True)


class VariantWorkflowSV(VariantWorkflow):

	def configure(self):
		super().configure_sv()

class SampleWorkflow(SingleCWLWorkflow):

	def configure(self):
		super().configure('SampleWorkflow','workflows','sample-workflow.cwl',[],[])

	def configure_pdx(self):
		super().configure('SampleWorkflowPDX','workflows','sample-workflow.cwl',[],[])

	def configure_bam(self):
		super().configure('SampleWorkflowBAM','workflows','sample-workflow.cwl',[],[])

	def get_inputs(self,single_dependency_list,multi_dependency_list):
		requirement_list, dependency_key_list = super().get_inputs(single_dependency_list,multi_dependency_list)
		sample_number = self.add_sample_or_pair_argument("sample")
		pair_number = self.add_sample_or_pair_argument("pair")
		batch_argument = self.add_batch_argument()
		requirement_list.extend([pair_number, sample_number,batch_argument])
		dependency_key_list.extend([pair_number[2],sample_number[2],batch_argument[2]])
		return (requirement_list, dependency_key_list)

	def modify_dependency_inputs(self,roslin_yaml,job_params):
		params = self.params
		requirements = params['requirements']
		logger = dill.loads(params['logger'])
		dependency_input =  copy.deepcopy(roslin_yaml)
		sample_input = self.input_sample_or_pair(["sample","pair","pairs"],job_params,roslin_yaml)
		dependency_input['sample'] = sample_input
		runparams_inputs = add_record_argument(roslin_yaml['runparams'],["genome","tmp_dir","opt_dup_pix_dist","gatk_jar_path","intervals"])
		db_files_inputs = add_record_argument(roslin_yaml['db_files'],["bait_intervals","target_intervals","fp_intervals","conpair_markers_bed"])
		dependency_input.update(runparams_inputs)
		dependency_input.update(db_files_inputs)
		return dependency_input

	def get_outputs(self,workflow_output_folder):
		workflow_output_path = os.path.join("outputs",workflow_output_folder)
		output_config = super().get_outputs(workflow_output_folder)
		output_config["bam"] = [{"patterns": ["*.bam","*.bai"], "input_folder": workflow_output_path}]
		output_config["qc"] = [{"patterns": ["*metrics","*.txt","*.pdf","*.summary"], "input_folder": workflow_output_path}]
		return output_config

class SampleWorkflowPDX(SampleWorkflow):

	def configure(self):
		super().configure_pdx()

	def modify_test_files(self,mpgr_output_path):
		clinical_file_glob = os.path.join(mpgr_output_path,'*_clinical.txt')
		clinical_file_list = glob.glob(clinical_file_glob)
		clinical_file_data = []
		pdx_cols_to_check = ['SAMPLE_CLASS', 'SAMPLE_TYPE']
		pdx_col_num = None
		clinical_file_str = None
		if clinical_file_list:
			clinical_file_path = clinical_file_list[0]
			if os.path.exists(clinical_file_path):
				with open(clinical_file_path,"r") as clinical_file:
					header = clinical_file.readline().strip().split("\t")
					for single_col in pdx_cols_to_check:
						if single_col in header and pdx_col_num == None:
							pdx_col_num = header.index(single_col)
					if pdx_col_num != None:
						clinical_file_header = "\t".join(header)
						clinical_file_data.append(clinical_file_header)
						for single_line in clinical_file:
							single_sample = single_line.strip().split("\t")
							single_sample[pdx_col_num] = 'pdx'
							single_sample_line = "\t".join(single_sample)
							clinical_file_data.append(single_sample_line)
				clinical_file_str = "\n".join(clinical_file_data)
			if clinical_file_str:
				with open(clinical_file_path,"w") as clinical_file:
					clinical_file.write(clinical_file_str)

class SampleWorkflowBAM(SampleWorkflow):

	def configure(self):
		super().configure_bam()

	def modify_test_files(self,mpgr_output_path):
		mapping_file_glob = os.path.join(mpgr_output_path,'*_mapping.txt')
		mapping_file_list = glob.glob(mapping_file_glob)
		mapping_file_data = []
		mapping_file_dict = {}
		bam_list = []
		workspace_path = os.environ['ROSLIN_PIPELINE_WORKSPACE_PATH']
		test_data_path = os.path.join(workspace_path,'test_data')
		if mapping_file_list:
			mapping_file_path = mapping_file_list[0]
			if os.path.exists(mapping_file_path):
				with open(mapping_file_path,"r") as mapping_file:
					for single_line in mapping_file:
						singe_fastq = single_line.strip().split("\t")
						fastq_name = singe_fastq[1]
						bam_file_name = fastq_name + ".rg.md.bam"
						bam_list.append(bam_file_name)
						mapping_file_dict[bam_file_name] = singe_fastq
				for root, dirnames, filenames in os.walk(test_data_path):
					for single_file in filenames:
						if single_file in bam_list:
							single_bam = mapping_file_dict[single_file]
							single_bam_path = os.path.join(root,single_file)
							single_bam[3] = single_bam_path
							single_bam_line = "\t".join(single_bam)
							mapping_file_data.append(single_bam_line)
							bam_list.remove(single_file)
							del mapping_file_dict[single_file]
				for single_fastq_key in mapping_file_dict:
					singe_fastq = mapping_file_dict[single_fastq_key]
					single_fastq_line = "\t".join(single_fastq)
					mapping_file_data.append(single_fastq_line)
				mapping_file_str = "\n".join(mapping_file_data)
				with open(mapping_file_path,"w") as mapping_file:
					mapping_file.write(mapping_file_str)

class PairWorkflow(SingleCWLWorkflow):

	def configure(self):
		super().configure('PairWorkflow','workflows','pair-workflow.cwl',[],[])

	def configure_sv(self):
		super().configure('PairWorkflowSV','workflows','pair-workflow-sv.cwl',[],[])

	def get_inputs(self,single_dependency_list,multi_dependency_list):
		requirement_list, dependency_key_list = super().get_inputs(single_dependency_list,multi_dependency_list)
		pair_number = self.add_sample_or_pair_argument("pair")
		batch_argument = self.add_batch_argument()
		requirement_list.extend([pair_number,batch_argument])
		dependency_key_list.extend([pair_number[2],batch_argument[2]])
		return (requirement_list, dependency_key_list)

	def modify_dependency_inputs(self,roslin_yaml,job_params):
		params = self.params
		requirements = params['requirements']
		logger = dill.loads(params['logger'])
		dependency_input =  copy.deepcopy(roslin_yaml)
		pair_input = self.input_sample_or_pair([None,"pair","pairs"],job_params,roslin_yaml)
		dependency_input = copy.deepcopy(roslin_yaml)
		dependency_input['pair'] = pair_input
		return dependency_input

	def get_outputs(self,workflow_output_folder):
		workflow_output_path = os.path.join("outputs",workflow_output_folder)
		output_config = super().get_outputs(workflow_output_folder)
		output_config = get_varriant_workflow_outputs(output_config, workflow_output_path)
		return output_config


class PairWorkflowSV(PairWorkflow):

	def configure(self):
		super().configure_sv()

#-------------------- Modules --------------------

class Alignment(SingleCWLWorkflow):

	def configure(self):
		super().configure('Alignment','modules/pair','alignment-pair.cwl',[],[])

	def get_inputs(self,single_dependency_list,multi_dependency_list):
		requirement_list, dependency_key_list = super().get_inputs(single_dependency_list,multi_dependency_list)
		pair_number = self.add_sample_or_pair_argument("pair")
		batch_argument = self.add_batch_argument()
		requirement_list.extend([pair_number,batch_argument])
		dependency_key_list.extend([pair_number[2],batch_argument[2]])
		return (requirement_list, dependency_key_list)

	def modify_dependency_inputs(self,roslin_yaml,job_params):
		params = self.params
		dependency_input =  copy.deepcopy(roslin_yaml)
		dependency_input['pair'] = self.input_sample_or_pair([None,"pair","pairs"],job_params,roslin_yaml)
		runparams_inputs = add_record_argument(roslin_yaml['runparams'],["genome","tmp_dir","opt_dup_pix_dist","covariates","abra_scratch","abra_ram_min","gatk_jar_path","intervals"])
		db_files_inputs = add_record_argument(roslin_yaml['db_files'],["bait_intervals","target_intervals","fp_intervals","conpair_markers_bed"])
		dependency_input.update(runparams_inputs)
		dependency_input.update(db_files_inputs)
		return dependency_input

	def get_outputs(self,workflow_output_folder):
		workflow_output_path = os.path.join("outputs",workflow_output_folder)
		output_config = super().get_outputs(workflow_output_folder)
		output_config["bam"] = [{"patterns": ["*.bam","*.bai"], "input_folder": workflow_output_path}]
		output_config["qc"] = [{"patterns": ["*metrics","*.txt","*.pdf","*.summary"], "input_folder": workflow_output_path}]
		return output_config

class GatherMetrics(SingleCWLWorkflow):

	def configure(self):
		super().configure('GatherMetrics','modules/sample','gather-metrics-sample.cwl',['Alignment'],[])

	def get_inputs(self,single_dependency_list,multi_dependency_list):
		requirement_list, dependency_key_list = super().get_inputs(single_dependency_list,multi_dependency_list)
		sample_number = self.add_sample_or_pair_argument("sample")
		pair_number = self.add_sample_or_pair_argument("pair")
		batch_argument = self.add_batch_argument()
		requirement_list.extend([pair_number, sample_number,batch_argument])
		dependency_key_list.extend([pair_number[2],sample_number[2],batch_argument[2]])
		return (requirement_list, dependency_key_list)

	def get_outputs(self,workflow_output_folder):
		workflow_output_path = os.path.join("outputs",workflow_output_folder)
		output_config = super().get_outputs(workflow_output_folder)
		output_config["qc"] = [{"patterns": ["*metrics","*.txt","*.pdf","*.summary"], "input_folder": workflow_output_path}]
		return output_config

	def modify_dependency_inputs(self,roslin_yaml,job_params):
		params = self.params
		dependency_input = copy.deepcopy(roslin_yaml)
		dependency_input['bam'] = self.input_sample_or_pair(["bam","bams","bams"],job_params,roslin_yaml)
		runparams_inputs = add_record_argument(roslin_yaml['runparams'],["genome","tmp_dir","gatk_jar_path"])
		db_files_inputs = add_record_argument(roslin_yaml['db_files'],["bait_intervals","target_intervals","fp_intervals","conpair_markers_bed"])
		dependency_input.update(runparams_inputs)
		dependency_input.update(db_files_inputs)
		return dependency_input


class GenerateQc(SingleCWLWorkflow):

	def configure(self):
		super().configure('GenerateQc','modules/project','generate-qc.cwl',[],['PairWorkflow'])

	def configure_sv(self):
		super().configure('GenerateQc','modules/project','generate-qc.cwl',['CdnaContam'],['PairWorkflowSV'])

	def get_outputs(self,workflow_output_folder):
		workflow_output_path = os.path.join("outputs",workflow_output_folder)
		output_config = super().get_outputs(workflow_output_folder)
		consolidated_metrics_folder = os.path.join(workflow_output_path,"consolidated_metrics_data")
		output_config["qc"] = [{"patterns": ["*_QC_Report.pdf"], "input_folder": workflow_output_path},
							   {"patterns": ["*"], "input_folder": consolidated_metrics_folder,"output_folder":"consolidated_metrics_data"}]
		return output_config

	def modify_dependency_inputs(self,roslin_yaml,job_params):
		dependency_input = copy.deepcopy(roslin_yaml)
		dependency_input['files'] = []
		dependency_input['directories'] = []
		return dependency_input

class GenerateQcSV(GenerateQc):

	def configure(self):
		super().configure_sv()

	def modify_dependency_inputs(self,roslin_yaml,job_params):
		files = roslin_yaml['cdna_contam_output']
		dependency_input = copy.deepcopy(roslin_yaml)
		dependency_input['files'] = [files]
		dependency_input['directories'] = []
		return dependency_input

class MafProcessing(SingleCWLWorkflow):

	def configure(self):
		super().configure('MafProcessing','modules/pair','maf-processing-pair.cwl',['Alignment','VariantCalling'],[])

	def get_inputs(self,single_dependency_list,multi_dependency_list):
		requirement_list, dependency_key_list = super().get_inputs(single_dependency_list,multi_dependency_list)
		pair_number = self.add_sample_or_pair_argument("pair")
		batch_argument = self.add_batch_argument()
		requirement_list.extend([pair_number,batch_argument])
		dependency_key_list.extend([pair_number[2],batch_argument[2]])
		return (requirement_list, dependency_key_list)

	def get_outputs(self,workflow_output_folder):
		workflow_output_path = os.path.join("outputs",workflow_output_folder)
		output_config = super().get_outputs(workflow_output_folder)
		output_config["maf"] = [{"patterns": ["*.maf"], "input_folder": workflow_output_path}]
		return output_config

	def modify_dependency_inputs(self,roslin_yaml,job_params):
		params = self.params
		dependency_input = copy.deepcopy(roslin_yaml)
		dependency_input['bams'] = self.input_sample_or_pair([None,"bams","bams"],job_params,roslin_yaml)
		dependency_input['pair'] = self.input_sample_or_pair([None,"pair","pairs"],job_params,roslin_yaml)
		dependency_input['annotate_vcf'] = self.input_sample_or_pair(["annotate_vcf","annotate_vcf",None],job_params,roslin_yaml)
		dependency_input['normal_sample_name'] = dependency_input['pair'][1]['ID']
		dependency_input['tumor_sample_name'] = dependency_input['pair'][0]['ID']
		runparams_inputs = add_record_argument(roslin_yaml['runparams'],["genome","tmp_dir"])
		db_files_inputs = add_record_argument(roslin_yaml['db_files'],["vep_path","custom_enst","vep_data","hotspot_list","pairing_file"])
		dependency_input.update(runparams_inputs)
		dependency_input.update(db_files_inputs)
		return dependency_input

class Realignment(SingleCWLWorkflow):

	def configure(self):
		super().configure('Realignment','modules/pair','realignment.cwl',[],['SampleWorkflow'])

	def get_inputs(self,single_dependency_list,multi_dependency_list):
		requirement_list, dependency_key_list = super().get_inputs(single_dependency_list,multi_dependency_list)
		pair_number = self.add_sample_or_pair_argument("pair")
		batch_argument = self.add_batch_argument()
		requirement_list.extend([pair_number,batch_argument])
		dependency_key_list.extend([pair_number[2],batch_argument[2]])
		return (requirement_list, dependency_key_list)

	def modify_dependency_inputs(self,roslin_yaml,job_params):
		params = self.params
		dependency_input = copy.deepcopy(roslin_yaml)
		dependency_input['pair'] = self.input_sample_or_pair([None,"pair","pairs"],job_params,roslin_yaml)
		dependency_input['bams'] = self.input_sample_or_pair([None,"bam","bams"],job_params,roslin_yaml)
		runparams_inputs = add_record_argument(roslin_yaml['runparams'],["covariates","genome","tmp_dir","abra_scratch","abra_ram_min","intervals"])
		dependency_input.update(runparams_inputs)
		return dependency_input

	def get_outputs(self,workflow_output_folder):
		workflow_output_path = os.path.join("outputs",workflow_output_folder)
		output_config = super().get_outputs(workflow_output_folder)
		output_config["bam"] = [{"patterns": ["*.bam","*.bai"], "input_folder": workflow_output_path}]
		output_config["qc"] = [{"patterns": ["*metrics","*.txt","*.pdf","*.summary"], "input_folder": workflow_output_path}]
		return output_config

class StructuralVariants(SingleCWLWorkflow):

	def configure(self):
		super().configure('StructuralVariants','modules/pair','structural-variants-pair.cwl',['Alignment'],[])

	def get_inputs(self,single_dependency_list,multi_dependency_list):
		requirement_list, dependency_key_list = super().get_inputs(single_dependency_list,multi_dependency_list)
		pair_number = self.add_sample_or_pair_argument("pair")
		batch_argument = self.add_batch_argument()
		requirement_list.extend([pair_number,batch_argument])
		dependency_key_list.extend([pair_number[2],batch_argument[2]])
		return (requirement_list, dependency_key_list)

	def get_outputs(self,workflow_output_folder):
		workflow_output_path = os.path.join("outputs",workflow_output_folder)
		output_config = super().get_outputs(workflow_output_folder)
		output_config["vcf"] = [{"patterns": ["*.vcf"], "input_folder": workflow_output_path}]
		output_config["maf"] = [{"patterns": ["*.maf","*.portal.txt"], "input_folder": workflow_output_path}]
		return output_config

	def modify_dependency_inputs(self,roslin_yaml,job_params):
		params = self.params
		dependency_input = copy.deepcopy(roslin_yaml)
		dependency_input['bam'] = self.input_sample_or_pair([None,"bams","bams"],job_params,roslin_yaml)
		dependency_input['pair'] = self.input_sample_or_pair([None,"pair","pairs"],job_params,roslin_yaml)
		dependency_input['normal_bam'] = dependency_input['bams'][1]
		dependency_input['tumor_bam'] = dependency_input['bams'][0]
		dependency_input['normal_sample_name'] = dependency_input['pair'][1]['ID']
		dependency_input['tumor_sample_name'] = dependency_input['pair'][0]['ID']
		runparams_inputs = add_record_argument(roslin_yaml['runparams'],["genome","tmp_dir","delly_type"])
		db_files_inputs = add_record_argument(roslin_yaml['db_files'],["vep_path","custom_enst","vep_data","hotspot_list","pairing_file","delly_exclude"])
		dependency_input.update(runparams_inputs)
		dependency_input.update(db_files_inputs)
		return dependency_input

class VariantCalling(SingleCWLWorkflow):

	def configure(self):
		super().configure('VariantCalling','modules/pair','variant-calling-pair.cwl',['Alignment'],[])

	def get_inputs(self,single_dependency_list,multi_dependency_list):
		requirement_list, dependency_key_list = super().get_inputs(single_dependency_list,multi_dependency_list)
		pair_number = self.add_sample_or_pair_argument("pair")
		batch_argument = self.add_batch_argument()
		requirement_list.extend([pair_number,batch_argument])
		dependency_key_list.extend([pair_number[2],batch_argument[2]])
		return (requirement_list, dependency_key_list)

	def modify_dependency_inputs(self,roslin_yaml,job_params):
		params = self.params
		dependency_input = copy.deepcopy(roslin_yaml)
		dependency_input['bams'] = self.input_sample_or_pair([None,"bams","bams"],job_params,roslin_yaml)
		dependency_input['bed'] = self.input_sample_or_pair(["bed","beds",None],job_params,roslin_yaml)
		dependency_input['normal_bam'] = dependency_input['bams'][1]
		dependency_input['tumor_bam'] = dependency_input['bams'][0]
		dependency_input['pair'] = self.input_sample_or_pair([None,"pair","pairs"],job_params,roslin_yaml)
		dependency_input['normal_sample_name'] = dependency_input['pair'][1]['ID']
		dependency_input['tumor_sample_name'] = dependency_input['pair'][0]['ID']
		runparams_inputs = add_record_argument(roslin_yaml['runparams'],["genome","tmp_dir","mutect_dcov","mutect_rf","facets_pcval","facets_cval","complex_tn","complex_nn"])
		db_files_inputs = add_record_argument(roslin_yaml['db_files'],["facets_snps","hotspot_vcf","refseq"])
		dependency_input.update(runparams_inputs)
		dependency_input.update(db_files_inputs)
		return dependency_input

	def get_outputs(self,workflow_output_folder):
		workflow_output_path = os.path.join("outputs",workflow_output_folder)
		output_config = super().get_outputs(workflow_output_folder)
		output_config["vcf"] = [{"patterns": ["*.vcf","*.norm.vcf.gz","*.norm.vcf.gz.tbi","*.mutect.txt","*.combined-variants.vcf.gz","*.combined-variants.vcf.gz.tbi"], "input_folder": workflow_output_path}]
		output_config["facets"] = [{"patterns": ["*_hisens.CNCF.png","*_hisens.cncf.txt","*_hisens.out","*_hisens.Rdata","*_hisens.seg","*_purity.CNCF.png","*_purity.cncf.txt","*_purity.out","*_purity.Rdata","*_purity.seg","*dat.gz"], "input_folder": workflow_output_path}]
		return output_config


#-------------------- Tools --------------------

class CdnaContam(SingleCWLWorkflow):

	def configure(self):
		super().configure('CreateCdnaContam','tools/roslin-qc','create-cdna-contam.cwl',[],['StructuralVariants'])

	def get_outputs(self,workflow_output_folder):
		workflow_output_path = os.path.join("outputs",workflow_output_folder)
		output_config = super().get_outputs(workflow_output_folder)
		output_config["qc"] = [{"patterns": ["*_cdna_contamination.txt"], "input_folder": workflow_output_path}]
		return output_config

	def modify_dependency_inputs(self,roslin_yaml,job_params):
		project_prefix = roslin_yaml['runparams']['project_prefix']
		input_mafs = roslin_yaml['maf_file']
		dependency_input = {'project_prefix':project_prefix,'input_mafs':input_mafs}
		return dependency_input


class HelloWorld(RoslinWorkflow):

	def run_pipeline(self):
		def helloWorld(params,job_params):
			return "Hello, world!"
		default_job_params = self.set_default_job_params()
		j1 = self.create_job(helloWorld,self.params,default_job_params,"first")
		j2 = self.create_job(helloWorld,self.params,default_job_params,"second")
		j3 = self.create_job(helloWorld,self.params,default_job_params,"third")
		j4 = self.create_job(helloWorld,self.params,default_job_params,"last")
		j1.addChild(j2)
		j1.addChild(j3)
		j1.addFollowOn(j4)
		return j1
