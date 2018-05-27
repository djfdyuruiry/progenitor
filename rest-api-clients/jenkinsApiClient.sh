#! /usr/bin/env bash

########################################################################################################################
#                                                                                                                      #
# Jenkins API client written in Bash using the `wget` and `curl` commands                                              # 
# -----------------------------------------------------------------------                                              #
#                                                                                                                      #
# Using global configuration:                                                                                          #
#                                                                                                                      #
#   export JENKINS_URL="https://my-jenkins-server"                                                                     #
#   export JENKINS_USERNAME="SOME_USER"                                                                                #
#   export JENKINS_TOKEN="JFUDJ388474HDU"                                                                              #
#   export JENKINS_OPTS="--crsf-enabled" # optional, required if CRSF protection is enabled                            #
#                                                                                                                      #
#   . jenkinsApiClient.sh                                                                                              #
#                                                                                                                      #
#   # call client functions..                                                                                          #
#                                                                                                                      #
# Using local configuration:                                                                                           #
#                                                                                                                      #
#   . jenkinsApiClient.sh                                                                                              #
#                                                                                                                      #
#   initJenkinsClient "https://my-jenkins-server" "SOME_USER" "JFUDJ388474HDU"                                         #
#   # OR (if CRSF protection is enabled)                                                                               #
#   initJenkinsClient "https://my-jenkins-server" "SOME_USER" "JFUDJ388474HDU" --crsf-enabled                          #
#                                                                                                                      #
#   # call client functions...                                                                                         #
#                                                                                                                      #
# A usage check is provided for convience if you are using initJenkinsClient:                                          #
#                                                                                                                      #
#   assertParamsForJenkinsClientScript "$@"                                                                            #
#   initJenkinsClient $1 $2 $3 $4                                                                                      #
#                                                                                                                      #
# Client Functions:                                                                                                    #
#                                                                                                                      #
#   callJenkinsEndpoint         - Params: resourcePath [queryParams method body bodyMimetype(defaults to JSON)]        #
#                                 ex. callJenkinsEndpoint "/me/api/json" # get calling user details                    #
#                                                                                                                      #
#     Note: This function will url encode the body if the bodyMimetype is application/x-www-form-urlencoded            #
#                                                                                                                      #
#   executeJenkinsGroovyScript  - https://wiki.jenkins.io/display/JENKINS/Jenkins+Script+Console                       #
#                                                                                                                      #
########################################################################################################################

set -e

jenkinsUrl="${JENKINS_URL}"
jenkinsUsername="${JENKINS_USERNAME}"
jenkinsToken="${JENKINS_TOKEN}"
crsfFlag="${JENKINS_OPTS}"

_printJenkinsErrorAndExit() {
    >&2 echo "Jenkins Client | ERROR: $1"
    exit 1
}

_printMissingJenkinsVariableErrorAndExit() {
    _printJenkinsErrorAndExit "Please set the $1 env var or set it locally by calling initJenkinsClient"
}

_buildJenkinsApiUrl() {
    if [ -z "${jenkinsUrl}" ]; then
        _printMissingJenkinsVariableErrorAndExit "JENKINS_URL"
    fi

    if [ -z "${jenkinsUsername}" ]; then
        _printMissingJenkinsVariableErrorAndExit "JENKINS_USERNAME"
    fi

    if [ -z "${jenkinsToken}" ]; then
        _printMissingJenkinsVariableErrorAndExit "JENKINS_TOKEN"
    fi

    jenkinsUrlWithUserNameAndPassword=${jenkinsUrl/:\/\//:\/\/${jenkinsUsername}:${jenkinsToken}@}

    echo "${jenkinsUrlWithUserNameAndPassword}"
}

_buildJenkinsCrumbHeaderIfCrsfEnabled() {
    if [ "${crsfFlag}" != "--crsf-enabled" ]; then
        return
    fi

    wget -q --auth-no-challenge \
        --output-document - \
        "$(_buildJenkinsApiUrl)/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)"
}

_assertParameter() {
    functionName=${FUNCNAME[1]}
    parameterIndex=$1
    parameterName=$2
    parameterValue="$3"
  
    if [ -z "${parameterValue}" ]; then
        _printJenkinsErrorAndExit "${functionName} requires a missing parameter, #${parameterIndex} - ${parameterName}"
    fi
}

assertParamsForJenkinsClientScript() {
    if (( $# > 2)); then
        return
    fi

    jenkinsClientScript=$(basename ${BASH_SOURCE[1]})

    echo "Usage: ${jenkinsClientScript} jenkinsUrl jenkinsUsername jenkinsToken [jenkinsOpts]"
    echo "  example -> ${jenkinsClientScript} 'https://jenkins' 'USER' 'c999CJCDJ39' --crsf-enabled"
    
    exit 1
}

initJenkinsClient() {
    _assertParameter "1" "jenkinsUrl" "$1"
    _assertParameter "2" "jenkinsUsername" "$2"
    _assertParameter "3" "jenkinsToken" "$3"

    jenkinsUrl="$1"
    jenkinsUsername="$2"
    jenkinsToken="$3"
    crsfFlag="$4"
}

callJenkinsEndpoint() {
    _assertParameter "1" "resourcePath" "$1"

    urlEncodedQueryParams="$2"
    method="${3:-GET}"
    body="$4"
    bodyMimetype="${5:-application/json}"

    if [ ! -z "${urlEncodedQueryParams}" ]; then
        urlEncodedQueryParams="?${urlEncodedQueryParams}"
    fi

    if [ "${bodyMimeType}" == "application/x-www-form-urlencoded" ]; then
        curl -sS -H "$(_buildJenkinsCrumbHeaderIfCrsfEnabled)" \
            -H "Content-Type: ${bodyMimetype}" \
            --request "${method}" \
            --data-urlencode "${body}" \
            "$(_buildJenkinsApiUrl)$1${urlEncodedQueryParams}"
    else
        curl -sS -H "$(_buildJenkinsCrumbHeaderIfCrsfEnabled)" \
            -H "Content-Type: ${bodyMimetype}" \
            --request "${method}" \
            --data "${body}" \
            "$(_buildJenkinsApiUrl)$1${urlEncodedQueryParams}"
    fi
}

executeJenkinsGroovyScript() {
    _assertParameter "1" "groovyScript" "$1"

    callJenkinsEndpoint "/scriptText" "" "POST" \
        "script=println 'Starting Script via HTTP'; $1; println 'Script Finished'" \
        "application/x-www-form-urlencoded"     
}
