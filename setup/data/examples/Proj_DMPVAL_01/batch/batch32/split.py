#!/usr/bin/env python

import csv
import re
import os


project_name = "Proj_DMPVAL_01"
num_of_groups = 256
num_of_groups_per_batch = 32


def chunks(l, n):
    """Yield successive n-sized chunks from l."""
    for i in xrange(0, len(l), n):
        yield l[i:i + n]


grouping_dict = dict()
file_batch = dict()

# inclusive (both ends)
split_ranges = list(chunks(range(1, num_of_groups + 1), num_of_groups_per_batch))

num_of_batches = len(split_ranges)


for batch_id in range(1, num_of_batches + 1):
    dst_dir="./batch-{}".format(batch_id)
    if not os.path.isdir(dst_dir):
        os.mkdir(dst_dir)
    file_batch[batch_id] = open("{0}/{1}_{2}_sample_grouping.txt".format(dst_dir, project_name, batch_id), "wt")
    grouping_dict[batch_id] = dict()

# open ${project_name}_sample_grouping.txt in the parent directory
with open("../{}_sample_grouping.txt".format(project_name), "r") as fh:

    csvreader = csv.DictReader(fh, delimiter="\t", fieldnames=['sample_id', 'group_id'])

    for row in csvreader:

        match = re.search(r'Group_(\d+)', row['group_id'])
        if not match:
            raise Exception("something not right")

        group_number = int(match.group(1))

        for batch_id_0th_based in range(0, num_of_batches):

            batch_id = batch_id_0th_based + 1

            if group_number in split_ranges[batch_id_0th_based]:
                # print batch_id, group_number

                if row['group_id'] not in grouping_dict[batch_id]:
                    grouping_dict[batch_id][row['group_id']] = list()

                grouping_dict[batch_id][row['group_id']].append(row['sample_id'])

                file_batch[batch_id].write("{}\t{}\n".format(row['sample_id'], row['group_id']))


for batch_id in range(1, num_of_batches + 1):
    file_batch[batch_id].close()
    print "Generated {}".format(file_batch[batch_id].name)
