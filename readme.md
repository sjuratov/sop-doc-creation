<center><img src="./images/sop.jpg" width="150" ></center>

# VANTAGE Genie Accelerator

MENU: [**USER STORY**](#user-story) \| [**SCENARIOS**](#scenarios)  \| [**SUPPORTING DOCUMENTS**](#supporting-documents) \|
[**CUSTOMER TRUTH**](#customer-truth)


<h2><img src="./images/userStory.png" width="64">
<br/>
User story
</h2>

**Solution accelerator overview**

The VANTAGE Genie Accelerator offers a transformative approach to creating Standard Operating Procedures (SOPs) by leveraging generative AI (genAI) technology. Traditionally, SOPs are detailed documents that outline the "who," "when," and "what" of business processes, ensuring reproducibility, knowledge transfer, error avoidance, production optimization, and regulatory compliance. However, the manual creation of these documents presents challenges such as transcription inaccuracies, difficulties in standardization, and issues with searchability, retrieval, and ongoing maintenance.

Our solution addresses these challenges by automating the SOP creation process through video recordings. By converting videos into precise and standardized SOP documents, VANTAGE Genie Accelerator ensures unparalleled accuracy and efficiency. This automation not only streamlines the transcription process but also enhances the consistency and reliability of SOPs across various business operations.

The outcomes of implementing the VANTAGE Genie Accelerator are significant. Businesses can expect substantial time savings in process documentation, improved knowledge transfer and onboarding procedures, and reduced scrap through enhanced accuracy. Overall, the solution optimizes business processes, ensuring that critical operational knowledge is preserved and easily accessible.

<h2>
Scenario
</h2>


### Operations Manager

The VANTAGE Genie Accelerator is tailored for Operations Managers who are responsible for maintaining and optimizing business processes within their organizations. This solution helps Operations Managers save time by automating the creation of SOP documents from video recordings of procedures. For example, an Operations Manager at a manufacturing plant can use the VANTAGE Genie Accelerator to convert a recorded training session on machinery operation into a detailed and standardized SOP document. This ensures that all employees have access to consistent and accurate procedural guidelines, enhancing knowledge transfer, reducing errors, and improving overall operational efficiency.

<h2>
VANTAGE Genie Accelerator Processing Steps
</h2>
<div style="display: flex; justify-content: center; align-items: center;">
    <img src="./images/sop_steps.jpg"/>
</div>

<h2>
VANTAGE Genie Accelerator Architecture
</h2>
<div style="display: flex; justify-content: center; align-items: center;">
    <img src="./images/sop_architecture.jpg"/>
</div>





<h2>
Implementation overview
</h2>

The application is implemented using Streamlit framework.

Azure infrastructure required to run this accelerator can be deployed by using azd or Deploy-to-Azure button.

Once infrastructure is deployed, required environment variables are saved to .azure/<env_name>/.env file.  This file is read by load_dotenv and used in the Streamlit application.

Alternatively, if the pre existing resources need to be used, manually configure .env file.

<h2>
Prerequisites
</h2>

- Install [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)

- Install [Azure Developer CLI](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd)

- On Windows install the [Platform PowerShell](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.4)

    - **Note** You MUST install Platform PowerShell; Windows PowerShell is not sufficient.
    
- Login to your tentnant with Azure CLI `az login`

<h2>
Deploy the infrastructure using azd (substitute switzerlandnorth with region relevant to you)
</h2>

```sh
azd env set AZURE_LOCATION 'switzerlandnorth'
azd up
```

**Note** 'Deploying services (azd deploy)' stage can take up to 15 min.

<h2>
ENV Variables
</h2>

The env variables are read from the azd config file located at:

```
.azure/<env_name>/.env
```

If azd has not been executed, the application will try to source the standard .env file.

<h3>
Azure Speech services environment variables
</h3>

AZURE_SPEECH_ACCOUNT_NAME

AZURE_SPEECH_KEY

AZURE_SPEECH_REGION

<h3>
Azure OpenAI environment variables
</h3>

AZURE_OPENAI_ACCOUNT_NAME

AZURE_OPENAI_DEPLOYMENT_NAME

AZURE_OPENAI_ENDPOINT

AZURE_OPENAI_KEY

<h2>
Run application as follow 
</h2>

```
cd src/frontend
streamlit run streamlit_app.py
```











<h2><img src="./images/supportingDocuments.png" width="64">
<br/>
Supporting documents
</h2>

Supporting documents coming soon.

<br>
<h2><img src="./images/customerTruth.png" width="64">
</br>
Customer truth
</h2>
Customer stories coming soon.

<h2>
</br>
Responsible AI Transparency FAQ 
</h2>

Please refer to [Transarency FAQ](./TRANSPARENCY_FAQ.md) for responsible AI transparency details of this solution accelerator.

<br/>
<br/>
---

## Disclaimers

This release is an artificial intelligence (AI) system that generates text based on user input. The text generated by this system may include ungrounded content, meaning that it is not verified by any reliable source or based on any factual data. The data included in this release is synthetic, meaning that it is artificially created by the system and may contain factual errors or inconsistencies. Users of this release are responsible for determining the accuracy, validity, and suitability of any content generated by the system for their intended purposes. Users should not rely on the system output as a source of truth or as a substitute for human judgment or expertise. 

This release only supports English language input and output. Users should not attempt to use the system with any other language or format. The system output may not be compatible with any translation tools or services, and may lose its meaning or coherence if translated. 

This release does not reflect the opinions, views, or values of Microsoft Corporation or any of its affiliates, subsidiaries, or partners. The system output is solely based on the system's own logic and algorithms, and does not represent any endorsement, recommendation, or advice from Microsoft or any other entity. Microsoft disclaims any liability or responsibility for any damages, losses, or harms arising from the use of this release or its output by any user or third party. 

This release does not provide any financial advice, and is not designed to replace the role of qualified client advisors in appropriately advising clients. Users should not use the system output for any financial decisions or transactions, and should consult with a professional financial advisor before taking any action based on the system output. Microsoft is not a financial institution or a fiduciary, and does not offer any financial products or services through this release or its output. 

This release is intended as a proof of concept only, and is not a finished or polished product. It is not intended for commercial use or distribution, and is subject to change or discontinuation without notice. Any planned deployment of this release or its output should include comprehensive testing and evaluation to ensure it is fit for purpose and meets the user's requirements and expectations. Microsoft does not guarantee the quality, performance, reliability, or availability of this release or its output, and does not provide any warranty or support for it. 

This Software requires the use of third-party components which are governed by separate proprietary or open-source licenses as identified below, and you must comply with the terms of each applicable license in order to use the Software. You acknowledge and agree that this license does not grant you a license or other right to use any such third-party proprietary or open-source components.  

To the extent that the Software includes components or code used in or derived from Microsoft products or services, including without limitation Microsoft Azure Services (collectively, “Microsoft Products and Services”), you must also comply with the Product Terms applicable to such Microsoft Products and Services. You acknowledge and agree that the license governing the Software does not grant you a license or other right to use Microsoft Products and Services. Nothing in the license or this ReadMe file will serve to supersede, amend, terminate or modify any terms in the Product Terms for any Microsoft Products and Services. 

You must also comply with all domestic and international export laws and regulations that apply to the Software, which include restrictions on destinations, end users, and end use. For further information on export restrictions, visit https://aka.ms/exporting. 

You acknowledge that the Software and Microsoft Products and Services (1) are not designed, intended or made available as a medical device(s), and (2) are not designed or intended to be a substitute for professional medical advice, diagnosis, treatment, or judgment and should not be used to replace or as a substitute for professional medical advice, diagnosis, treatment, or judgment. Customer is solely responsible for displaying and/or obtaining appropriate consents, warnings, disclaimers, and acknowledgements to end users of Customer’s implementation of the Online Services. 

You acknowledge the Software is not subject to SOC 1 and SOC 2 compliance audits. No Microsoft technology, nor any of its component technologies, including the Software, is intended or made available as a substitute for the professional advice, opinion, or judgement of a certified financial services professional. Do not use the Software to replace, substitute, or provide professional financial advice or judgment.  

BY ACCESSING OR USING THE SOFTWARE, YOU ACKNOWLEDGE THAT THE SOFTWARE IS NOT DESIGNED OR INTENDED TO SUPPORT ANY USE IN WHICH A SERVICE INTERRUPTION, DEFECT, ERROR, OR OTHER FAILURE OF THE SOFTWARE COULD RESULT IN THE DEATH OR SERIOUS BODILY INJURY OF ANY PERSON OR IN PHYSICAL OR ENVIRONMENTAL DAMAGE (COLLECTIVELY, “HIGH-RISK USE”), AND THAT YOU WILL ENSURE THAT, IN THE EVENT OF ANY INTERRUPTION, DEFECT, ERROR, OR OTHER FAILURE OF THE SOFTWARE, THE SAFETY OF PEOPLE, PROPERTY, AND THE ENVIRONMENT ARE NOT REDUCED BELOW A LEVEL THAT IS REASONABLY, APPROPRIATE, AND LEGAL, WHETHER IN GENERAL OR IN A SPECIFIC INDUSTRY. BY ACCESSING THE SOFTWARE, YOU FURTHER ACKNOWLEDGE THAT YOUR HIGH-RISK USE OF THE SOFTWARE IS AT YOUR OWN RISK.  
