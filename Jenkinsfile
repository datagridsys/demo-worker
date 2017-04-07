node {

    // groovy closures for sending slack message
    def git_commit = 'unknown'
    def git_branch = 'unknown'
    def notify = { co, msg ->
        short_commit = git_commit.take(7)
        slackSend color: "$co", message: "$msg: branch `${git_branch}`, commit " +
            "`${short_commit}`, job `${env.BUILD_TAG}` <${env.BUILD_URL}|Details>",
            tokenCredentialId: 'demo-slack'
    }
    def notify_fail = { msg -> notify('danger', "*FAILED* $msg") }
    def notify_pass = { msg -> notify('good', "PASSED $msg") }
    def image_name = 'demo-worker'

    stage('build') {

        // setup perms for docker socket and jenkins user docker config
        sh 'sudo /dgri/setup.sh'

        // checkout git repo:  it is possible that what is checked out here is
        // newer than the commit which triggered the pipeline - get the commit
        try {
            checkout scm
            git_commit = sh(returnStdout: true, script: 'git rev-parse HEAD').trim()
            git_branch = sh(returnStdout: true, script: 'git rev-parse HEAD | ' +
                'git branch -a --contains | grep remotes | sed s/.*remotes.origin.//').trim()
        } catch (e) {
            notify_fail("$image_name git repo checkout")
            throw e
        }

        // build the image
        try {
            timeout(300) {
                sh 'make image'
            }
        } catch (e) {
            notify_fail("$image_name image build")
            throw e
        }
    }

    stage('push') {

        // push to docker hub
        try {
            timeout(300) {
                sh 'make push'
            }
        } catch (e) {
            notify_fail("$image_name image push")
            throw e
        }
    }

    // notify of success
    notify_pass("$image_name image build and push")
}
