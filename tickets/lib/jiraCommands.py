from lib.utils import Utils, Issues
import requests
from requests.auth import HTTPBasicAuth
import json
import os

class Jira:

    def __init__(self, webaddress, username):
        self.auth = JiraApi(
            webaddress,
            username
        )
        self.issueTypes = {}

    def getAuthenticatedUser(self):
        user = self.auth.getRequest("myself")
        self.accountId = user["accountId"]
        return user

    def validateConnection(self):
        user = self.getAuthenticatedUser()
        resp = f"Connectivity to {user['self']} successful"
        return resp

    # project
    def createProject(self, project):
        project["leadAccountId"] = self.accountId

        resp = self.auth.createRequest(
            "POST", 
            "project", 
            project
        )

        # add response project id to dict
        project["projectId"] = resp["id"]
        
        self.project = project

        return project

    def deleteProjectByName(self, labName):
        project = self.getProjectByName(labName)
        
        resp = self.auth.delRequest(f"project/{project['key']}?enableUndo=false")
        return resp
    
    def getProjectByName(self, labName):
        all_projects = self.getAllProjects()

        for project in all_projects["values"]:
            if labName in project.values():
                return project

        return "no project found"
        
    def getAllProjects(self):
        resp = self.auth.getRequest("project/search")
        return resp

    # issue type schemes
    def createIssueTypeScheme(self, scheme):
        issueTypeIds = self.setIssueTypeIds()

        scheme["issueTypeIds"] = list(issueTypeIds.values())
        scheme["defaultIssueTypeId"] = issueTypeIds['story']

        resp = self.auth.createRequest(
            "POST", 
            "issuetypescheme", 
            scheme
        )

        return resp["issueTypeSchemeId"]

    def deleteIssueTypeSchemeByName(self, schemeName):
        scheme = self.getIssueTypeSchemeByName(schemeName)

        resp = self.auth.delRequest(f"issuetypescheme/{scheme["id"]}")
        return resp

    def getIssueTypeSchemeByName(self, schemeName):
        allSchemes = self.getAllIssueTypeSchemes()

        for scheme in allSchemes["values"]:
            if schemeName in scheme.values():
                return scheme
        return "no scheme found"

    def getAllIssueTypeSchemes(self):
        resp = self.auth.getRequest("issuetypescheme")
        return resp
    
    def getIssueTypeSchemeForProject(self, projectId):
        query = {
            'projectId': projectId
        }
        resp = self.auth.getRequest("issuetypescheme/project", query)

        return resp["values"]

    # issue types
    def setIssueType(self, key, value):
        self.issueTypes[key] = value
        
        return self.issueTypes

    def getAllIssueTypesForUser(self):
        resp = self.auth.getRequest("issuetype")
        return resp

    def setIssueTypeIds(self, issueTypes = dict(story = "", bug = "")):
        allIssueTypes = self.getAllIssueTypesForUser()

        for item in allIssueTypes:
            for key in item:
                if key == 'name' and item[key].lower() in issueTypes and issueTypes[item[key].lower()] == "":
                    x = item[key].lower()
                    issueTypes.update( {x:item['id']} ) 
        
        self.issueTypes = self.issueTypes | issueTypes
        print(f"Updated issue type ids: {self.issueTypes}")

        return self.issueTypes
    
    def createIssueType(self, issueDetails = dict(description = "", name = "", hierarchyLevel = "")):
        resp = self.auth.createRequest(
            "POST", 
            "issuetype", 
            issueDetails
        )
        print(resp)
        return resp
        # self.issueTypes[issueDetails["name"]] = resp["id"]

        # return self.issueTypes

    def getIssueTypeByName(self, issueName):
        allIssueTypes = self.getAllIssueTypesForUser()

        for issue in allIssueTypes:
            if issueName in issue.values():
                return issue
        return "no issue found"

    def deleteIssueTypeByName(self, issueName):
        issue = self.getIssueTypeByName(issueName)

        resp = self.auth.delRequest(f"issuetype/{issue["id"]}")
        return resp

    # misc
    def addIssueDependencies(self, issues):
        #create issue links 
        responses = []
        for issue in issues:
            if "link" in issue:
                for link in issue["link"]:
                    linkedIssue = (next(item for item in issues if item["storyid"] == link["idtolink"]))

                    resp = self.auth.createRequest(
                        "POST", 
                        "issueLink", 
                        {
                            "inwardIssue": {
                                "key": issue["key"]
                            },
                            "outwardIssue": {
                                "key": linkedIssue["key"]
                            },
                            "type": {
                                "name": link["type"].title()
                            }
                        }
                    )

                    responses.append(resp)
        
        return responses

    def linkIssueTypesToProject(self, issueTypesId, projectId):
        resp = self.auth.createRequest(
            "PUT", 
            "issuetypescheme/project", 
            {
                "issueTypeSchemeId": issueTypesId,
                "projectId": projectId
            }
        )

        return resp

    def createIssueLinkTypes(self, issueLinks):  
        resp = self.auth.createRequest(
            "POST", 
            "issueLinkType", 
            issueLinks
        )

        return resp
    
    def deleteIssueLinkTypes(self, linkId):
        resp = self.auth.delRequest(f"issueLinkType/{linkId}")
        return resp

    def getAllIssueLinkTypes(self):
        resp = self.auth.getRequest("issueLinkType")
        return resp

    def createProjectIssues(self, issuesDict):
        resp = self.auth.createRequest(
            "POST", 
            "issue/bulk", 
            issuesDict
        )
        print("Issues Created:", resp)
        
        return resp

class JiraApi:
    def __init__(self, site_url, username):
        self.site_url = site_url
        self.username = username
        self.response = ""

    def __str__(self):
        return f"{self.site_url}, {self.username}, {self.response}"

    @staticmethod
    def auth(username):
        auth = HTTPBasicAuth(username, os.environ['JIRA_TOKEN']) 
        return auth

    @staticmethod
    def requestUrl(site_url, requestParams):
        url = f"{site_url}/rest/api/3/{requestParams}"
        return url
    
    def getRequest(self, requestParams, query=None):
        auth = JiraApi.auth(self.username)
        url = JiraApi.requestUrl(self.site_url, requestParams)

        headers = {
            "Accept": "application/json"
        }

        response = requests.request(
            "GET",
            url,
            headers=headers,
            auth=auth,
            params=query
        )

        self.response = json.loads(response.text)
        return self.response

    def delRequest(self, requestParams):
        auth = JiraApi.auth(self.username)
        url = JiraApi.requestUrl(self.site_url, requestParams)

        response = requests.request(
            "DELETE",
            url,
            auth=auth
        )

        return response

    def createRequest(self, requestType, requestParams, payload):
        auth = JiraApi.auth(self.username)
        url = JiraApi.requestUrl(self.site_url, requestParams)

        headers = {
            "Accept": "application/json",
            "Content-Type": "application/json"
        }

        response = requests.request(
            requestType,
            url,
            data=json.dumps(payload),
            headers=headers,
            auth=auth
        )

        if response.text != "":
            self.response = json.loads(response.text)
            return json.loads(response.text)
        return response