# https://learn.microsoft.com/en-us/azure/azure-functions/functions-bindings-storage-blob-trigger?tabs=python-v2%2Cisolated-process%2Cnodejs-v4%2Cextensionv5&pivots=programming-language-python
import logging
import azure.functions as func

app = func.FunctionApp()

@app.function_name(name="blobTrigger")
@app.blob_trigger(arg_name="myblob", path="inbox/{name}", connection="AzureWebJobsStorage")
def test_function(myblob: func.InputStream):
    logging.info("--------------------------> Python blob trigger function processed")
    logging.info("Python blob trigger function processed blob \nName: %s", myblob.name)
   #  logging.info("------->Python blob trigger function processed")