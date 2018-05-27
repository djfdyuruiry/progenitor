#! /usr/bin/env bash
set -e

scriptPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

jobDslPath="${1}"
cleanupPlaygroundsFlag="${2}"

testAllJobDslScripts() {
    for jobDslScript in  ${jobDslPath}/*.groovy; do
        jobDslScriptFileName=$(basename ${jobDslScript})
        jobDslScriptName="${jobDslScriptFileName%%.*}"

        "${scriptPath}/testJobDslScript.sh" ${jobDslScriptName} ${cleanupPlaygroundsFlag}
    done
}

testAllJobDslScripts
