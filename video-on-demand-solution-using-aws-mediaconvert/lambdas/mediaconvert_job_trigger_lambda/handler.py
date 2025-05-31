#!/usr/bin/env python

import json
import os
import boto3


def lambda_handler(event, context):
    source_s3_bucket = event["Records"][0]["s3"]["bucket"]["name"]
    source_s3_key = event["Records"][0]["s3"]["object"]["key"]
    source_s3 = "s3://"+ source_s3_bucket + "/" + source_s3_key
    source_s3_base_name = os.path.splitext(os.path.basename(source_s3))[0]
    destination_s3 = "s3://" + os.environ["OUTPUT_BUCKET"] + "/output"
    media_convert_role = os.environ["MEDIA_CONVERT_ROLE_ARN"]
    region = os.environ["DEFAULT_AWS_REGION"]

    # Use MediaConvert SDK UserMetadata to tag jobs with the asset_id 
    # Events from MediaConvert will have the asset_id in UserMedata
    job_meta_data = {"env": os.environ["ENV"]}
    
    try:
        # Job settings are in the lambda zip file in the current working directory
        with open("job.json") as json_data:
            job_settings = json.load(json_data)

        # get the account-specific mediaconvert endpoint for this region
        mc_client = boto3.client("mediaconvert", region_name=region)
        endpoints = mc_client.describe_endpoints()

        # add the account-specific endpoint to the client session 
        client = boto3.client("mediaconvert", region_name=region, endpoint_url=endpoints["Endpoints"][0]["Url"], verify=False)

        job_settings["Inputs"][0]["FileInput"] = source_s3
        job_settings["OutputGroups"][0]["OutputGroupSettings"]["FileGroupSettings"]["Destination"] = destination_s3 + "/" + source_s3_base_name + "-high"
        job_settings["OutputGroups"][1]["OutputGroupSettings"]["FileGroupSettings"]["Destination"] = destination_s3 + "/" + source_s3_base_name + "-low"

        job = client.create_job(Role=media_convert_role, UserMetadata=job_meta_data, Settings=job_settings)

    except Exception as e:
        print ("Exception: %s" % e)
