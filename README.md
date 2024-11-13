# terraform-aws-graduate-lab-template

## Intro

These Labs are designed to replicate potential architectures encountered on Airwalk Projects. Each lab has an architecture diagram and set of accompanying Jira tickets which outline the requirements and tasks needed to build out the design. The lab infrastructure should be written using Terraform and deployed to an AWS Sandbox account. 

This repo serves as a starting point for each lab and a new repo should be created in a personal Github account for each of the labs using this template. A sibling repo [terraform-aws-graduate-lab-solutions](https://github.com/AirWalk-Digital/terraform-aws-graduate-lab-solutions) has been created which mirrors the structure of this repo and holds a completed solution which can be referenced as a guide when needed. To get the most out of the labs, this repo should only be referenced as a last option as there won't necessarily be a solution available to view on a client project!


## Requirements

The labs are setup assuming the following are already configured on your machine:

    * AWS CLI
    * Terraform CLI
    * Git CLI
    * AWS SSO config

To view the created Jira tickets, a free Atlassian account is needed. Instructions for setting up access can be found [here](docs/JIRA.md)


## Getting Started

* Create new repo from this template
* Create PythonEnv, navigate to tickets dir and install pip dependencies from requirements.txt, then run python script jira.py for desired lab (Full command list [here](tickets/README.md))
* Create infrastructure for related lab based on Lab Diagram and README.md in architecture folder, and Jira tickets deployed from tickets dir


## Folder Strucuture

### terraform

This is the main working folder and any terraform code/lab files should be added here. The folder structure is set up typical of what is used on projects however depending on the lab not all folders/files may be needed so the structure can be amended as necessary. When writing terraform code, a standard branching strategy should be followed and PRs raised on completion of a feature before merging into main. Information on this along with other useful guides can be found on the following links:

##### Suggested
* [Airwalk Branching Strategies](https://airview.airwalkconsulting.io/knowledge/infrastructure_as_code_lhynoxvg/_index.md)
* [Iac Terraform Style Guide](https://airview.airwalkconsulting.io/knowledge/terraform_style_guide/_index.md)
* [IaC Terraform AWS Backend State](https://airview.airwalkconsulting.io/knowledge/terraform_aws_backend_state_li2zif10/_index.md)
* [IaC Code Review](https://airview.airwalkconsulting.io/knowledge/code_review_li5t4xvr/_index.md)

##### Optional
* [IaC Versioning Strategy](https://airview.airwalkconsulting.io/knowledge/versioning_and_release_lhz0d2me/_index.md)
* [IaC Deployment Workflow](https://airview.airwalkconsulting.io/knowledge/deployment_workflow_lhynwyip/_index.md)
* [IaC Environment Strategy](https://airview.airwalkconsulting.io/knowledge/environment_strategy_lhynw9dp/_index.md)


The README.md file inside this folder has information on terraform commands to initialise and run each layer. This is also where additional information that is required to sucessfully complete a deploy should be added when building out the lab.

#### layers

Terraform code on larger projects is often organised into layers to split up large code bases, reducing deployment times and allowing infrastructure to be deployed seperately as needed. Layer names can differ between projects however the should be named to suit the role it plays in the overall infrastructure. 

For these labs the Base layer is used to hold core infrastructure - hosted zones, VPCs, etc and the App layer for application specific code such as EC2 instances, website code, etc. 

Each layer has the following blank .tf files that are required for each lab:
* backend.tf - stores the reference to the backend config inside the environment layer
* outputs.tf - stores outputs following a terraform plan/apply
* providers.tf - stores any needed providers configuration
* variables.tf - stores variables for the layer

These files should be populated as needed, with additional .tf files added as required. Any code written here should work across multiple environments, with environment specific code being added inside the environment folder.

#### environment

Projects will typically have multiple accounts for each environment (Dev, Prod, UAT, etc). Backend configuration and variables will likely differ between environments, so this folder is used to store the terraform backend config and tvars for each environment and the layer it relates to.

#### bootstrap

On first-time deployment into a new account, the code in this directory will create your state bucket and dynamodb locking table (which you can then reference in your backend config). On apply a variable prompt will appear asking for the lab_name which is added to the S3 bucket name to ensure unique naming.


### architecture

The architecture folder holds the architecture diagram for each lab, with the README.md file detailing the scenario requirements for completing the lab not shown in the diagram. The diagrams illustrate what services are required, where they should be deployed and how services connect to each other.


### src

Lab specific application code is added to the src folder and are typically website files, lambda scripts, etc. Files here should not be directly referenced and instead copied to the terraform folder inside the relevant layer.

### tickets

The contents of this folder are responsible for deploying the tickets for each lab. Once an Atlassian account has been configured, the python script jira.py will deploy tickets for each lab to the Jira site. Full details for deploying tickets and using the python scripts can be found [here](tickets/README.md). 

The python script should be run each time a new lab is started to deploy the tickets. The tickets consist of the following types:
* Epics - Provide an overview for the whole project and any requirements
* Story - Details the task to be completed, along with acceptance criteria, useful links and reference to a solution PR if necessary.
* Bug - Information on an issue in existing infrastructure that needs to be fixed.
* Spike - Research task to aid in completion of another task

Tickets can mostly be completed in any order however some tickets may have a `depends on` attribute linking it to another ticket which will need to be completed before progressing that item. 

Additional tickets can and should be created. This can be for reasons such as additional stories to add functionality, or tasks/spikes to find information on how to complete a story. Any work to complete the lab that's not already ticketed, should be!
