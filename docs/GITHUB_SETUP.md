# Put the starter on GitHub

1. Extract this ZIP and open the `lab-analysis-templates` folder.
2. Review README.md, REUSE_POLICY.md and REVIEW_QUEUE.md with the lab.
3. Create an empty repository under the lab GitHub organization. Start private while authorship and examples are being checked. Do not auto-create a README or license because this package already contains documentation.
4. In a terminal in this folder, run the following after replacing LAB_ORG with the actual organization name:

```bash
git init -b main
git add .
git commit -m "Add initial lab analysis collection and documentation"
git remote add origin https://github.com/LAB_ORG/lab-analysis-templates.git
git push -u origin main
```

Do not run `git init` again if you have already initialized this folder. GitHub authentication is required for pushing. No remote repository or publication was created during package assembly.

Ask collaborators to use branches and pull requests and reproduce an example before marking a module reviewed.
