library(usethis)
library(gitcreds)


usethis::use_git_config(user.name = "leesahanders", user.email = "lisamaeanders@gmail.com")
usethis::create_github_token()
gitcreds::gitcreds_set()

usethis::use_git()
usethis::use_github()