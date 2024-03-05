# Finding bugs fixed since last release

For 7.5-3 testing, we needed to generate a list of bugs that needed to be verified as fixed. The criteria is:

1. Falls under one of our features we're responsible for. For 7.5-3 that included some core features:
  a. XPath operator
  b. Intelligent streams
  c. Light crawler
2. Fixed since 7.5-2

This command shows all commits since 7.5-2 until the release candidate that we're testing (rc2):

$ git --no-pager log --author='cox\|nichols\|lange\|font\|palmer\|goulding\|bielski\|bradley' --pretty=oneline --no-merges 7.5-2..7.5-3-rc2 > fixed-bugs-7.5-3.txt

After that, I ran utils/massage_commit_messages.rb on the generated file to find unique bugs and reformat the bugs as wiki bugs (like {{bug|1234}}). 

Then I went through the list of bugs manually and removed bugs that were still open or were not our responsibility.