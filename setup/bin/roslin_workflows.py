import os, sys

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

	def run_pipeline(self):
		default_job_params = self.set_default_job_params()
		default_job_params['cwl'] = "project-workflow.cwl"
		workflow_job = self.create_job(self.run_cwl,self.params,default_job_params,"ProjectWorkflow")
		return workflow_job

class LegacyVariantWorkflowSV(RoslinWorkflow):

	def run_pipeline(self):
		default_job_params = self.set_default_job_params()
		default_job_params['cwl'] = "project-workflow-sv.cwl"
		workflow_job = self.create_job(self.run_cwl,self.params,default_job_params,"ProjectWorkflowSV")
		return workflow_job

class VariantWorkflow(RoslinWorkflow):

	def configure(self):
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

		alignment_post_job.addFollowOn(gather_metrics_job)
		alignment_post_job.addFollowOn(conpair_job)
		variant_calling_post_job.addFollowOn(filtering_job)
		variant_calling_job.addFollowOn(variant_calling_post_job)
		alignment_post_job.addFollowOn(variant_calling_job)
		if workflow_params['run_sv']:
			structural_variants_job, structural_variants_params = StructuralVariants(workflow_params).get_job(alignment_post_params)
			alignment_post_job.addFollowOn(structural_variants_job)
		alignment_job.addFollowOn(alignment_post_job)

		return alignment_job


class VariantWorkflowSV(VariantWorkflow):

	def configure(self):
		self.params['run_sv'] = True

class Alignment(RoslinWorkflow):

	def run_pipeline(self):
		workflow_params = self.params
		alignment_job, alignment_params = Alignment(workflow_params).get_job()
		return alignment_job

	def get_job(self):
		return self.create_workflow(None,None,'alignment.cwl','Alignment')

class AlignmentPost(RoslinWorkflow):

	def run_pipeline(self):
		workflow_params = self.params
		workflow_inputs = workflow_params['input_yaml']
		alignment_meta = workflow_params['alignment_meta']
		alignment_info = {'output_meta_json':alignment_meta,'input_yaml':workflow_inputs}
		alignment_post_job, alignment_post_params = AlignmentPost(workflow_params).get_job(alignment_info)
		return alignment_post_job

	def add_requirement(self,parser):
		requirement_list = get_post_alignment_requirement()
		parser = add_workflow_requirement(parser,requirement_list)
		return (parser, requirement_list)

	def get_job(self,alignment_job_params):
		parent_job_params = [alignment_job_params]
		workflow_output_directory = self.params['output_dir']
		job_yaml_path = os.path.join(workflow_output_directory,'post-alignment.yaml')
		return self.create_workflow(parent_job_params,job_yaml_path,None,'Alignment-post')

class GatherMetrics(RoslinWorkflow):

	def run_pipeline(self):
		workflow_params = self.params
		workflow_inputs = workflow_params['input_yaml']
		alignment_meta = workflow_params['alignment_meta']
		alignment_info = {'output_meta_json':alignment_meta,'input_yaml':workflow_inputs}
		alignment_post_job, alignment_post_params = AlignmentPost(workflow_params).get_job(alignment_info)
		gather_metrics_job, gather_metrics_params = GatherMetrics(workflow_params).get_job(alignment_post_params)
		alignment_post_job.addFollowOn(gather_metrics_job)
		return alignment_post_job

	def add_requirement(self,parser):
		requirement_list = get_post_alignment_requirement()
		parser = add_workflow_requirement(parser,requirement_list)
		return (parser, requirement_list)

	def get_job(self,alignment_post_job_params):
		job_yaml_path = alignment_post_job_params['input_yaml']
		return self.create_workflow(None,job_yaml_path,'gather_metrics.cwl','Gather-metrics')

class Conpair(RoslinWorkflow):

	def run_pipeline(self):
		workflow_params = self.params
		workflow_inputs = workflow_params['input_yaml']
		alignment_meta = workflow_params['alignment_meta']
		alignment_info = {'output_meta_json':alignment_meta,'input_yaml':workflow_inputs}
		alignment_post_job, alignment_post_params = AlignmentPost(workflow_params).get_job(alignment_info)
		conpair_job, conpair_params = Conpair(workflow_params).get_job(alignment_post_params)
		alignment_post_job.addFollowOn(conpair_job)
		return alignment_post_job

	def add_requirement(self,parser):
		requirement_list = get_post_alignment_requirement()
		parser = add_workflow_requirement(parser,requirement_list)
		return (parser, requirement_list)

	def get_job(self,alignment_post_job_params):
		job_yaml_path = alignment_post_job_params['input_yaml']
		return self.create_workflow(None,job_yaml_path,'conpair.cwl','Conpair')

class VariantCalling(RoslinWorkflow):

	def run_pipeline(self):
		workflow_params = self.params
		workflow_inputs = workflow_params['input_yaml']
		alignment_meta = workflow_params['alignment_meta']
		alignment_info = {'output_meta_json':alignment_meta,'input_yaml':workflow_inputs}
		alignment_post_job, alignment_post_params = AlignmentPost(workflow_params).get_job(alignment_info)
		variant_calling_job, variant_calling_params = VariantCalling(workflow_params).get_job(alignment_post_params)
		alignment_post_job.addFollowOn(variant_calling_job)
		return alignment_post_job

	def add_requirement(self,parser):
		requirement_list = get_post_alignment_requirement()
		parser = add_workflow_requirement(parser,requirement_list)
		return (parser, requirement_list)

	def get_job(self,alignment_post_job_params):
		job_yaml_path = alignment_post_job_params['input_yaml']
		return self.create_workflow(None,job_yaml_path,'variant_calling.cwl','Variant-calling')

class VariantCallingPost(RoslinWorkflow):

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
		alignment_post_job.addFollowOn(variant_calling_post_job)
		return alignment_post_job

	def add_requirement(self,parser):
		alignment_requirement_list = get_post_alignment_requirement()
		variant_requirement_list = get_post_variant_calling_requirement()
		requirement_list = alignment_requirement_list + variant_requirement_list
		parser = add_workflow_requirement(parser,requirement_list)
		return (parser, requirement_list)

	def get_job(self,variant_job_params):
		parent_job_params = [variant_job_params]
		workflow_output_directory = self.params['output_dir']
		job_yaml_path = os.path.join(workflow_output_directory,'post-variant-calling.yaml')
		return self.create_workflow(parent_job_params,job_yaml_path,None,'Variant-calling-post')

class StructuralVariants(RoslinWorkflow):

	def run_pipeline(self):
		workflow_params = self.params
		workflow_inputs = workflow_params['input_yaml']
		alignment_meta = workflow_params['alignment_meta']
		alignment_info = {'output_meta_json':alignment_meta,'input_yaml':workflow_inputs}
		alignment_post_job, alignment_post_params = AlignmentPost(workflow_params).get_job(alignment_info)
		structural_variants_job, structural_variants_params = StructuralVariants(workflow_params).get_job(alignment_post_params)
		alignment_post_job.addFollowOn(structural_variants_job)
		return alignment_post_job

	def add_requirement(self,parser):
		requirement_list = get_post_alignment_requirement()
		parser = add_workflow_requirement(parser,requirement_list)
		return (parser, requirement_list)

	def get_job(self,alignment_post_job_params):
		job_yaml_path = alignment_post_job_params['input_yaml']
		return self.create_workflow(None,job_yaml_path,'find_svs.cwl','Structural-variants')

class Filtering(RoslinWorkflow):

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
		variant_calling_post_job.addFollowOn(filtering_job)
		alignment_post_job.addFollowOn(variant_calling_post_job)
		return alignment_post_job

	def add_requirement(self,parser):
		alignment_requirement_list = get_post_alignment_requirement()
		variant_requirement_list = get_post_variant_calling_requirement()
		requirement_list = alignment_requirement_list + variant_requirement_list
		parser = add_workflow_requirement(parser,requirement_list)
		return (parser, requirement_list)

	def get_job(self,variant_post_job_params):
		job_yaml_path = variant_post_job_params['input_yaml']
		return self.create_workflow(None,job_yaml_path,'filtering.cwl','Filtering')

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


