from lib.jiraCommands import Jira
from lib.utils import Utils, Issues
import json, os, sys
import webbrowser

def setSpikeIssueType(x):
    payload = {
        "description": "Research or fact finding for completing a goal",
        "name": "Spike",
        "hierarchyLevel": "0"
    }

    spike = x.getIssueTypeByName("Spike")

    if spike == "no issue found":
        response = x.createIssueType(payload)
        createdIssue = x.setIssueType(payload["name"], response["id"])
    else:
        createdIssue = x.setIssueType(payload["name"], spike["id"])

    return createdIssue

def assignIssueTypeScheme(x, scheme):
    # Get ids of issues in jira and assign to object
    x.setIssueTypeIds()

    # check if exists, create if not
    schemeResponse = x.getIssueTypeSchemeByName(scheme["name"])

    if schemeResponse == "no scheme found":
        createdSchemeId = x.createIssueTypeScheme(scheme)
    else:
        createdSchemeId = schemeResponse["id"]

    return createdSchemeId

def setStoryDependencyLinks(x, issueLinks):

    issueLinkTypes = x.getAllIssueLinkTypes()
    print(issueLinkTypes)
    if not any(d['name'] == issueLinks["name"] for d in issueLinkTypes["issueLinkTypes"]):
        print("not found")
        x.createIssueLinkTypes(issueLinks)

    return

def destroy(args):
    x = Jira(args.webaddress, args.username)
    lab_directory = os.path.dirname(__file__)+"/json/"+args.lab
    lab_project = Utils.getProjectDict(lab_directory+"/project.json")
    issueLinks = Utils.loadJsonToDict(os.path.dirname(__file__)+"/lib/json/jiraIssueLinks.json")

    # allIssueLinkTypes = x.getAllIssueLinkTypes()
    # for linkTypes in allIssueLinkTypes["issueLinkTypes"]:
    #     if linkTypes["name"] == issueLinks["name"]:
    #         print(x.deleteIssueLinkTypes(linkTypes["id"]))
            
    project = x.getProjectByName(lab_project["name"])
    
    # projectSchemes = x.getIssueTypeSchemeForProject(project["id"])
    # for scheme in projectSchemes:
    #     x.deleteIssueTypeSchemeByName(scheme['issueTypeScheme']["name"])

    allIssueTypeSchemes = x.getAllIssueTypeSchemes()
    for scheme in allIssueTypeSchemes["values"]:
        if project["key"] in scheme["name"]:
            x.deleteIssueTypeSchemeByName(scheme["name"])

    # print(x.deleteIssueTypeByName("Spike"))
    print(x.deleteProjectByName(lab_project["name"]))


def create(args):
    x = Jira(args.webaddress, args.username)
    x.getAuthenticatedUser()
    
    # setup project
    lab_directory = os.path.dirname(__file__)+"/json/"+args.lab
    lab_project = Utils.getProjectDict(lab_directory+"/project.json")
    issues =  Utils.loadJsonToDict(lab_directory+"/issues.json")

    # print("Creating project...")
    x.createProject(lab_project)

    # create spike issue type 
    setSpikeIssueType(x)
    
    # create custom issue type scheme
    scheme = Utils.loadJsonToDict(os.path.dirname(__file__)+"/lib/json/jiraIssueTypeScheme.json")
    issueSchemeId = assignIssueTypeScheme(x, scheme)
    
    # assign issue type scheme to project
    x.linkIssueTypesToProject(issueSchemeId, x.project["projectId"])
    
    # # add custom issue dependency links
    issueLinks = Utils.loadJsonToDict(os.path.dirname(__file__)+"/lib/json/jiraIssueLinks.json")
    setStoryDependencyLinks(x, issueLinks)

    # Build and create Issue stories
    if len(issues) != len({issue['storyid']:issue for issue in issues}.values()):
        print("Duplicate issue storyIds detected. check ids before continuing")
        sys.exit(1)

    issuesDict = {
        "issueUpdates": []
    }

    for issue in issues:
        formattedDescription = Issues.formatDescription(issue["description"])
        newIssue = Issues(x.project["projectId"],issue["name"],formattedDescription,x.issueTypes[issue["type"]])
        issuesDict["issueUpdates"].append(newIssue.issueDict)

    createdIssues = x.createProjectIssues(issuesDict)

    # build response issue keys into issue dict 
    for i in range(len(createdIssues["issues"])):
        issues[i]["key"] = createdIssues["issues"][i]["key"]

    x.addIssueDependencies(issues)

    print("Finished Successfully")

    webbrowser.open(f'{args.webaddress}/browse/{x.project["key"]}')

if __name__ == "__main__":

    if "JIRA_TOKEN" not in os.environ:
        print("JIRA_TOKEN environment variable is not set. See README.md for info")
        sys.exit(1)

    if os.environ.get("JIRA_TOKEN") == "":
        print("JIRA_TOKEN environment variable is empty. See README.md for info")
        sys.exit(1)

    args = Utils.parseCliArgs()

    if args.validate:
        x = Jira(args.webaddress, args.username)
        print(x.validateConnection())
    elif args.destroy:
        destroy(args)
    else:
        create(args)