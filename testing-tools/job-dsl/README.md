## Job DSL Testing Script

This script executes Job DSL scripts (for the Job DSL plugin in Jenkins) using a Job DSL playground, running in a local Docker container. It will generate the Jenkins Job Configuration XML using the DSL scripts and report any errors.

This is useful for validating the final Job Config output before the DSL script is ran on Jenkins. The playground is a testing app which presents a light weight web app that executes the Job DSL script using the actual plugin code.

How to Use:

```bash
# test a single script
./testJobDslScript.sh ~/someProject/jobs/packageBuilds.groovy

# clean up the docker container on exit (leaving it up speeds up script execution)
./testJobDslScript.sh ~/someProject/jobs/packageBuilds.groovy --cleanup-playgrounds

# test all DSL scripts found in a directory (this script also supports the above cleanup flag)
./testAllJobDslScripts.sh ~/someProject/jobs 
``` 