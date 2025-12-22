# Instructions for Claude AI

# Project description

This project houses scripts for deploying various projects on a local kubernetes environment running one control plane and one worker node both with kubernetes version 1.34.1

# Structure
Each folder bears the name of the project to be deployed. 
A project can either be a single or multiple services. 

Each folder should contain at least one deployment file. Notify in case of folders without the deployment.yml file or some file you consider as an equivalent. 

# Tasks

Generate deployment files for each project generally running at least two replicas for each container. 

When generating a file, use the latest container version. 

Where applicable, always mount data files from an external directory bearing the project name and a subfolder of /home/data. In a case of a project with multiple containers, the data directory should be subfolder of the project data directory. 