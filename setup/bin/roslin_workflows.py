import os, sys
from builtins import super

ROSLIN_CORE_BIN_PATH = os.environ['ROSLIN_CORE_BIN_PATH']
sys.path.append(ROSLIN_CORE_BIN_PATH)

from track_utils import RoslinWorkflow, SingleCWLWorkflow
from core_utils  import run_command_realtime
import copy
import dill

def get_varriant_workflow_outputs(output_config, workflow_output_path):
	output_config["bam"] = [{"patterns": ["*.bam","*.bai"], "input_folder": workflow_output_path}]
	output_config["vcf"] = [{"patterns": ["*.vcf","*.norm.vcf.gz","*.norm.vcf.gz.tbi","*.mutect.txt"], "input_folder": workflow_output_path}]
	output_config["maf"] = [{"patterns": ["*.maf","*.portal.txt"], "input_folder": workflow_output_path}]
	output_config["qc"] =  [{"patterns": ["qc_merged_directory/*"], "input_folder": workflow_output_path}]
	output_config["facets"] = [{"patterns": ["*_hisens.CNCF.png","*_hisens.cncf.txt","*_hisens.out","*_hisens.Rdata","*_hisens.seg","*_purity.CNCF.png","*_purity.cncf.txt","*_purity.out","*_purity.Rdata","*_purity.seg","*dat.gz"], "input_folder": workflow_output_path}]
	return output_config

def add_record_argument(record,key_list):
	input_arguments = {}
	for single_key in key_list:
		if single_key in record:
			input_arguments[single_key] = record[single_key]
	return input_arguments

def input_sample(key_list,params,roslin_yaml):
	return input_specific_sample_or_pair("sample",key_list,params,roslin_yaml)
def input_pair(key_list,params,roslin_yaml):
	return input_specific_sample_or_pair("pair",key_list,params,roslin_yaml)

def input_sample_or_pair(sample_or_pair,key_list,params,roslin_yaml):
	requirements = params['requirements']
	logger = dill.loads(params['logger'])
	dependency_input = None
	dependency_key_list = []
	error_description = ""
	duplicate_description = ""
	pair_number = None
	sample_number = None
	if 'pair_number' in requirements:
		pair_number = requirements['pair_number']
	if 'sample_number' in requirements:
		sample_number = requirements['sample_number']
	if sample_or_pair == 'pair':
		key_list.insert(0,None)
	valid_keys = []
	key_name = None
	for input_key_num, input_key in enumerate(key_list):
		new_dependency_input = None
		if input_key:
			valid_keys.append(input_key)
		if input_key in roslin_yaml:
			if input_key_num == 0:
				if isinstance(roslin_yaml[input_key], list):
					error_description = error_description+ "Tried " + input_key + ", but input cannot be of type list, got "+ type(roslin_yaml[input_key]).__name__ +" instead\n"
				else:
					key_name = input_key
					new_dependency_input = roslin_yaml[input_key]
			if input_key_num == 1:
				if isinstance(roslin_yaml[input_key], list):
					if sample_or_pair == 'pair':
						if any(isinstance(single_elem, list) for single_elem in roslin_yaml[input_key]):
							error_description = error_description + "Tried " + input_key + ", but input must be of type list, got type list of lists\n"
						else:
							key_name = input_key
							new_dependency_input = roslin_yaml[input_key]
					else:
						if sample_number:
							key_name = input_key
							new_dependency_input = roslin_yaml[input_key][sample_number]
						else:
							error_description = error_description + "Tried " + input_key + ", but --sample-num is not specified\n"
			if input_key_num == 2:
				if isinstance(roslin_yaml[input_key], list):
					if any(isinstance(single_elem, list) for single_elem in roslin_yaml[input_key]):
						if pair_number:
							if sample_or_pair == 'pair':
								key_name = input_key
								new_dependency_input = roslin_yaml[input_key][pair_number]
							else:
								if sample_number:
									key_name = input_key
									new_dependency_input = roslin_yaml[input_key][pair_number][sample_number]
								else:
									error_description = error_description + "Tried " + input_key + ", but --sample-num is not specified\n"
						else:
							error_description = error_description + "Tried " + input_key + ", but --pair-num is not specified\n"
		if new_dependency_input:
			dependency_input = new_dependency_input
			dependency_key_list.append(input_key)

	if len(dependency_key_list) > 1:
		error_description = "Multiple valid inputs from keys: " +",".join(dependency_key_list)
	if len(dependency_key_list) == 0:
		error_description = "Could not find inputs from valid keys: " + ",".join(valid_keys)

	if error_description:
		log(logger,"error",error_message)
		sys.exit(1)
	else:
		return dependency_input

def add_sample_or_pair_argument(sample_or_pair):
	if sample_or_pair == 'sample':
		return ("store",int,"sample_number","--sample-num","The sample to process in a given pair", False, False)
	else:
		return ("store",int,"pair_number","--pair-num","The pair to process in a given list of pairs", False, False)


#-------------------- Workflows --------------------

class VariantWorkflow(SingleCWLWorkflow):

	def configure(self):
		super().configure('ProjectWorkflow','workflows','project-workflow.cwl',[],[])

	def get_outputs(self,workflow_output_folder):
		workflow_output_path = os.path.join("outputs",workflow_output_folder)
		output_config = super().get_outputs(workflow_output_folder)
		output_config = get_varriant_workflow_outputs(output_config, workflow_output_path)
		return output_config

	def run_pipeline(self):
		return super().run_pipeline(run_analysis=True)


class VariantWorkflowSV(VariantWorkflow):

	def configure(self):
		super().configure('ProjectWorkflowSV','project-workflow-sv.cwl',[],[])

	def get_outputs(self,workflow_output_folder):
		output_config = super().get_outputs(workflow_output_folder)
		return output_config

	def run_pipeline(self):
		return super().run_pipeline(run_analysis=True)

class QcWorkflow(SingleCWLWorkflow):

	def configure(self):
		super().configure('Qc-workflow','qc-workflow.cwl',[],['PairWorkflow'])

	def get_outputs(self,workflow_output_folder):
		workflow_output_path = os.path.join("outputs",workflow_output_folder)
		output_config = super().get_outputs(workflow_output_folder)
		consolidated_metrics_folder = os.path.join(workflow_output_path,"consolidated_metrics_data")
		output_config["qc"] = [{"patterns": ["*_QC_Report.pdf"], "input_folder": workflow_output_path},
							   {"patterns": ["*"], "input_folder": consolidated_metrics_folder,"output_folder":"consolidated_metrics_data"}]
		return output_config

class QcWorkflowSV(QcWorkflow):

	def configure(self):
		super().configure('Qc-workflow','qc-workflow.cwl',['CdnaContam'],['PairWorkflowSV'])

	def get_outputs(self,workflow_output_folder):
		workflow_output_path = os.path.join("outputs",workflow_output_folder)
		output_config = super().get_outputs(workflow_output_folder)
		consolidated_metrics_folder = os.path.join(workflow_output_path,"consolidated_metrics_data")
		output_config["qc"] = [{"patterns": ["*_QC_Report.pdf"], "input_folder": workflow_output_path},
							   {"patterns": ["*"], "input_folder": consolidated_metrics_folder,"output_folder":"consolidated_metrics_data"}]
		return output_config

	def modify_dependency_inputs(self,roslin_yaml):
		files = roslin_yaml['cdna_contam_output']
		dependency_input = copy.deepcopy(roslin_yaml)
		dependency_input['files'] = [files]
		return dependency_input


class SampleWorkflow(SingleCWLWorkflow):

	def configure(self):
		super().configure('SampleWorkflow','sample-workflow.cwl',[],[])

	def get_inputs(self,dependency_list):
		requirement_list, dependency_key_list = self.get_inputs(dependency_list)
		sample_number = add_sample_or_pair_argument("sample")
		pair_number = add_sample_or_pair_argument("pair")
		requirement_list.extend([pair_number, sample_number])
		dependency_key_list.extend([pair_number[2],sample_number[2]])
		return (requirement_list, dependency_key_list)

	def modify_dependency_inputs(self,roslin_yaml):
		params = self.params
		requirements = params['requirements']
		logger = dill.loads(params['logger'])
		dependency_input =  copy.deepcopy(roslin_yaml)
		sample_input = input_sample(["sample","pair","pairs"],params,roslin_yaml)
		runparams_inputs = add_record_argument(roslin_yaml['runparams'],["genome","tmp_dir","opt_dup_pix_dist","gatk_jar_path"])
		db_files_inputs = add_record_argument(roslin_yaml['db_files'],["bait_intervals","target_intervals","fp_intervals","ref_fasta","conpair_markers_bed"])
		dependency_input.extend(runparams_inputs)
		dependency_input.extend(db_files_inputs)
		dependency_input = {"sample":sample_input,"bait_intervals":bait_intervals,"target_intervals":target_intervals,"fp_intervals":fp_intervals,"ref_fasta":ref_fasta,"conpair_markers_bed":conpair_markers_bed,"genome":genome,"tmp_dir":tmp_dir,"gatk_jar_path":gatk_jar_path,'opt_dup_pix_dist':opt_dup_pix_dist}
		return dependency_input

	def get_outputs(self,workflow_output_folder):
		workflow_output_path = os.path.join("outputs",workflow_output_folder)
		output_config = super().get_outputs(workflow_output_folder)
		output_config["bam"] = [{"patterns": ["*.bam","*.bai"], "input_folder": workflow_output_path}]
		output_config["qc"] = [{"patterns": ["*metrics","*.txt","*.pdf","*.summary"], "input_folder": workflow_output_path}]
		return output_config

class PairWorkflow(SingleCWLWorkflow):

	def configure(self):
		super().configure('PairWorkflow','pair-workflow.cwl',[],[])

	def get_inputs(self,dependency_list):
		requirement_list, dependency_key_list = self.get_inputs(dependency_list)
		pair_number = add_sample_or_pair_argument("pair")
		requirement_list.extend([pair_number])
		dependency_key_list.extend([pair_number[2]])
		return (requirement_list, dependency_key_list)

	def modify_dependency_inputs(self,roslin_yaml):
		params = self.params
		requirements = params['requirements']
		logger = dill.loads(params['logger'])
		dependency_input =  copy.deepcopy(roslin_yaml)
		pair_input = input_pair(["pair","pairs"],params,roslin_yaml)
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
		super().configure('PairWorkflowSV','pair-workflow-sv.cwl',[])

	def get_outputs(self,workflow_output_folder):
		output_config = super().get_outputs(workflow_output_folder)
		return output_config

#-------------------- Modules --------------------

class Alignment(SingleCWLWorkflow):

	def configure(self):
		super().configure('Alignment','modules/pair','alignment-pair.cwl',[])

	def get_inputs(self,dependency_list):
		requirement_list, dependency_key_list = self.get_inputs(dependency_list)
		pair_number = add_sample_or_pair_argument("pair")
		requirement_list.extend([pair_number])
		dependency_key_list.extend([pair_number[2]])
		return (requirement_list, dependency_key_list)

	def modify_dependency_inputs(self,roslin_yaml):
		params = self.params
		dependency_input =  copy.deepcopy(roslin_yaml)
		dependency_input['pair'] = input_pair(["pair","pairs"],params,roslin_yaml)
		runparams_inputs = add_record_argument(roslin_yaml['runparams'],["genome","tmp_dir","opt_dup_pix_dist","covariates","abra_scratch","abra_ram_min","gatk_jar_path"])
		db_files_inputs = add_record_argument(roslin_yaml['db_files'],["bait_intervals","target_intervals","fp_intervals","ref_fasta","conpair_markers_bed"])
		dependency_input.extend(runparams_inputs)
		dependency_input.extend(db_files_inputs)
		return dependency_input

	def get_outputs(self,workflow_output_folder):
		workflow_output_path = os.path.join("outputs",workflow_output_folder)
		output_config = super().get_outputs(workflow_output_folder)
		output_config["bam"] = [{"patterns": ["*.bam","*.bai"], "input_folder": workflow_output_path}]
		output_config["qc"] = [{"patterns": ["*metrics","*.txt","*.pdf","*.summary"], "input_folder": workflow_output_path}]
		return output_config

class GatherMetrics(SingleCWLWorkflow):

	def configure(self):
		super().configure('GatherMetrics','modules/sample','gather-metrics.cwl',['Alignment'])

	def get_inputs(self,dependency_list):
		requirement_list, dependency_key_list = self.get_inputs(dependency_list)
		sample_number = input_sample(["sample","pair","pairs"],params,roslin_yaml)
		pair_number = input_pair(["pair","pairs"],params,roslin_yaml)
		requirement_list.extend([pair_number, sample_number])
		dependency_key_list.extend([pair_number[2],sample_number[2]])
		return (requirement_list, dependency_key_list)

	def get_outputs(self,workflow_output_folder):
		workflow_output_path = os.path.join("outputs",workflow_output_folder)
		output_config = super().get_outputs(workflow_output_folder)
		output_config["qc"] = [{"patterns": ["*metrics","*.txt","*.pdf","*.summary"], "input_folder": workflow_output_path}]
		return output_config

	def modify_dependency_inputs(self,roslin_yaml):
		params = self.params
		dependency_input = copy.deepcopy(roslin_yaml)
		dependency_input['bam'] = input_sample(["bam","bams","bams"],params,roslin_yaml)
		runparams_inputs = add_record_argument(roslin_yaml['runparams'],["genome","tmp_dir","gatk_jar_path"])
		db_files_inputs = add_record_argument(roslin_yaml['db_files'],["bait_intervals","target_intervals","fp_intervals","ref_fasta","conpair_markers_bed"])
		dependency_input.extend(runparams_inputs)
		dependency_input.extend(db_files_inputs)
		return dependency_input


class GenerateQc(SingleCWLWorkflow):

	def configure(self):
		super().configure('GenerateQc.cwl','modules/project','generate-qc.cwl',[],['PairWorkflow'])

	def get_outputs(self,workflow_output_folder):
		workflow_output_path = os.path.join("outputs",workflow_output_folder)
		output_config = super().get_outputs(workflow_output_folder)
		consolidated_metrics_folder = os.path.join(workflow_output_path,"consolidated_metrics_data")
		output_config["qc"] = [{"patterns": ["*_QC_Report.pdf"], "input_folder": workflow_output_path},
							   {"patterns": ["*"], "input_folder": consolidated_metrics_folder,"output_folder":"consolidated_metrics_data"}]
		return output_config

	def modify_dependency_inputs(self,roslin_yaml):
		data_dir = roslin_yaml['qc_merged_and_hotspots_directory']
		bin_value = roslin_yaml['runparams']['scripts_bin']
		file_prefix = roslin_yaml['runparams']['project_prefix']
		dependency_input = {'data_dir':data_dir,'bin':bin_value,'file_prefix':file_prefix}
		return dependency_input

class GenerateQcSV(GenerateQc):

	def configure(self):
		super().configure('GenerateQc.cwl','modules/project','generate-qc.cwl',['CdnaContam'],['PairWorkflowSv'])

	def modify_dependency_inputs(self,roslin_yaml):
		files = roslin_yaml['cdna_contam_output']
		dependency_input = copy.deepcopy(roslin_yaml)
		dependency_input['files'] = [files]
		return dependency_input

class MafProcessing(SingleCWLWorkflow):

	def configure(self):
		super().configure('MafProcessing','modules/pair','maf-processing-pair.cwl',['Alignment','VariantCalling'])

	def get_inputs(self,dependency_list):
		requirement_list, dependency_key_list = self.get_inputs(dependency_list)
		pair_number = add_sample_or_pair_argument("pair")
		requirement_list.extend([pair_number])
		dependency_key_list.extend([pair_number[2]])
		return (requirement_list, dependency_key_list)

	def get_outputs(self,workflow_output_folder):
		workflow_output_path = os.path.join("outputs",workflow_output_folder)
		output_config = super().get_outputs(workflow_output_folder)
		output_config["maf"] = [{"patterns": ["*.maf"], "input_folder": workflow_output_path}]
		return output_config

	def modify_dependency_inputs(self,roslin_yaml):
		params = self.params
		dependency_input = copy.deepcopy(roslin_yaml)
		dependency_input['bam'] = input_pair(["bams","bams"],params,roslin_yaml)
		dependency_input['pair'] = input_pair(["pair","pairs"],params,roslin_yaml)
		dependency_input['annotate_vcf'] = input_pair(["annotate_vcf","annotate_vcf"],params,roslin_yaml)[0]
		dependency_input['normal_sample_name'] = dependency_input['pair'][1]['ID']
		dependency_input['tumor_sample_name'] = dependency_input['pair'][0]['ID']
		runparams_inputs = add_record_argument(roslin_yaml['runparams'],["genome","tmp_dir"])
		db_files_inputs = add_record_argument(roslin_yaml['db_files'],["ref_fasta","vep_path","custom_enst","vep_data","hotspot_list","pairing_file"])
		dependency_input.extend(runparams_inputs)
		dependency_input.extend(db_files_inputs)
		return dependency_input

class Realignment(SingleCWLWorkflow):

	def configure(self):
		super().configure('Realignment','modules/pair','realignment.cwl',[],['SampleWorkflow'])

	def get_inputs(self,dependency_list):
		requirement_list, dependency_key_list = self.get_inputs(dependency_list)
		pair_number = add_sample_or_pair_argument("pair")
		requirement_list.extend([pair_number])
		dependency_key_list.extend([pair_number[2]])
		return (requirement_list, dependency_key_list)

	def modify_dependency_inputs(self,roslin_yaml):
		params = self.params
		requirements = params['requirements']
		logger = dill.loads(params['logger'])
		dependency_input = copy.deepcopy(roslin_yaml)
		dependency_input['pair'] = input_pair(["pair","pairs"],params,roslin_yaml)
		dependency_input['bams'] = input_pair(["bams","bams"],params,roslin_yaml)
		runparams_inputs = add_record_argument(roslin_yaml['runparams'],["covariates","genome","tmp_dir","abra_scratch","abra_ram_min"])
		dependency_input.extend(runparams_inputs)
		return dependency_input

	def get_outputs(self,workflow_output_folder):
		workflow_output_path = os.path.join("outputs",workflow_output_folder)
		output_config = super().get_outputs(workflow_output_folder)
		output_config = get_varriant_workflow_outputs(output_config, workflow_output_path)
		return output_config

class StructuralVariants(SingleCWLWorkflow):

	def configure(self):
		super().configure('StructuralVariants','modules/pair','structural-variants-pair.cwl',['Alignment'])

	def get_outputs(self,workflow_output_folder):
		workflow_output_path = os.path.join("outputs",workflow_output_folder)
		output_config = super().get_outputs(workflow_output_folder)
		output_config["vcf"] = [{"patterns": ["*.vcf"], "input_folder": workflow_output_path}]
		output_config["maf"] = [{"patterns": ["*.maf","*.portal.txt"], "input_folder": workflow_output_path}]
		return output_config

	def modify_dependency_inputs(self,roslin_yaml):
		params = self.params
		dependency_input = copy.deepcopy(roslin_yaml)
		dependency_input['bam'] = input_pair(["bams","bams"],params,roslin_yaml)
		dependency_input['pair'] = input_pair(["pair","pairs"],params,roslin_yaml)
		dependency_input['normal_sample_name'] = dependency_input['pair'][1]['ID']
		dependency_input['tumor_sample_name'] = dependency_input['pair'][0]['ID']
		runparams_inputs = add_record_argument(roslin_yaml['runparams'],["genome","tmp_dir"])
		db_files_inputs = add_record_argument(roslin_yaml['db_files'],["ref_fasta","vep_path","custom_enst","vep_data","hotspot_list","pairing_file"])
		dependency_input.extend(runparams_inputs)
		dependency_input.extend(db_files_inputs)
		return dependency_input

class VariantCalling(SingleCWLWorkflow):

	def configure(self):
		super().configure('VariantCalling','modules/pair','variant-calling-pair.cwl',['PairAlignment'])

	def modify_dependency_inputs(self,roslin_yaml):
		params = self.params
		dependency_input = copy.deepcopy(roslin_yaml)
		dependency_input['bams'] = input_pair(["bams","bams"],params,roslin_yaml)
		dependency_input['bed'] = input_pair(["bed","beds"],params,roslin_yaml)
		dependency_input['normal_bam'] = dependency_input['bams'][1]
		dependency_input['tumor_bam'] = dependency_input['bams'][0]
		dependency_input['pair'] = input_pair(["pair","pairs"],params,roslin_yaml)
		dependency_input['normal_sample_name'] = dependency_input['pair'][1]['ID']
		dependency_input['tumor_sample_name'] = dependency_input['pair'][0]['ID']
		runparams_inputs = add_record_argument(roslin_yaml['runparams'],["genome","tmp_dir","mutect_dcov","mutect_rf","facets_pcval","facets_cval","complex_tn","complex_nn"])
		db_files_inputs = add_record_argument(roslin_yaml['db_files'],["ref_fasta","facets_snps","hotspot_vcf","refseq"])
		dependency_input.extend(runparams_inputs)
		dependency_input.extend(db_files_inputs)
		return dependency_input

	def get_outputs(self,workflow_output_folder):
		workflow_output_path = os.path.join("outputs",workflow_output_folder)
		output_config = super().get_outputs(workflow_output_folder)
		output_config["vcf"] = [{"patterns": ["*.vcf","*.norm.vcf.gz","*.norm.vcf.gz.tbi","*.mutect.txt"], "input_folder": workflow_output_path}]
		output_config["facets"] = [{"patterns": ["*_hisens.CNCF.png","*_hisens.cncf.txt","*_hisens.out","*_hisens.Rdata","*_hisens.seg","*_purity.CNCF.png","*_purity.cncf.txt","*_purity.out","*_purity.Rdata","*_purity.seg","*dat.gz"], "input_folder": workflow_output_path}]
		return output_config


#-------------------- Tools --------------------

class CdnaContam(SingleCWLWorkflow):

	def configure(self):
		super().configure('Create-cdna-contam','tools/roslin-qc','create-cdna-contam.cwl',['StructuralVariants'])

	def get_outputs(self,workflow_output_folder):
		workflow_output_path = os.path.join("outputs",workflow_output_folder)
		output_config = super().get_outputs(workflow_output_folder)
		output_config["qc"] = [{"patterns": ["*_cdna_contamination.txt"], "input_folder": workflow_output_path}]
		return output_config

	def modify_dependency_inputs(self,roslin_yaml):
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
