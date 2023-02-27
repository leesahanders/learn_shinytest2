## learn shinytest2 and github hooks


Resources: 

- <https://github.com/rstudio/actions/tree/main/connect-publish> 
- <https://solutions.posit.co/operations/deploy-methods/ci-cd/github-actions/> 
- <https://github.com/r-lib/actions/tree/v2/setup-r> 
- <https://github.com/rstudio/shinytest2/blob/main/.github/workflows/test-actions.yaml> 


Note: the `Error: ENOENT: no such file or directory, lstat '/home/runner/work/learn_shinytest2/learn_shinytest2/.github/workflows/connect-publish.yaml'` error is resolved by updating the manifest file using `rsconnect:writeManifest()` from an R console or including writeManifest as part of the deployment process. 
