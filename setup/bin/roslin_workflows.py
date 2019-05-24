import os, sys
from builtins import super

ROSLIN_CORE_BIN_PATH = os.environ['ROSLIN_CORE_BIN_PATH']
sys.path.append(ROSLIN_CORE_BIN_PATH)

from track_utils import log, RoslinWorkflow, SingleCWLWorkflow
from core_utils  import run_command_realtime, add_record_argument
import copy
import dill

def get_varriant_workflow_outputs(output_config, workflow_output_path):
	output_config["bam"] = [{"patterns": ["*.bam","*.bai"], "input_folder": workflow_output_path}]
	output_config["vcf"] = [{"patterns": ["*.vcf","*.norm.vcf.gz","*.norm.vcf.gz.tbi","*.mutect.txt","*.combined-variants.vcf.gz","*.combined-variants.vcf.gz.tbi"], "input_folder": workflow_output_path}]
	output_config["maf"] = [{"patterns": ["*.maf","*.portal.txt"], "input_folder": workflow_output_path}]
	output_config["qc"] =  [{"patterns": ["qc_merged_directory/*"], "input_folder": workflow_output_path}]
	output_config["facets"] = [{"patterns": ["*_hisens.CNCF.png","*_hisens.cncf.txt","*_hisens.out","*_hisens.Rdata","*_hisens.seg","*_purity.CNCF.png","*_purity.cncf.txt","*_purity.out","*_purity.Rdata","*_purity.seg","*dat.gz"], "input_folder": workflow_output_path}]
	return output_config

#-------------------- Workflows --------------------

class VariantWorkflow(SingleCWLWorkflow):

	def configure(self):
		super().configure('VariantWorkflow','workflows','project-workflow.cwl',[],[])

	def configure_sv(self):
		super().configure('VariantWorkflowSV','workflows','project-workflow-sv.cwl',[],[])

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

class QcWorkflow(SingleCWLWorkflow):

	def configure(self):
		super().configure('QcWorkflow','workflows','qc-workflow.cwl',[],['PairWorkflow'])

	def configure_sv(self):
		super().configure('QcWorkflow','workflows','qc-workflow.cwl',['CdnaContam'],['PairWorkflowSV'])

	def get_outputs(self,workflow_output_folder):
		workflow_output_path = os.path.join("outputs",workflow_output_folder)
		output_config = super().get_outputs(workflow_output_folder)
		consolidated_metrics_folder = os.path.join(workflow_output_path,"consolidated_metrics_data")
		output_config["qc"] = [{"patterns": ["*_QC_Report.pdf"], "input_folder": workflow_output_path},
							   {"patterns": ["*"], "input_folder": consolidated_metrics_folder,"output_folder":"consolidated_metrics_data"}]
		return output_config

class QcWorkflowSV(QcWorkflow):

	def configure(self):
		super().configure_sv()

	def modify_dependency_inputs(self,roslin_yaml,job_params):
		files = roslin_yaml['cdna_contam_output']
		dependency_input = copy.deepcopy(roslin_yaml)
		dependency_input['files'] = [files]
		return dependency_input


class SampleWorkflow(SingleCWLWorkflow):

	def configure(self):
		super().configure('SampleWorkflow','workflows','sample-workflow.cwl',[],[])

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
		db_files_inputs = add_record_argument(roslin_yaml['db_files'],["bait_intervals","target_intervals","fp_intervals","ref_fasta","conpair_markers_bed"])
		dependency_input.update(runparams_inputs)
		dependency_input.update(db_files_inputs)
		return dependency_input

	def get_outputs(self,workflow_output_folder):
		workflow_output_path = os.path.join("outputs",workflow_output_folder)
		output_config = super().get_outputs(workflow_output_folder)
		output_config["bam"] = [{"patterns": ["*.bam","*.bai"], "input_folder": workflow_output_path}]
		output_config["qc"] = [{"patterns": ["*metrics","*.txt","*.pdf","*.summary"], "input_folder": workflow_output_path}]
		return output_config

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
		db_files_inputs = add_record_argument(roslin_yaml['db_files'],["bait_intervals","target_intervals","fp_intervals","ref_fasta","conpair_markers_bed"])
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
		db_files_inputs = add_record_argument(roslin_yaml['db_files'],["bait_intervals","target_intervals","fp_intervals","ref_fasta","conpair_markers_bed"])
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
		db_files_inputs = add_record_argument(roslin_yaml['db_files'],["ref_fasta","vep_path","custom_enst","vep_data","hotspot_list","pairing_file"])
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
		db_files_inputs = add_record_argument(roslin_yaml['db_files'],["ref_fasta","vep_path","custom_enst","vep_data","hotspot_list","pairing_file"])
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
		db_files_inputs = add_record_argument(roslin_yaml['db_files'],["ref_fasta","facets_snps","hotspot_vcf","refseq"])
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
