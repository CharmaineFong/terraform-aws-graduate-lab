# graduate-lab-jira-tickets

## CLI commands

Environment variable JIRA_TOKEN must be set with API key created at https://id.atlassian.com/manage-profile/security/api-tokens to run commands.

#### Load lab

```
python3 jira.py -u <username> -w https://<site-url>.atlassian.net --lab lab1
```

#### Validate setup

```
python3 jira.py -u <username> -w https://<site-url>.atlassian.net --validate
```

Command Line arguments:

"--username",   "-u",   "username (email) used to log into Jira"
"--webaddress", "-w"    "Jira site url (e.g. https://my-site.atlassian.net)
"--lab",        "-l",   "lab to load (e.g. lab1, lab2, ...)"
"--validate",           "Validate connectivity to Jira Site"


## Structure

To add additional labs, new folder should be created under tickets/json/ with the lab name and 2 .json files added: issues.json and project.json. 

* project.json should have two key value pairs: name and description.

* issues.json should have a list of objects of the following structure:
    ```    
    {
        "storyid": "1",
        "name": "my issue",
        "description": {
        "taskDescription": "As an engineer, I want to deploy a VPC so I can host instances inside a subnet",
        "acceptanceCriteria": [
            "Deploy VPC in eu-west-2 using terraform module",
            "Check VPC exists in console"
        ],
        "usefulLinks": [
            {
            "title": "Solution PR:",
            "href": "www.github.com",
            "hrefText": "Git"
            },
            {
            "title": "Some Other Link:",
            "href": "http://www.google.com",
            "hrefText": "google"
            }
        ]
        },
        "type": "story",
        "link": [
            {
                "type": "blocks",
                "idtolink": "1"
            }
        ]
    }
    ```

    Accepted "type" values are story, spike, bug, epic. storyid should be incremented for each issue added. Link takes a list of relation types to other issues. Accepted values are 'blocks', 'depends on' and 'relates to'


## Rest API

https://developer.atlassian.com/cloud/jira/platform/rest/v3/intro/#about
https://developer.atlassian.com/cloud/jira/software/rest/intro/#introduction

## Improvements

* Add test cases to allow refactoring and improvements
* Boards are created with defaults, add functionality for custom board of backlog - InProgress - Review - Complete
* Request object is passed to methods for them to make API calls which causes confusion when calling nested methods. Refactor this to simplify making API calls
* Comments! 
