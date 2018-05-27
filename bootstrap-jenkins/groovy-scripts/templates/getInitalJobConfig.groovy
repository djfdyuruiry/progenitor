def getInitalJobConfig() {
    return [
        folder: "${folder}",
        name: "${name}",
        displayName: "${displayName}",
        parameters: [
            new StringParameterDefinition("gitRepoUrl", "${gitRepoUrl}", 
                "The URL of the Git repository host. (This should never need changed.)"),
            new StringParameterDefinition("gitRepoBranch", "${gitDefaultBranch}", 
                "The branch of the Git repository to check out. (Change this to test a feature branch.)"),
            new StringParameterDefinition("gitCredentialsId", "${gitCredentialsId}", 
                "Id of the Jenkins credentials that enable access the Git host. (This should never need changed.)")
        ],
        triggers: [
            new SCMTrigger("${scmTriggerCron}")
        ],
        gitConfig: [
            userConfig: [ new UserRemoteConfig(gitRepoUrl, null, null, gitCredentialsId) ],
            branchConfig: [ new BranchSpec(gitDefaultBranch) ],
            extensionsConfig: [ new CleanBeforeCheckout(), new SparseCheckoutPaths([new SparseCheckoutPath("Jenkinsfile")]) ]
        ]
    ]
}