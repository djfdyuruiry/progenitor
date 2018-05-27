#! /usr/bin/env bash
set -e

scriptPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

localPlaygroundRootUrl="http://localhost:5050"
localPlaygroundExecuteUrl="${localPlaygroundRootUrl}/execute"
processPlaygroundResponseScriptPath="${scriptPath}/processDslPlaygroundResponse.py"

dslScriptPath="${1}"
cleanupPlaygroundsFlag="${2}"
cleanupPlaygroundsFlagValue="--cleanup-playgrounds"

dslScriptFileName=$(basename ${dslScriptPath})
dslScriptName=${dslScriptFileName%%.*}

getPlaygroundDockerContainers() {
    docker ps -a -q --filter ancestor=${playgroundDockerImage} --format="{{.ID}}"
}

shutdownPlayground() {
    dockerContainers=$(getPlaygroundDockerContainers)

    if [ ${dockerContainers} ]; then
        dockerContainersKilled=$(docker stop ${dockerContainers})

        echo "Shutdown Job DSL docker containers: ${dockerContainersKilled}"
    fi
}

testDslScriptOnPlayground() {
    log "Execute DSL Script '${dslScriptName}' on Playground"
    playgroundResponse="$(curl -X POST -F "script=$(<${dslScriptPath})" ${localPlaygroundExecuteUrl})"
    
    log "Process Playground Response"
    outputFile="${tempPath}/${dslScriptName}_playground_response.xml"

    playgroundResponseJobXml=$(echo "${playgroundResponse}" | python ${processPlaygroundResponseScriptPath})
    echo "${playgroundResponseJobXml}" > ${outputFile}

    echo "Generated Job XMLs for DSL script '${dslScriptName}' have been save to temp path: ${outputFile}"
}

startPlaygroundIfNotRunning() {
    dockerContainers=$(getPlaygroundDockerContainers)

    if [ ${dockerContainers} ]; then
        if [ "${cleanupPlaygroundsFlag}" != "${cleanupPlaygroundsFlagValue}" ]; then
            return
        fi

        shutdownPlayground
    fi

    log "Start Job DSL Playground Docker Container"

    if [ ! -d ${gradlePath} ]; then
        mkdir -p ${gradlePath}
    fi

    docker run -d --rm \
        --volume=${gradlePath}:/home/gradle/.gradle \
        -p 5050:5050 \
        ${playgroundDockerImage}
    
    printf "Wait for Playground service to become available..."

    while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' ${localPlaygroundRootUrl})" != "200" ]]; do
        printf "."
        sleep 1
    done

    echo "\nPlayground is now ready to accept requests"
}

validateDslScript() {
    if [ -z "${dslScriptName}" ]; then
        printErrorAndExit "Usage: ${0} dsl_script_name_without_extension [--cleanup-playgrounds]"
    fi

    if [ ! -f "${dslScriptPath}" ]; then
        printErrorAndExit "DSL script file could not be found at path: ${dslScriptPath}"
    fi
}

testJobDslScript() {
    validateDslScript

    log "Test Job DSL Script '${dslScriptName}'"

    startPlaygroundIfNotRunning
    testDslScriptOnPlayground

    if [ "${cleanupPlaygroundsFlag}" == "${cleanupPlaygroundsFlagValue}" ]; then
        shutdownPlayground
    fi
}

testJobDslScript
