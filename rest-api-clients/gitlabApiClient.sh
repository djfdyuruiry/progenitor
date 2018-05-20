#!/bin/bash

########################################################################################################################
#                                                                                                                      #
# GitLab API client written in Bash using the `curl` command                                                           # 
# -----------------------------------------------------------                                                          #
#                                                                                                                      #
# Using global configuration:                                                                                          #
#                                                                                                                      #
#   export GITLAB_URL="https://my-gitlab-server"                                                                       #
#   export GITLAB_TOKEN="JFUDJ388474HDU"                                                                               #
#   export GITLAB_API_VERSION="v4" # optional (default is v4)                                                          #
#                                                                                                                      #
#   . gitlabApiClient.sh                                                                                               #
#                                                                                                                      #
#   # call client functions..                                                                                          #
#                                                                                                                      #
# Using local configuration:                                                                                           #
#                                                                                                                      #
#   . gitlabApiClient.sh                                                                                               #
#                                                                                                                      #
#   initGitlabClient "https://my-gitlab-server" "JFUDJ388474HDU"                                                       #
#   # OR                                                                                                               #
#   initGitlabClient "https://my-gitlab-server" "JFUDJ388474HDU" "v4" # specify API version, optional (default is v4)  #
#                                                                                                                      #
#   # call client functions...                                                                                         #
#                                                                                                                      #
# A usage check is provided for convience if you are using initGitlabClient:                                           #
#                                                                                                                      #
#   assertParamsForGitlabClientScript "$@"                                                                             #
#   initGitlabClient $1 $2 $3                                                                                          #
#                                                                                                                      #
# Client Functions:                                                                                                    #
#                                                                                                                      #
#   callGitlabEndpoint    - Params: resourcePath [queryParams method body bodyMimetype(defaults to JSON)]              #
#                             ex. callGitlabEndpoint "/users" "active=true" # get active users                         #
#                                                                                                                      #
#     Note: This function will url encode the body if the bodyMimetype is application/x-www-form-urlencoded            #
#                                                                                                                      #
#   getGitlabProject      - https://docs.gitlab.com/ee/api/projects.html#get-single-project                            #
#   getGitlabProjectHooks - https://docs.gitlab.com/ee/api/projects.html#get-project-hook                              #
#   addGitlabProjectHook  - https://docs.gitlab.com/ee/api/projects.html#add-project-hook                              #
#                                                                                                                      #
########################################################################################################################

set -e

defaultGitlabApiVersion="v4"

gitlabUrl="${GITLAB_URL}"
gitlabApiVersion="${GITLAB_API_VERSION:-$defaultGitlabApiVersion}"
gitlabToken="${GITLAB_TOKEN}"

_buildGitlabApiUrl() {
    if [ -z "${gitlabUrl}" ]; then
        _printMissingGitlabVariableErrorAndExit "GITLAB_URL"
    fi

    echo "${gitlabUrl}/api/${gitlabApiVersion}"
}

_buildGitlabProjectUrl() {
    urlEncodedGitlabProject="${1/\//%2F}"
    echo "$(_buildGitlabApiUrl)/projects/${urlEncodedGitlabProject}"
}

_printGitlabErrorAndExit() {
    >&2 echo "Gitlab Client | ERROR: $1"
    exit 1
}

_printMissingGitlabVariableErrorAndExit() {
    _printGitlabErrorAndExit "Please set the $1 env var or set it locally by calling initGitlabClient"
}

_buildGitLabTokenHeader() {
    if [ -z "${gitlabToken}" ]; then
        _printMissingGitlabVariableErrorAndExit "GITLAB_TOKEN"
    fi

    echo "PRIVATE-TOKEN: ${gitlabToken}"
}

_assertParameter() {
    functionName=${FUNCNAME[1]}
    parameterIndex=$1
    parameterName=$2
    parameterValue="$3"
  
    if [ -z "${parameterValue}" ]; then
        _printGitlabErrorAndExit "${functionName} requires a missing parameter, #${parameterIndex} - ${parameterName}"
    fi
}

assertParamsForGitlabClientScript() {
    if (( $# > 1)); then
        return
    fi

    gitlabClientScript=$(basename ${BASH_SOURCE[1]})

    echo "Usage: ${gitlabClientScript} gitlabUrl gitlabToken"
    echo "  example -> ${gitlabClientScript} 'https://gitlab' 'NJSKF938t49FIJJc'"
    
    exit 1
}

initGitlabClient() {
    _assertParameter "1" "gitlabUrl" "$1"
    _assertParameter "2" "gitlabToken" "$2"

    gitlabUrl="$1"
    gitlabToken="$2"
    gitlabApiVersion="${3:-$defaultGitlabApiVersion}"
}

callGitlabEndpoint() {
    _assertParameter "1" "resourcePath" "$1"

    queryParams="$2"
    method="${3:-GET}"
    body="$4"
    bodyMimetype="${5:-application/json}"

    if [ ! -z "${queryParams}" ]; then
        queryParams="?${queryParams}"
    fi

    if [ "${bodyMimeType}" == "application/x-www-form-urlencoded" ]; then
        curl -sS -H "$(_buildGitLabTokenHeader)" \
            -H "Content-Type: ${bodyMimetype}" \
            --request "${method}" \
            --data-urlencode "${body}" \
            "$(_buildGitlabApiUrl)$1${queryParams}"
    else
        curl -sS -H "$(_buildGitLabTokenHeader)" \
            -H "Content-Type: ${bodyMimetype}" \
            --request "${method}" \
            --data "${body}" \
            "$(_buildGitlabApiUrl)$1${queryParams}"
    fi
}

getGitlabProject() {
    _assertParameter "1" "projectName" "$1"

    callGitlabEndpoint "$(_buildGitlabProjectUrl $1)"
}

getGitlabProjectHooks() {
    _assertParameter "1" "projectName" "$1"

    callGitlabEndpoint "$(_buildGitlabProjectUrl $1)/hooks"
}

addGitlabProjectHook() {
    _assertParameter "1" "projectName" "$1"
    _assertParameter "2" "hookJson" "$2"

    callGitlabEndpoint "$(_buildGitlabProjectUrl $1)/hooks"  "" "POST" "$2"
}
