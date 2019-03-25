import os, sys
from builtins import super

ROSLIN_CORE_BIN_PATH = os.environ['ROSLIN_CORE_BIN_PATH']
sys.path.append(ROSLIN_CORE_BIN_PATH)

from track_utils import RoslinWorkflow, SingleCWLWorkflow
from core_utils  import run_command_realtime
import copy

class LegacyVariantWorkflow(SingleCWLWorkflow):

	def configure(self):
		super().configure('ProjectWorkflow','project-workflow.cwl',[])

	def get_outputs(self,workflow_output_folder):
		workflow_output_path = os.path.join("outputs",workflow_output_folder)
		output_config = super().get_outputs(workflow_output_folder)
		output_config["bam"] = [{"patterns": ["*.bam","*.bai"], "input_folder": workflow_output_path}]
		output_config["vcf"] = [{"patterns": ["*.vcf","*.norm.vcf.gz","*.norm.vcf.gz.tbi","*.mutect.txt"], "input_folder": workflow_output_path}]
		output_config["maf"] = [{"patterns": ["*.maf","*.portal.txt"], "input_folder": workflow_output_path}]
		output_config["qc"] =  [{"patterns": ["qc_merged_directory/*"], "input_folder": workflow_output_path}]
		output_config["facets"] = [{"patterns": ["*_hisens.CNCF.png","*_hisens.cncf.txt","*_hisens.out","*_hisens.Rdata","*_hisens.seg","*_purity.CNCF.png","*_purity.cncf.txt","*_purity.out","*_purity.Rdata","*_purity.seg","*dat.gz"], "input_folder": workflow_output_path}]
		return output_config

	def run_pipeline(self):
		return super().run_pipeline(run_analysis=True)


class LegacyVariantWorkflowSV(LegacyVariantWorkflow):

	def configure(self):
		super().configure('ProjectWorkflowSV','project-workflow-sv.cwl',[])

	def get_outputs(self,workflow_output_folder):
		workflow_output_path = os.path.join("outputs",workflow_output_folder)
		output_config = super().get_outputs(workflow_output_folder)
		output_config["bam"] = [{"patterns": ["*.bam","*.bai"], "input_folder": workflow_output_path}]
		output_config["vcf"] = [{"patterns": ["*.vcf","*.norm.vcf.gz","*.norm.vcf.gz.tbi","*.mutect.txt"], "input_folder": workflow_output_path}]
		output_config["maf"] = [{"patterns": ["*.maf","*.portal.txt"], "input_folder": workflow_output_path}]
		output_config["qc"] =  [{"patterns": ["qc_merged_directory/*"], "input_folder": workflow_output_path}]
		output_config["facets"] = [{"patterns": ["*_hisens.CNCF.png","*_hisens.cncf.txt","*_hisens.out","*_hisens.Rdata","*_hisens.seg","*_purity.CNCF.png","*_purity.cncf.txt","*_purity.out","*_purity.Rdata","*_purity.seg","*dat.gz"], "input_folder": workflow_output_path}]
		return output_config

	def run_pipeline(self):
		return super().run_pipeline(run_analysis=True)

class VariantWorkflow(RoslinWorkflow):

	def configure(self):
		super().configure()
		self.params['configure']['run_sv'] = False

	def run_pipeline(self):
		workflow_params = self.params
		alignment_job, alignment_params = Alignment(workflow_params).get_job()
		gather_metrics_job, gather_metrics_params = GatherMetrics(workflow_params).get_job([alignment_params])
		conpair_job, conpair_params = Conpair(workflow_params).get_job([alignment_params])
		generate_images_job, generate_images_params = GenerateImages(workflow_params).get_job([gather_metrics_params])
		consolidate_results_job, consolidate_results_params = ConsolidateResults(workflow_params).get_job([gather_metrics_params, conpair_params])
		variant_calling_job, variant_calling_params = VariantCalling(workflow_params).get_job([alignment_params])
		structural_variants_job, structural_variants_params = StructuralVariants(workflow_params).get_job([alignment_params])
		filtering_job, filtering_params = Filtering(workflow_params).get_job([alignment_params,variant_calling_params])
		generate_images_job.addChild(consolidate_results_job)
		conpair_job.addChild(generate_images_job)
		gather_metrics_job.addChild(conpair_job)
		alignment_job.addChild(gather_metrics_job)
		variant_calling_job.addChild(filtering_job)
		alignment_job.addChild(variant_calling_job)
		if workflow_params['configure']['run_sv']:
			structural_variants_job, structural_variants_params = StructuralVariants(workflow_params).get_job(alignment_post_params)
			cdna_contam_job, cdna_contam_job_params = CdnaContam(workflow_params).get_job(structural_variants_params)
			structural_variants_job.addChild(cdna_contam_job)
			alignment_job.addChild(structural_variants_job)
		alignment_job = self.copy_workflow_outputs(alignment_job)
		alignment_job = self.roslin_analysis(alignment_job)
		return alignment_job


class VariantWorkflowSV(VariantWorkflow):

	def configure(self):
		super().configure()
		self.params['configure']['run_sv'] = True

class CdnaContam(SingleCWLWorkflow):

	def configure(self):
		super().configure('Create-cdna-contam','roslin-qc/create-cdna-contam.cwl',['StructuralVariants'])

	def get_outputs(self,workflow_output_folder):
		workflow_output_path = os.path.join("outputs",workflow_output_folder)
		output_config = super().get_outputs(workflow_output_folder)
		output_config["qc"] = [{"patterns": ["*_cdna_contamination.txt"], "input_folder": workflow_output_path}]

	def modify_dependency_inputs(roslin_yaml):
		project_prefix = roslin_yaml['runparams']['project_prefix']
		input_mafs = roslin_yaml['maf_file']
		dependency_input = {'project_prefix':project_prefix,'input_mafs':input_mafs}
		return dependency_input

class GenerateImages(SingleCWLWorkflow):

	def configure(self):
		super().configure('GenerateImages','roslin-qc/generate-images.cwl',['GatherMetrics'])

	def get_outputs(self,workflow_output_folder):
		workflow_output_path = os.path.join("outputs",workflow_output_folder)
		output_config = super().get_outputs(workflow_output_folder)
		output_config["qc"] = [{"patterns": ["*_ProjectSummary.txt","*_SampleSummary.txt"], "input_folder": workflow_output_path},
							   {"patterns": ["images"], "input_folder": workflow_output_path}]

	def modify_dependency_inputs(roslin_yaml):
		data_dir = roslin_yaml['qc_merged_and_hotspots_directory']
		bin_value = roslin_yaml['runparams']['scripts_bin']
		file_prefix = roslin_yaml['runparams']['project_prefix']
		dependency_input = {'data_dir':data_dir,'bin':bin_value,'file_prefix':file_prefix}
		return dependency_input

class ConsolidateResults(SingleCWLWorkflow):

	def configure(self):
		super().configure('ConsolidateResults','consolidate-files/consolidate-directories.cwl',['GatherMetrics','Conpair'])
		self.params['configure']['consolidate_results_output'] = "consolidated_metrics_data"

	def get_outputs(self,workflow_output_folder):
		output_directory_name = self.params['configure']['consolidate_results_output']
		workflow_output_path = os.path.join("outputs",workflow_output_folder)
		output_config = super().get_outputs(workflow_output_folder)
		output_config["qc"] = [{"patterns": ["*_ProjectSummary.txt","*_SampleSummary.txt"], "input_folder": workflow_output_path},
							   {"patterns": ["output_directory_name"], "input_folder": workflow_output_path }]

	def modify_dependency_inputs(roslin_yaml):
		output_directory_name = self.params['configure']['consolidate_results_output']
		directories = [roslin_yaml['conpair_output_dir'],roslin_yaml['gather_metrics_files'],roslin_yaml['qc_merged_and_hotspots_directory'],roslin_yaml['output']]
		dependency_input = {'output_directory_name':output_directory_name,'directories':directories}
		return dependency_input

class Alignment(SingleCWLWorkflow):

	def configure(self):
		super().configure('Alignment','alignment.cwl',[])

	def get_outputs(self,workflow_output_folder):
		workflow_output_path = os.path.join("outputs",workflow_output_folder)
		output_config = super().get_outputs(workflow_output_folder)
		output_config["bam"] = [{"patterns": ["*.bam","*.bai"], "input_folder": workflow_output_path}]
		return output_config

class GatherMetrics(SingleCWLWorkflow):

	def configure(self):
		super().configure('Gather-metrics','gather_metrics.cwl',['Alignment'])

	def get_outputs(self,workflow_output_folder):
		workflow_output_path = os.path.join("outputs",workflow_output_folder)
		output_config = super().get_outputs(workflow_output_folder)
		qc_merged_path = os.path.join(workflow_output_path,"qc_merged_directory")
		gather_metrics_files_path = os.path.join(workflow_output_path,"gather_metrics_files")
		output_config["qc"] = [{"patterns": ["*.pdf","*.summary","*.gcbiasmetrics","*.asmetrics"], "input_folder": workflow_output_path},
							   {"patterns": ["*metrics","*.txt"], "input_folder": gather_metrics_files_path},
							   {"patterns": ["*.txt"], "input_folder": qc_merged_path}]
		return output_config


class Conpair(SingleCWLWorkflow):

	def configure(self):
		super().configure('Conpair','conpair.cwl',['Alignment'])

	def get_outputs(self,workflow_output_folder):
		workflow_output_path = os.path.join("outputs",workflow_output_folder)
		conpair_output_path = os.path.join(workflow_output_path,"conpair_output_files")
		output_config = super().get_outputs(workflow_output_folder)
		output_config["qc"] = [{"patterns": ["*.pdf","*.txt"], "input_folder": conpair_output_path}]
		return output_config

class VariantCalling(SingleCWLWorkflow):

	def configure(self):
		super().configure('Variant-calling','variant_calling.cwl',['Alignment'])

	def get_outputs(self,workflow_output_folder):
		workflow_output_path = os.path.join("outputs",workflow_output_folder)
		output_config = super().get_outputs(workflow_output_folder)
		output_config["vcf"] = [{"patterns": ["*.vcf","*.norm.vcf.gz","*.norm.vcf.gz.tbi","*.mutect.txt"], "input_folder": workflow_output_path}]
		output_config["facets"] = [{"patterns": ["*_hisens.CNCF.png","*_hisens.cncf.txt","*_hisens.out","*_hisens.Rdata","*_hisens.seg","*_purity.CNCF.png","*_purity.cncf.txt","*_purity.out","*_purity.Rdata","*_purity.seg","*dat.gz"], "input_folder": workflow_output_path}]
		return output_config


class StructuralVariants(SingleCWLWorkflow):

	def configure(self):
		super().configure('Structural-variants','find_svs.cwl',['Alignment'])

	def get_outputs(self,workflow_output_folder):
		workflow_output_path = os.path.join("outputs",workflow_output_folder)
		output_config = super().get_outputs(workflow_output_folder)
		output_config["vcf"] = [{"patterns": ["*.vcf"], "input_folder": workflow_output_path}]
		output_config["maf"] = [{"patterns": ["*.maf","*.portal.txt"], "input_folder": workflow_output_path}]
		return output_config


class Filtering(SingleCWLWorkflow):

	def configure(self):
		super().configure('Filtering','filtering.cwl',['Alignment','VariantCalling'])
		super().configure()
		workflow_output = 'Filtering'
		workflow_filename = 'filtering.cwl'
		workflow_name = self.__class__.__name__
		workflow_info = {'output':workflow_output,'filename':workflow_filename}
		workflow_output_path = os.path.join("outputs",workflow_output)
		workflow_log_path = os.path.join(workflow_output_path,"log")
		output_config = {"maf": [{"patterns": ["*.maf"], "input_folder": workflow_output_path}],
         				 "log": [{"patterns": ["cwltoil.log"], "input_folder": workflow_log_path, "output_folder": workflow_output},
						 		 {"patterns": ["output-meta.json","settings","job-uuid","job-store-uuid"], "input_folder": workflow_output_path, "output_folder": workflow_output}]}
		self.params['workflows'][workflow_name] = workflow_info
		self.update_copy_outputs_config(output_config)

	def get_outputs(self,workflow_output_folder):
		workflow_output_path = os.path.join("outputs",workflow_output_folder)
		output_config = super().get_outputs(workflow_output_folder)
		output_config["maf"] = [{"patterns": ["*.maf"], "input_folder": workflow_output_path}]
		return output_config

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