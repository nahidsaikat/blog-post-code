#!/usr/bin/env python

def lambda_handler(event, context):
    result = 'Success'

    # Send email or notification

    return {
        'statusCode' : 200,
        'body': result
    }
