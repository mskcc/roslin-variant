import os, sys
from builtins import super

ROSLIN_CORE_BIN_PATH = os.environ['ROSLIN_CORE_BIN_PATH']
sys.path.append(ROSLIN_CORE_BIN_PATH)

from track_utils import RoslinWorkflow
from core_utils  import run_command_realtime
import copy

def add_workflow_requirement(parser,requirements_list):
	for parser_action, parser_type, parser_dest, parser_option, parser_help, parser_required, is_path in requirements_list:
		parser.add_argument(parser_option, type=parser_type, action=parser_action, dest=parser_dest, help=parser_help, required=parser_required)
	return parser

def get_post_alignment_requirement():
	requirement_list = [("store",str,"alignment_meta","--use_alignment_meta","The path to the alignment outputs meta file that you need for this run ( since this is a intermediate workflow )", True, True)]
	return requirement_list

def get_post_variant_calling_requirement():
	requirement_list = [("store",str,"variant_calling_meta","--use_variant_calling_meta","The path to the variant calling outputs meta file that you need for this run ( since this is intermediate workflows )", True, True)]
	return requirement_list

class LegacyVariantWorkflow(RoslinWorkflow):

	def configure(self):
		super().configure()
		workflow_output = 'ProjectWorkflow'
		workflow_filename = 'project-workflow.cwl'
		workflow_name = self.__class__.__name__
		workflow_info = {'output':workflow_output,'filename':workflow_filename}
		workflow_output_path = os.path.join("outputs",workflow_output)
		workflow_log_path = os.path.join(workflow_output_path,"logs")
		self.params['workflows'][workflow_name] = workflow_info
		self.update_copy_outputs_config(output_config)
		super().configure()
		output_config = {"bam": [{"patterns": ["*.bam","*.bai"], "input_folder": workflow_output}],
						 "vcf": [{"patterns": ["*.vcf","*.norm.vcf.gz","*.norm.vcf.gz.tbi","*.mutect.txt"], "input_folder": workflow_output}],
						 "maf": [{"patterns": ["*.maf","*.portal.txt"], "input_folder": workflow_output}],
						 "qc":  [{"patterns": ["qc_merged_directory/*"], "input_folder": workflow_output}],
						 "log": [{"patterns": ["cwltoil.log"], "input_folder": workflow_log_path, "output_folder": workflow_output},
						 		 {"patterns": ["output-meta.json","settings","job-uuid","job-store-uuid"], "input_folder": workflow_output_path, "output_folder": workflow_output}],
						 "facets": [{"patterns": ["*_hisens.CNCF.png","*_hisens.cncf.txt","*_hisens.out","*_hisens.Rdata","*_hisens.seg","*_purity.CNCF.png","*_purity.cncf.txt","*_purity.out","*_purity.Rdata","*_purity.seg","*dat.gz"], "input_folder": workflow_output}]}
		self.update_copy_outputs_config(output_config)

	def run_pipeline(self):
		default_job_params = self.set_default_job_params()
		workflow_filename, workflow_output = self.get_workflow_info()
		default_job_params['cwl'] = workflow_filename
		workflow_job = self.create_job(self.run_cwl,self.params,default_job_params,workflow_output)
		workflow_job = self.copy_workflow_outputs(workflow_job)
		return workflow_job

class LegacyVariantWorkflowSV(LegacyVariantWorkflow):

	def configure(self):
		super().configure()
		workflow_output = 'ProjectWorkflowSV'
		workflow_filename = 'project-workflow-sv.cwl'
		workflow_name = self.__class__.__name__
		workflow_info = {'output':workflow_output,'filename':workflow_filename}
		workflow_output_path = os.path.join("outputs",workflow_output)
		workflow_log_path = os.path.join(workflow_output_path,"logs")
		self.params['workflows'][workflow_name] = workflow_info
		self.update_copy_outputs_config(output_config)
		super().configure()
		output_config = {"bam": [{"patterns": ["*.bam","*.bai"], "input_folder": workflow_output}],
						 "vcf": [{"patterns": ["*.vcf","*.norm.vcf.gz","*.norm.vcf.gz.tbi","*.mutect.txt"], "input_folder": workflow_output}],
						 "maf": [{"patterns": ["*.maf","*.portal.txt"], "input_folder": workflow_output}],
						 "qc":  [{"patterns": ["qc_merged_directory/*"], "input_folder": workflow_output}],
						 "log": [{"patterns": ["cwltoil.log"], "input_folder": workflow_log_path, "output_folder": workflow_output},
						 		 {"patterns": ["output-meta.json","settings","job-uuid","job-store-uuid"], "input_folder": workflow_output_path, "output_folder": workflow_output}],
						 "facets": [{"patterns": ["*_hisens.CNCF.png","*_hisens.cncf.txt","*_hisens.out","*_hisens.Rdata","*_hisens.seg","*_purity.CNCF.png","*_purity.cncf.txt","*_purity.out","*_purity.Rdata","*_purity.seg","*dat.gz"], "input_folder": workflow_output}]}
		self.update_copy_outputs_config(output_config)

	def run_pipeline(self):
		default_job_params = self.set_default_job_params()
		workflow_filename, workflow_output = self.get_workflow_info()
		default_job_params['cwl'] = workflow_filename
		workflow_job = self.create_job(self.run_cwl,self.params,default_job_params,workflow_output)
		workflow_job = self.copy_workflow_outputs(workflow_job)
		return workflow_job

class VariantWorkflow(RoslinWorkflow):

	def configure(self):
		super.configure()
		self.params['run_sv'] = False

	def run_pipeline(self):
		workflow_params = self.params
		alignment_job, alignment_params = Alignment(workflow_params).get_job()
		alignment_post_job, alignment_post_params = AlignmentPost(workflow_params).get_job(alignment_params)
		gather_metrics_job, gather_metrics_params = GatherMetrics(workflow_params).get_job(alignment_post_params)
		conpair_job, conpair_params = Conpair(workflow_params).get_job(alignment_post_params)
		variant_calling_job, variant_calling_params = VariantCalling(workflow_params).get_job(alignment_post_params)
		variant_calling_post_job, variant_calling_post_params = VariantCallingPost(workflow_params).get_job(variant_calling_params)
		structural_variants_job, structural_variants_params = StructuralVariants(workflow_params).get_job(alignment_post_params)
		filtering_job, filtering_params = Filtering(workflow_params).get_job(variant_calling_post_params)

		alignment_post_job.addChild(gather_metrics_job)
		alignment_post_job.addChild(conpair_job)
		variant_calling_post_job.addChild(filtering_job)
		variant_calling_job.addChild(variant_calling_post_job)
		alignment_post_job.addChild(variant_calling_job)
		if workflow_params['run_sv']:
			structural_variants_job, structural_variants_params = StructuralVariants(workflow_params).get_job(alignment_post_params)
			alignment_post_job.addChild(structural_variants_job)
		alignment_job.addChild(alignment_post_job)
		alignment_job = self.copy_workflow_outputs(alignment_job)
		return alignment_job


class VariantWorkflowSV(VariantWorkflow):

	def configure(self):
		super().configure()
		self.params['run_sv'] = True

class Alignment(RoslinWorkflow):

	def configure(self):
		super().configure()
		workflow_output = 'Alignment'
		workflow_filename = 'alignment.cwl'
		workflow_name = self.__class__.__name__
		workflow_info = {'output':workflow_output,'filename':workflow_filename}
		workflow_output_path = os.path.join("outputs",workflow_output)
		workflow_log_path = os.path.join(workflow_output_path,"logs")
		output_config = {"bam": [{"patterns": ["*.bam","*.bai"], "input_folder": workflow_output_path}],
						 "log": [{"patterns": ["cwltoil.log"], "input_folder": workflow_log_path, "output_folder": workflow_output},
						 		 {"patterns": ["output-meta.json","settings","job-uuid","job-store-uuid"], "input_folder": workflow_output_path, "output_folder": workflow_output}] }
		self.params['workflows'][workflow_name] = workflow_info
		self.update_copy_outputs_config(output_config)

	def run_pipeline(self):
		workflow_params = self.params
		alignment_job, alignment_params = Alignment(workflow_params).get_job()
		alignment_job = self.copy_workflow_outputs(alignment_job)
		return alignment_job

	def get_job(self):
		workflow_filename, workflow_output = self.get_workflow_info()
		return self.create_workflow(None,None,workflow_filename,workflow_output)

class AlignmentPost(RoslinWorkflow):

	def configure(self):
		super().configure()
		workflow_output = 'Alignment-post'
		workflow_filename = None
		workflow_name = self.__class__.__name__
		workflow_info = {'output':workflow_output,'filename':workflow_filename}
		output_config = {"log": [{"patterns": ["post-alignment.yaml"], "input_folder": "outputs", "output_folder": workflow_output}]}
		self.params['workflows'][workflow_name] = workflow_info
		self.update_copy_outputs_config(output_config)

	def run_pipeline(self):
		workflow_params = self.params
		workflow_inputs = workflow_params['input_yaml']
		alignment_meta = workflow_params['alignment_meta']
		alignment_info = {'output_meta_json':alignment_meta,'input_yaml':workflow_inputs}
		alignment_post_job, alignment_post_params = AlignmentPost(workflow_params).get_job(alignment_info)
		alignment_post_job = self.copy_workflow_outputs(alignment_post_job)
		return alignment_post_job

	def add_requirement(self,parser):
		requirement_list = get_post_alignment_requirement()
		parser = add_workflow_requirement(parser,requirement_list)
		return (parser, requirement_list)

	def get_job(self,alignment_job_params):
		workflow_filename, workflow_output = self.get_workflow_info()
		parent_job_params = [alignment_job_params]
		workflow_output_directory = self.params['output_dir']
		job_yaml_path = os.path.join(workflow_output_directory,'post-alignment.yaml')
		return self.create_workflow(parent_job_params,job_yaml_path,workflow_filename,workflow_output)

class GatherMetrics(RoslinWorkflow):

	def configure(self):
		super().configure()
		workflow_output = 'Gather-metrics'
		workflow_filename = 'gather_metrics.cwl'
		workflow_name = self.__class__.__name__
		workflow_info = {'output':workflow_output,'filename':workflow_filename}
		workflow_output_path = os.path.join("outputs",workflow_output)
		qc_merged_path = os.path.join(workflow_output_path,"qc_merged_directory")
		gather_metrics_files_path = os.path.join(workflow_output_path,"gather_metrics_files")
		workflow_log_path = os.path.join(workflow_output_path,"log")
		output_config = {"qc": [{"patterns": ["*.pdf","*.summary","*.gcbiasmetrics","*.asmetrics"], "input_folder": workflow_output_path},
								{"patterns": ["*metrics","*.txt"], "input_folder": workflow_output_path},
								{"patterns": ["*.txt"], "input_folder": qc_merged_path}],
						 "log": [{"patterns": ["cwltoil.log"], "input_folder": workflow_log_path, "output_folder": workflow_output},
						 		 {"patterns": ["output-meta.json","settings","job-uuid","job-store-uuid"], "input_folder": workflow_output_path, "output_folder": workflow_output}] }
		self.params['workflows'][workflow_name] = workflow_info
		self.update_copy_outputs_config(output_config)

	def run_pipeline(self):
		workflow_params = self.params
		workflow_inputs = workflow_params['input_yaml']
		alignment_meta = workflow_params['alignment_meta']
		alignment_info = {'output_meta_json':alignment_meta,'input_yaml':workflow_inputs}
		alignment_post_job, alignment_post_params = AlignmentPost(workflow_params).get_job(alignment_info)
		gather_metrics_job, gather_metrics_params = GatherMetrics(workflow_params).get_job(alignment_post_params)
		alignment_post_job.addChild(gather_metrics_job)
		alignment_post_job = self.copy_workflow_outputs(alignment_post_job)
		return alignment_post_job

	def add_requirement(self,parser):
		requirement_list = get_post_alignment_requirement()
		parser = add_workflow_requirement(parser,requirement_list)
		return (parser, requirement_list)

	def get_job(self,alignment_post_job_params):
		workflow_filename, workflow_output = self.get_workflow_info()
		job_yaml_path = alignment_post_job_params['input_yaml']
		return self.create_workflow(None,job_yaml_path,workflow_filename,workflow_output)

class Conpair(RoslinWorkflow):

	def configure(self):
		super().configure()
		workflow_output = 'Conpair'
		workflow_filename = 'conpair.cwl'
		workflow_name = self.__class__.__name__
		workflow_info = {'output':workflow_output,'filename':workflow_filename}
		workflow_output_path = os.path.join("outputs",workflow_output)
		conpair_output_path = os.path.join(workflow_output_path,"conpair_output_files")
		workflow_log_path = os.path.join(workflow_output_path,"log")
		output_config = {"qc": [{"patterns": ["*.pdf","*.txt"], "input_folder": conpair_output_path}],
						 "log": [{"patterns": ["cwltoil.log"], "input_folder": workflow_log_path, "output_folder": workflow_output},
						 		 {"patterns": ["output-meta.json","settings","job-uuid","job-store-uuid"], "input_folder": workflow_output_path, "output_folder": workflow_output}] }
		self.params['workflows'][workflow_name] = workflow_info
		self.update_copy_outputs_config(output_config)

	def run_pipeline(self):
		workflow_params = self.params
		workflow_inputs = workflow_params['input_yaml']
		alignment_meta = workflow_params['alignment_meta']
		alignment_info = {'output_meta_json':alignment_meta,'input_yaml':workflow_inputs}
		alignment_post_job, alignment_post_params = AlignmentPost(workflow_params).get_job(alignment_info)
		conpair_job, conpair_params = Conpair(workflow_params).get_job(alignment_post_params)
		alignment_post_job.addChild(conpair_job)
		alignment_post_job = self.copy_workflow_outputs(alignment_post_job)
		return alignment_post_job

	def add_requirement(self,parser):
		requirement_list = get_post_alignment_requirement()
		parser = add_workflow_requirement(parser,requirement_list)
		return (parser, requirement_list)

	def get_job(self,alignment_post_job_params):
		workflow_filename, workflow_output = self.get_workflow_info()
		job_yaml_path = alignment_post_job_params['input_yaml']
		return self.create_workflow(None,job_yaml_path,workflow_filename,workflow_output)

class VariantCalling(RoslinWorkflow):

	def configure(self):
		super().configure()
		workflow_output = 'Variant-calling'
		workflow_filename = 'variant_calling.cwl'
		workflow_name = self.__class__.__name__
		workflow_info = {'output':workflow_output,'filename':workflow_filename}
		workflow_output_path = os.path.join("outputs",workflow_output)
		workflow_log_path = os.path.join(workflow_output_path,"log")
		output_config = {"vcf": [{"patterns": ["*.vcf","*.norm.vcf.gz","*.norm.vcf.gz.tbi","*.mutect.txt"], "input_folder": workflow_output}],
						 "facets": [{"patterns": ["*_hisens.CNCF.png","*_hisens.cncf.txt","*_hisens.out","*_hisens.Rdata","*_hisens.seg","*_purity.CNCF.png","*_purity.cncf.txt","*_purity.out","*_purity.Rdata","*_purity.seg","*dat.gz"], "input_folder": workflow_output}],
         				 "log": [{"patterns": ["cwltoil.log"], "input_folder": workflow_log_path, "output_folder": workflow_output},
						 		 {"patterns": ["output-meta.json","settings","job-uuid","job-store-uuid"], "input_folder": workflow_output_path, "output_folder": workflow_output}]}
		self.params['workflows'][workflow_name] = workflow_info
		self.update_copy_outputs_config(output_config)

	def run_pipeline(self):
		workflow_params = self.params
		workflow_inputs = workflow_params['input_yaml']
		alignment_meta = workflow_params['alignment_meta']
		alignment_info = {'output_meta_json':alignment_meta,'input_yaml':workflow_inputs}
		alignment_post_job, alignment_post_params = AlignmentPost(workflow_params).get_job(alignment_info)
		variant_calling_job, variant_calling_params = VariantCalling(workflow_params).get_job(alignment_post_params)
		alignment_post_job.addChild(variant_calling_job)
		alignment_post_job = self.copy_workflow_outputs(alignment_post_job)
		return alignment_post_job

	def add_requirement(self,parser):
		requirement_list = get_post_alignment_requirement()
		parser = add_workflow_requirement(parser,requirement_list)
		return (parser, requirement_list)

	def get_job(self,alignment_post_job_params):
		workflow_filename, workflow_output = self.get_workflow_info()
		job_yaml_path = alignment_post_job_params['input_yaml']
		return self.create_workflow(None,job_yaml_path,workflow_filename,workflow_output)

class VariantCallingPost(RoslinWorkflow):

	def configure(self):
		super().configure()
		workflow_output = 'Variant-calling-post'
		workflow_filename = None
		workflow_name = self.__class__.__name__
		workflow_info = {'output':workflow_output,'filename':workflow_filename}
		output_config = {"log": [{"patterns": ["post-variant-calling.yaml"], "input_folder": "outputs", "output_folder": workflow_output}]}
		self.params['workflows'][workflow_name] = workflow_info
		self.update_copy_outputs_config(output_config)

	def run_pipeline(self):
		workflow_params = self.params
		workflow_inputs = workflow_params['input_yaml']
		alignment_meta = workflow_params['alignment_meta']
		variant_calling_meta = workflow_params['variant_calling_meta']
		alignment_info = {'output_meta_json':alignment_meta,'input_yaml':workflow_inputs}
		alignment_post_job, alignment_post_params = AlignmentPost(workflow_params).get_job(alignment_info)
		alignment_input_yaml = alignment_post_params['input_yaml']
		variant_calling_info = {'output_meta_json':variant_calling_meta,'input_yaml':alignment_input_yaml}
		variant_calling_post_job, variant_calling_post_params = VariantCallingPost(workflow_params).get_job(variant_calling_info)
		alignment_post_job.addChild(variant_calling_post_job)
		alignment_post_job = self.copy_workflow_outputs(alignment_post_job)
		return alignment_post_job

	def add_requirement(self,parser):
		alignment_requirement_list = get_post_alignment_requirement()
		variant_requirement_list = get_post_variant_calling_requirement()
		requirement_list = alignment_requirement_list + variant_requirement_list
		parser = add_workflow_requirement(parser,requirement_list)
		return (parser, requirement_list)

	def get_job(self,variant_job_params):
		workflow_filename, workflow_output = self.get_workflow_info()
		parent_job_params = [variant_job_params]
		workflow_output_directory = self.params['output_dir']
		job_yaml_path = os.path.join(workflow_output_directory,'post-variant-calling.yaml')
		return self.create_workflow(parent_job_params,job_yaml_path,workflow_filename,workflow_output)

class StructuralVariants(RoslinWorkflow):

	def configure(self):
		super().configure()
		workflow_output = 'Structural-variants'
		workflow_filename = 'find_svs.cwl'
		workflow_name = self.__class__.__name__
		workflow_info = {'output':workflow_output,'filename':workflow_filename}
		workflow_output_path = os.path.join("outputs",workflow_output)
		workflow_log_path = os.path.join(workflow_output_path,"log")
		output_config = {"vcf": [{"patterns": ["*.vcf"], "input_folder": workflow_output}],
         				 "maf": [{"patterns": ["*.maf","*.portal.txt"], "input_folder": workflow_output}],
         				 "log": [{"patterns": ["cwltoil.log"], "input_folder": workflow_log_path, "output_folder": workflow_output},
						 		 {"patterns": ["output-meta.json","settings","job-uuid","job-store-uuid"], "input_folder": workflow_output_path, "output_folder": workflow_output}]}
		self.params['workflows'][workflow_name] = workflow_info
		self.update_copy_outputs_config(output_config)

	def run_pipeline(self):
		workflow_params = self.params
		workflow_inputs = workflow_params['input_yaml']
		alignment_meta = workflow_params['alignment_meta']
		alignment_info = {'output_meta_json':alignment_meta,'input_yaml':workflow_inputs}
		alignment_post_job, alignment_post_params = AlignmentPost(workflow_params).get_job(alignment_info)
		structural_variants_job, structural_variants_params = StructuralVariants(workflow_params).get_job(alignment_post_params)
		alignment_post_job.addChild(structural_variants_job)
		alignment_post_job = self.copy_workflow_outputs(alignment_post_job)
		return alignment_post_job

	def add_requirement(self,parser):
		requirement_list = get_post_alignment_requirement()
		parser = add_workflow_requirement(parser,requirement_list)
		return (parser, requirement_list)

	def get_job(self,alignment_post_job_params):
		workflow_filename, workflow_output = self.get_workflow_info()
		job_yaml_path = alignment_post_job_params['input_yaml']
		return self.create_workflow(None,job_yaml_path,workflow_filename,workflow_output)

class Filtering(RoslinWorkflow):

	def configure(self):
		super().configure()
		workflow_output = 'Filtering'
		workflow_filename = 'filtering.cwl'
		workflow_name = self.__class__.__name__
		workflow_info = {'output':workflow_output,'filename':workflow_filename}
		workflow_output_path = os.path.join("outputs",workflow_output)
		workflow_log_path = os.path.join(workflow_output_path,"log")
		output_config = {"maf": [{"patterns": ["*.maf"], "input_folder": workflow_output}],
         				 "log": [{"patterns": ["cwltoil.log"], "input_folder": workflow_log_path, "output_folder": workflow_output},
						 		 {"patterns": ["output-meta.json","settings","job-uuid","job-store-uuid"], "input_folder": workflow_output_path, "output_folder": workflow_output}]}
		self.params['workflows'][workflow_name] = workflow_info
		self.update_copy_outputs_config(output_config)

	def run_pipeline(self):
		workflow_params = self.params
		workflow_inputs = workflow_params['input_yaml']
		alignment_meta = workflow_params['alignment_meta']
		variant_calling_meta = workflow_params['variant_calling_meta']
		alignment_info = {'output_meta_json':alignment_meta,'input_yaml':workflow_inputs}
		alignment_post_job, alignment_post_params = AlignmentPost(workflow_params).get_job(alignment_info)
		alignment_input_yaml = alignment_post_params['input_yaml']
		variant_calling_info = {'output_meta_json':variant_calling_meta,'input_yaml':alignment_input_yaml}
		variant_calling_post_job, variant_calling_post_params = VariantCallingPost(workflow_params).get_job(variant_calling_info)
		filtering_job, filtering_params = Filtering(workflow_params).get_job(variant_calling_post_params)
		variant_calling_post_job.addChild(filtering_job)
		alignment_post_job.addChild(variant_calling_post_job)
		alignment_post_job = self.copy_workflow_outputs(alignment_post_job)
		return alignment_post_job

	def add_requirement(self,parser):
		alignment_requirement_list = get_post_alignment_requirement()
		variant_requirement_list = get_post_variant_calling_requirement()
		requirement_list = alignment_requirement_list + variant_requirement_list
		parser = add_workflow_requirement(parser,requirement_list)
		return (parser, requirement_list)

	def get_job(self,variant_post_job_params):
		workflow_filename, workflow_output = self.get_workflow_info()
		job_yaml_path = variant_post_job_params['input_yaml']
		return self.create_workflow(None,job_yaml_path,workflow_filename,workflow_output)

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