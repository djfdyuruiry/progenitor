def getInitalJobConfig() {
    return [
        folder: System.getenv("folder"),
        name: System.getenv("name"),
        displayName: System.getenv("displayName"),
        parameters: [
            new StringParameterDefinition("gitRepoUrl", System.getenv("gitRepoUrl"), 
                "The URL of the Git repository host. (This should never need changed.)"),
            new StringParameterDefinition("gitRepoBranch", System.getenv("gitDefaultBranch"), 
                "The branch of the Git repository to check out. (Change this to test a feature branch.)"),
            new StringParameterDefinition("gitCredentialsId", System.getenv("gitCredentialsId"), 
                "Id of the Jenkins credentials that enable access the Git host. (This should never need changed.)")
        ],
        triggers: [
            new SCMTrigger(System.getenv("scmTriggerCron"))
        ],
        gitConfig: [
            userConfig: [ new UserRemoteConfig(gitRepoUrl, null, null, gitCredentialsId) ],
            branchConfig: [ new BranchSpec(gitDefaultBranch) ],
            extensionsConfig: [ new CleanBeforeCheckout(), new SparseCheckoutPaths([new SparseCheckoutPath("Jenkinsfile")]) ]
        ]
    ]
}