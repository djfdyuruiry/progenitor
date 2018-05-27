import org.jenkinsci.plugins.gitlablogo.GitlabLogoProperty
import org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition
import org.jenkinsci.plugins.workflow.flow.FlowDefinition
import org.jenkinsci.plugins.workflow.job.properties.PipelineTriggersJobProperty
import org.jenkinsci.plugins.workflow.job.WorkflowJob

import com.cloudbees.hudson.plugins.folder.Folder

import hudson.model.ParametersDefinitionProperty
import hudson.plugins.git.BranchSpec
import hudson.plugins.git.extensions.impl.SparseCheckoutPath
import hudson.plugins.git.extensions.impl.SparseCheckoutPaths
import hudson.plugins.git.GitSCM
import hudson.plugins.git.UserRemoteConfig
import hudson.plugins.git.extensions.impl.CleanBeforeCheckout
import hudson.triggers.SCMTrigger

def configureInitialSyncJob(syncJob, syncJobConfig, initalBuildNumber) {
    def gitConfig = syncJobConfig.gitConfig
    def gitScmConfig = new GitSCM(gitConfig.userConfig,
        gitConfig.branchConfig, 
        false, [], null, null, 
        gitConfig.extensionsConfig)

    syncJob.definition = new CpsScmFlowDefinition(gitScmConfig, "Jenkinsfile")

    syncJob.addProperty(new ParametersDefinitionProperty(syncJobConfig.parameters))
    syncJob.addProperty(new PipelineTriggersJobProperty(syncJobConfig.triggers))
    syncJobConfig.properties.each { p -> syncJob.addProperty(p) }

    syncJob.setDisplayName(syncJobConfig.displayName)
    syncJob.updateNextBuildNumber(initalBuildNumber)

    syncJob.save()

    println "Configured CI sync job '$syncJob.fullName'"
}

def getJenkinsFolder(folderFullName) {
    def jenkinsFolders = Jenkins.instance.getAllItems(Folder)
    def folder = jenkinsFolders?.find { f -> f.fullName == folderFullName }

    if (!folder) {
        throw new Exception("The folder '$folderFullName' is missing from this Jenkins instance," +
            " please create it")
    }

    return folder
}

${getInitalJobConfigFunction}

def createOrUpdateInitialSyncJob() {
    def syncJobConfig = getInitalJobConfig()
    def ciFolder = getJenkinsFolder(syncJobConfig.folder)
    def pipelineJobs = Jenkins.instance.getAllItems(WorkflowJob)
    def initialSyncJob = pipelineJobs?.find { f -> f.fullName == "$syncJobConfig.folder/$syncJobConfig.name" }
    def initalBuildNumber = 1

    if (initialSyncJob) {
        // ensure new job has the next build number of the existing one 
        //   (jenkins preserves build history for removed jobs)
        initalBuildNumber = initialSyncJob.getNextBuildNumber()
        ciFolder.remove(initialSyncJob)

        println "Removed existing CI sync job '$initialSyncJob.fullName'"
    }

    initialSyncJob = ciFolder.createProject(WorkflowJob, syncJobConfig.name)
    println "Created CI sync job '$initialSyncJob.fullName'"

    configureInitialSyncJob(initialSyncJob, syncJobConfig, initalBuildNumber)

    return initialSyncJob
}

createOrUpdateInitialSyncJob()
