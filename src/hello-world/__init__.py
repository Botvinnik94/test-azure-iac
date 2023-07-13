import logging

import azure.functions as func
from azure.identity import DefaultAzureCredential
from azure.storage.blob import BlobServiceClient


def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    try:
        # Use DefaultAzureCredential to authenticate using the Managed Identity
        credential = DefaultAzureCredential()

        # Connect to the Azure Storage Account
        storage_account_name = ""
        blob_service_client = BlobServiceClient(account_url=f"https://{storage_account_name}.blob.core.windows.net", credential=credential)

        # Get the blob container and blob name
        container_name = ""
        blob_name = "hello-world.txt"

        # Retrieve the blob content
        blob_client = blob_service_client.get_blob_client(container=container_name, blob=blob_name)
        blob_content = blob_client.download_blob().readall()

        return func.HttpResponse(body=blob_content, mimetype="text/plain")

    except Exception as e:
        logging.error(e)
        return func.HttpResponse("An error occurred", status_code=500)
