# progenitor
Framework of tools to enable continuous integration as code using Jenkins

## What is this?

An attempt to use Docker, shell scripting, REST APIs and some key Jenkins plugins to provide a `stateless` Jenkins Framework.

- Configure Jenkins nodes as configuration & code
    - Plugins
    - Users
    - Folders
    - Jobs
    - GitHub / GitLab Integration
- Generators for common components (Like the items above)
- Create a `Stateless` Jenkins node using Docker
- Useful tools that can be used in isolation
    - Clients for common CI REST API's
    - Admin scripts for Jenkins
    - Reusable Custom Jenkins Pipeline Steps and Libraries
- Reuses well established Jenkins Plugins
    - [Job DSL Plugin](https://github.com/jenkinsci/job-dsl-plugin)
    - [GitHub]() / [GitLab]() Plugins
- Uses the lowest common denominator for the best portability
    - Scripts and components are written in Bash, using tools like `wget` and `curl`
    - Admin and Pipeline scripts use Groovy
    - Configuration using CSV/PSV files

## Things to note

- Framework uses the latest stable version of any Plugins, Shells and REST API's
- While components are as generic and configurable as possible, not everything will suit your use case
- Scripting can be done in Python or Powershell etc. but Bash is widly understood and is available for most Linux distros and OSX out of the box (and with a little work, Windows can also join the fun)  
