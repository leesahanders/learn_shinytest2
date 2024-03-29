## learn shinytest2 and github hooks


Resources: 

- <https://github.com/rstudio/actions/tree/main/connect-publish> 
- <https://solutions.posit.co/operations/deploy-methods/ci-cd/github-actions/> 
- <https://github.com/r-lib/actions/tree/v2/setup-r> 
- <https://github.com/rstudio/shinytest2/blob/main/.github/workflows/test-actions.yaml> 
- rstudio::conf(2022): {shinytest2}: Unit testing for Shiny applications: <https://www.rstudio.com/conference/2022/talks/shinytest2-unit-testing-for-shiny/> 


Note: the `Error: ENOENT: no such file or directory, lstat '/home/runner/work/learn_shinytest2/learn_shinytest2/.github/workflows/connect-publish.yaml'` error is resolved by updating the manifest file using `rsconnect:writeManifest()` from an R console or including writeManifest as part of the deployment process. 


## Project History: 
  
This project is a copy from: 
 - https://github.com/sbhagerty/learn_shinytest2
 
With references, useful details, and pulling in documentation from: 
 - https://github.com/rstudio/shinytest2
 - https://docs.google.com/presentation/d/1PQ_xZ4MGqB_edc26ty3a97eCM55gwKgPsJ1h1mpEjWA/edit#slide=id.g12d9053b0ec_0_44
 - https://rstudio.github.io/renv/articles/renv.html
 - https://github.com/colearendt/shinytest-example 
 
Credit to Cole Arendt whose original documentation has been pulled in below and heavily used, Trevor Nederlof who walked through the setup and gotcha's for each step, Phil Bowsher for developing the Shiny App being displayed here, and Shannon Hagerty for project and example setup and details. 

## Goal
 
The goal of this example is to walk users through setting up a testing and automated publishing pipeline (continuous integration/continuous deployment) using github actions. To that end we can break this down into three separate pieces that will be put together at the end: 

1. Reproducibility
   - Using [git](https://happygitwithr.com/), [usethis](https://usethis.r-lib.org/index.html), and [reproduceable environments](https://environments.rstudio.com/) using [renv](https://rstudio.github.io/renv/articles/renv.html). 

2. Testing 
   - Using [shinytest2](https://rstudio.github.io/shinytest2/) based on the [testthat](https://testthat.r-lib.org/) workflow. For examples the [R Packages](https://r-pkgs.org/tests.html) documentation on testing might be useful.  

3. Continuous Integration / Continuous Deployment 
   - Automation using [github actions](https://docs.github.com/en/actions) and various community built action scripts to simplify the process such as [the actions written by the r-lib team](https://github.com/r-lib/actions). 

## Reproducibility (Trevor's run through)

This example is mimicking a workflow where a developer is using [renv](https://rstudio.github.io/renv/articles/renv.html) however the project isn't currently using git. We'll be walking through the steps of setting up the provided project files on the [Workbench server provided by RStudio SolEng](https://colorado.rstudio.com/), loading the developer provided environment, and setting up [git](https://happygitwithr.com/) change control using [usethis](https://usethis.r-lib.org/index.html). 

1. Create a new RStudio Workbench Session -> File -> New Project -> New Directory and upload the provided project files to the server 

2. Restore the environment with `renv::restore()`  and reload the session

3. Initialize git with `usethis::use_git()`

4. In order to create a branch so we can do work on it we need to commit the changes we've made. Use the RStudio IDE for committing and pushing changes (include everything except the renv folder and .rprofile file)

5. Create the Personal Access Token by running `usethis::create_github_token()`. Running this will pop up another chrome window for using the git web interface. 

6. Cache the credential with `gitcreds::gitcreds_set()`

7. Create the repo with `usethis::use_github()`

So we have now taken this project where we uploaded a zip onto workbench and we have now set it up in git so we can take advantage of automated workflows. 

Tip: Other authentication options can also work, such as setting up a [ssh key and configuring the git credentials](https://happygitwithr.com/ssh-keys.html) with `usethis::use_git_config(user.name = "MyName", user.email = "MyEmail@Email.com")`

## Testing (Trevor's run through)

Now let's get set up for testing. We can either develop tests interactively or can programmatically create tests and run them manually or through automation (which is what we will be doing below). Tests are stored in the [`./tests/testthat/`](./tests/testthat/) folder. This project already comes with some tests created for use that can be run interactively or through automation. New tests could also be created either using the record function and can be added or can be directly added to the tests code. 

#### Dependencies (useful in case of debugging): 

<details>
  <summary>Dependencies set up, click to expand: </summary>
  
1. Install Shinytest dependencies with `shinytest::installDependencies()`.
 
2. Install the dev version of pak to resolve the map_mold dependency error (see: https://github.com/r-lib/pak/issues/298) with `install.packages("pak", repos = "https://r-lib.github.io/p/pak/dev/")`.
 
3. Load the installed `library(pak)`.
 
4. Install `install.packages("shinyvalidate")`.

</details>

#### Creating and running tests manually: 

1. Load `library(shinytest2)`
 
2. To create a new test run `record_test()` or you can programmatically edit the tests in the [`./tests/testthat/`](./tests/testthat/) folder.  
 
3. Interact with your app, setting inputs and recording expected outputs. Save test and exit. 
 
4. Run tests with `shinytest2::test_app()`.

Tip: The shinytest package commands include testApp() - don't do this! This is antiquated. 

## Continuous Integration / Continuous Deployment (Trevor's run through)

Github actions are a new capability of using triggers during the git workflow (such as on committing a project, pushing a project, or on PR) for kicking off a series of steps defined in a recipe yaml file. 

CI/CD pipelins could also be done with other CI Services (e.g. Azure DevOps, Jenkins, etc.)
 - [Azure devops pipelines for deploying content to RStudio Connect](https://medium.com/rstudio-connect-digest/azure-devops-pipelines-for-deploying-content-to-rstudio-connect-e992f49103b6)
 - [RStudio Connect Deployments with GitHub Webhooks and Jenkins](https://medium.com/rstudio-connect-digest/rstudio-connect-deployments-with-github-webhooks-and-jenkins-c0dd8a82b986)

Tip: In the RStudio IDE through the 'files' pane click on the wheel to select the "show hidden files" option. 

### First goal: Publish to connect server using a github action 

Lets set up and run our first Github Actions workflow - automated deployment to the Connect server when code is pushed to the git repository. We will be using one yaml recipe file that lives at  [`.github/workflows/connect-publish.yaml`](./.github/workflows/connect-publish.yaml)

#### Setting up for publishing to Connect: 

1. Create an API key on the Connect server you will later be deploying to and in GitHub Actions on your repo, set the `CONNECT_API_KEY` secret

   - Go to the repository on GitHub
   
   - Navigate to Settings > Secrets
   
   - Create a "New Repository Secret" with an API key named 'CONNECT_API_KEY'

2. Create the manifest document by running in the console: `rsconnect::writeManifest()`. This document defines what will be included in the deployment to the Connect server when called later using the automation we are setting up. 

> If you create your own `manifest.json`, you may need to remove your `.Rprofile`
> before generating it, or edit the `manifest.json` and remove the `.Rprofile`
> record from "files".
> 
> This will be improved in a future version of the GitHub Action

#### Creating the automation yaml recipe: 

1. Open [`.github/workflows/connect-publish.yaml`](./.github/workflows/connect-publish.yaml) - we'll use this as a starting point and modify it so it fits our project needs. 

2. Change branch name to match the one you have (In this example since Colorado and usethis default to creating a "master" branch we'll be changing our branch name from 'main' to 'master')

3. Add the Connect URL. For the provided RStudio Connect server the address is *https://colorado.rstudio.com/rsc*

4. Access type is changed according to what Connect has set (for this example leave as acl). 

5. Set the dir. The info included in this block are all separate examples. When done using this naming convention this field sets the name of the published document as well as the vanity url. (Future work: figure out how to set name separate from url)

6. Update the runs-on section as needed for the hosted virtual environments / operating systems you want it to test on

7. Verify that your recipe yaml now looks something like: 

  <details>
    <summary>connect-publish yaml, click to expand</summary>
    
  ```
  name: connect-publish
  on:
    push:
      branches: [master]
  
  jobs:
    connect-publish:
      name: connect-publish
      runs-on: ubuntu-20.04
      steps:
        - uses: actions/checkout@v2
        - name: Publish Connect content
          uses: rstudio/actions/connect-publish@main
          with:
            url: https://colorado.rstudio.com/rsc
            api-key: ${{ secrets.CONNECT_API_KEY }}
            access-type: acl
            dir: |
              .:/shiny-workshop-test 
              
  ```
  </details>

9. Test the automation by committing and pushing the changes. Github will see the action and will automatically run the defined recipe and on push will try to publish the app to the Connect server specified. 

10. Open a browser window with your git repo and go to actions -> workflows. Watch real time it's progress. 

## Final goal: Putting it all together

Let's now set up an additional step and bring all the above parts together by adding testing to our workflow then publishing to the Connect server using github actions. In this example we are assuming that we would want testing to be kicked off on two conditions; (1) whenever changes are pushed to the repo and (2) if a PR is requested. In addition we want publishing to the Connect server to only happen when tests are successful. To that end we will be modfying our main yaml to call a second yaml recipe called  [`.github/workflows/test-actions.yaml`](./.github/workflows/test-actions.yaml) that will be setup to run when called (using the workflow-call parameter) and when certain triggers are met (on PR). 

- If the tests succeed, the workflow run will pass

- If the tests differ or fail, the workflow run will fail

- To review the results directly, you have to download the build artifacts

- Alternatively, since tests are failing, it means that something about the
application has changed. Tests may need to be updated (or code fixed) to address
the changes. To do this, you can run the tests locally or address any code
changes necessary

#### Create the testing yaml recipe: 

We will be creating a test yaml recipe at [`.github/workflows/test-actions.yaml`](./.github/workflows/test-actions.yaml). This recipe walks through these steps for creating an environment and running the tests we defined earlier: 

1. Checkout the code 

2. Setup pandoc 

3. Setup the R version using the RStudio public rspm 

4. Remove the .Rprofile file (so it can't conflict with renv)

5. Use r-lib actions to set up the environment 

6. Run the tests using shinytest2

7. (optional) There's an option to run tests across multiple OS's and R versions using a "matrix" parameter. This example has that removed. 
 
8. Verify that yYour test yaml looks something like: 

  <details>
    <summary>test-app yaml, click to expand</summary>
    
  ```
  on:
    pull_request:
      branches: [master]
    workflow_call:
    
  name: test-app
  
  jobs:
    test-app:
      name: test-app
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v2
  
        - uses: r-lib/actions/setup-pandoc@v2
  
        - uses: r-lib/actions/setup-r@v2
          with:
            r-version: release
            use-public-rspm: true
  
        # Connect does not like `renv`'s `./.Rprofile`
        # Removing from deployment as Connect listens to the `./manifest.json` file
        - name: Remove `.Rprofile`
          shell: bash
          run: |
            rm .Rprofile
  
        - uses: r-lib/actions/setup-renv@v2 # use our renv.lock
  
        - name: Test app
          uses: rstudio/shinytest2/actions/test-app@main
  ```
  
  </details>


#### Updates to the main recipe yaml

1. Open our main yaml recipe at [`.github/workflows/connect-publish.yaml`](./.github/workflows/connect-publish.yaml)

2. Make changes to add our testing recipe yaml as a step before publishing to Connect. 

   - By default github actions run in parallel. We need to add before publishing to the Connect server so that it requires passing the tests prior to publishing. We can do this by adding `needs: [test-app]`. 

2. Verify that after making changes the yaml now looks something like: 

  <details>
    <summary>connect-publish yaml, click to expand</summary>
    
  ```
  name: connect-publish
  on:
    push:
      branches: [master]
  
  jobs:
    test-app:
      uses: ./.github/workflows/test-actions.yaml
    connect-publish:
      name: connect-publish
      needs: [test-app]
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v2
        - name: Publish Connect content
          uses: rstudio/actions/connect-publish@main
          with:
            url: https://colorado.rstudio.com/rsc/
            api-key: ${{ secrets.CONNECT_API_KEY }}
            access-type: acl
            dir: |
              .:/shiny-workshop-test-prod
  ```
  </details>

We can now do the same steps of testing our automation by committing and pushing the changes. Github will see the action and will automatically run. We can open a browser window in our git repo and go to actions -> workflows to watch real time it's progress. 

Tip: The packages being pulled in are cached. First time running an action will take longer but next time should be faster. 


## Next Steps 

 - Make breaking changes to see tests fail during automated deployment 

 - Set up running across multiple R versions and OS's using the "matrix" parameter for cross-platform testing 
 
 - Set up git-backed deployment to the Connect server which will use a "pull-based" approach for deploying commits to git rather than relying on the "push-based" approach. [You can read more about the process here](https://docs.rstudio.com/connect/user/git-backed/). This requires a `manifest.json` in the repository. It is created with
`rsconnect::writeManifest()`
