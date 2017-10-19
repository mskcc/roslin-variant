from pymongo import MongoClient
import time
import sys

MONGO_URL = 'mongodb://pitchfork.cbio.mskcc.org:27017'
client = MongoClient(MONGO_URL, connect=False)
db = client.pi_workflows

def watch_mongo(pipelineJobId):
	while True:
		print pipelineJobId
		jobs_running = 0
		for run_result_doc in db.RunResults.find({'pipelineJobId':pipelineJobId}):
			pipelineJobId = run_result_doc['pipelineJobId']
			projectId = run_result_doc['projectId']
			status = run_result_doc['status']
			if status == 'DONE':
				sys.exit(0)
			if status == 'EXIT':
				sys.exit(1)
			print status
		time.sleep(10)	

if __name__ == '__main__':
	watch_mongo(sys.argv[1])
