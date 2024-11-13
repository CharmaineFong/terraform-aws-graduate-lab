import argparse
import json, os, sys
import random
import string

class Utils:

    @staticmethod
    def parseCliArgs():
        labDir = os.listdir(os.path.dirname(__file__)+"/../json")

        argParser = argparse.ArgumentParser()
        argParser.add_argument("-u", "--username", required=True, help="username (email) used to log into Jira")
        argParser.add_argument("-w", "--webaddress",required=True, help="Jira site url (e.g. https://my-site.atlassian.net) ")
        argParser.add_argument("-l", "--lab",required='--validate' not in sys.argv, choices=labDir, help="lab to load (e.g. lab1, lab2, ...)")
        argParser.add_argument("--validate", action='store_true', required=False, help="Validate connectivity to Jira Site")
        argParser.add_argument("--destroy", action='store_true', required=False, help="Destroy lab")

        args = argParser.parse_args()
        
        return args

    @staticmethod
    def loadJsonToDict(fileName):
        file = open(fileName)
        fileDict = json.loads(file.read())

        return fileDict

    @staticmethod
    def uniqueKey(projectName):
        nameId = ''.join([ s[0] for s in projectName.split() ])
        randomLength = 10 - len(nameId)
        randomId = ''.join(random.choice(string.ascii_uppercase) for _ in range(randomLength))

        uniqueKey = f'{nameId}{randomId}'
        return uniqueKey

    @staticmethod
    def getProjectDict(projectFile):
        project = Utils.loadJsonToDict(projectFile)
        project["key"] = Utils.uniqueKey(project["name"])
        project["assigneeType"] = "UNASSIGNED"
        project["avatarId"] = 10200
        project["projectTemplateKey"] = "com.pyxis.greenhopper.jira:gh-simplified-kanban-classic"
        project["projectTypeKey"] = "software"

        return project

class Issues:
    def __init__(self, project, name, description, issueType):
        self.issueDict = {
            "fields": {
                "description": {
                    "content": description,
                    "type": "doc",
                    "version": 1
                },
                "issuetype": {
                    # "id": self.issueTypes[type]
                    "id": issueType
                },
                "priority": {
                    "id": "3"
                },
                "project": {
                    "id": project
                },
                "summary": name
            }
        }
    
    @staticmethod
    def formatDescription(description):  
        acceptanceCriteria = Issues.buildList(description["acceptanceCriteria"])
        usefulLinks = Issues.buildListLinks(description["usefulLinks"])

        formattedDescription = [
            {
                "type": "paragraph",
                "content": [
                    {
                        "type": "text",
                        "text": "Task Description:",
                        "marks": [{ "type": "strong" }, { "type": "underline" }]
                    }
                ]
            },
            {
                "type": "paragraph",
                "content": [
                    {
                        "type": "text",
                        "text": description["taskDescription"]
                    }
                ]
            },
            { "type": "rule" },
            {
                "type": "paragraph",
                "content": [
                    {
                        "type": "text",
                        "text": "Acceptance Criteria:",
                        "marks": [{ "type": "strong" }, { "type": "underline" }]
                    }
                ]
            },
            {
                "type": "bulletList",
                "content": acceptanceCriteria
            },
            { "type": "rule" },
            {
                "type": "paragraph",
                "content": [
                    {
                        "type": "text",
                        "text": "Useful Links:",
                        "marks": [{ "type": "strong" }, { "type": "underline" }]
                    }
                ]
            },
            {
                "type": "bulletList",
                "content": usefulLinks
            }
        ]
        return formattedDescription
    
    @staticmethod
    def buildList(listItems):  
        content = []

        for item in listItems:
            bullet = {
                "type": "listItem",
                "content": [
                    {
                    "type": "paragraph",
                    "content": [
                        {
                            "type": "text",
                            "text": item
                        }
                    ]
                    }
                ]
            }

            content.append(bullet)

        return content
    
    @staticmethod
    def buildListLinks(listItems):  
        content = []

        for item in listItems:
            bullet = {
                "type": "listItem",
                "content": [
                    {
                    "type": "paragraph",
                    "content": [
                        {
                            "type": "text",
                            "text": item["title"]
                        },
                        { "type": "text", "text": " " },
                        {
                            "type": "text",
                            "text": item["hrefText"],
                            "marks": [
                                {
                                    "type": "link",
                                    "attrs": { "href": item["href"] }
                                }
                            ]
                        }
                    ]
                    }
                ]
            }

            content.append(bullet)

        return content