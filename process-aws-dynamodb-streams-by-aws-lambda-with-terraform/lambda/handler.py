import logging

LOGGER = logging.getLogger()
LOGGER.setLevel(logging.INFO)


def handler(event, context):
    for record in event['Records']:
        LOGGER.info(record['eventID'])
        LOGGER.info(record['eventName'])
        LOGGER.info(record['dynamodb'])
    return event
