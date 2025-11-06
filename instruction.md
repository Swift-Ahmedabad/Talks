# Instructions

- This repository 
	- uses Git LFS to support large files (PDFs) from the talk resources.
	- uses a custom swift executable file (.scripts/GenerateReadMe) to generate the README.md, to compile the talk and speaker information.
	- uses a pre-commit hook to update README.md and talks.json to make this automatic (using generate-readme.sh) as git commit is performed.

- **Note**: pre-commit hook does not automatically add the updated README.md and talks.json file to current git commit operation, so make sure to add these file changes to git again.

- To learn more about the GenerateReadMe executable, visit: https://github.com/Swift-Ahmedabad/GenerateReadMe

### Tasks:
- [ ] Pre-commit hook add updated files to git commit operation
- [ ] Add documentation.
- [ ] Optimize code for hidden files
- [ ] Add support for more information (i.e., about-talk, event-details, etc)
