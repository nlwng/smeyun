#!/usr/bin/env python
#-*- coding:utf-8 -*-
# Author:Neil
'''
AWS lambda script auto stop start Instances
version 0.1
'''

import boto3
import datetime

now = datetime.datetime.now()

regions='us-east-1'

def manager_instances():
    ReservationId_list=[]
    start_list = []
    stop_list = []

    ec2 = boto3.client('ec2', region_name=regions)
    ec2_des_inst_list=ec2.describe_instances()['Reservations']

    for ec2_des_inst_dict in ec2_des_inst_list:
        try:
            '''[u'Instances', u'ReservationId', u'Groups', u'OwnerId']'''
            ReservationId = ec2_des_inst_dict['ReservationId']

            for Instances_dict in ec2_des_inst_dict['Instances']:

                #ec2 State
                state = Instances_dict['State']['Name']
                ec2_instances = Instances_dict['InstanceId']

                Tags_list = Instances_dict['Tags']

                for Tags_dict in Tags_list:
                    Instances_name = Tags_dict['Value'] if 'Name' in Tags_dict['Key'] else None

                    start_sched = Tags_dict['Value'] if 'auto:start' in Tags_dict['Key'] else None
                    stop_sched = Tags_dict['Value'] if 'auto:stop' in Tags_dict['Key'] else None

                    #print( 'Instances_name',Instances_name,'state',state,'start_sched',start_sched,'stop_sched',stop_sched,'instances',instances)

                    if start_sched != None and state == "stopped":
                        start_list.append(ec2_instances)

                    if stop_sched != None and state == "running":
                        stop_list.append(ec2_instances)

                #start instances
                if len(start_list) > 0:
                    print("%s Starting>  %s" % (now, start_list))
                    ret = ec2.start_instances(instance_ids=start_list, dry_run=False)
                    print("%s Started >  %s" % (now, ret))

                # stop instances
                if len(stop_list) > 0:
                    print("%s Stopping> %s" % (now, stop_list))
                    ret = ec2.stop_instances(instance_ids=stop_list, dry_run=False)
                    print("%s Stopped > %s" % (now, ret))

        except Exception as e:
            if "credentials" not in e.message:  # skip: AWS was not able to validate the provided access credentials
                print
                '%s Exception error in %s:%s %s => %s \n %s' % (now, regions, Instances_name, ec2_instances, e.message, e)

manager_instances()


