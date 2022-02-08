# Automatically Generate Documentation From Code

Use a docker version of Doxygen to generate html documentation.

See https://www.doxygen.nl/index.html

## Purpose
To quick create a useful learning and navigation tool for exploring code bases - particularly useful to generate per major release. You can in some respects treat it as API documentation for internal use.

## Method
1. `Doxyfile` into the root of your code shadow
   1. **Note:** If downloading using a web browser then remember to remove the `.txt` extension if added
2. Modify `INPUT` in this file to match your root code location, default is `/src`
3. Run `docker_run_doxygen.ps1` in a powershell from the root of the code shadow (same place as the `Doxyfile`)
4. Run this command in the docker container cli and wait 10 to 15 minutes
   1. `cd /src && doxygen`
5. In a web browser open the generated file `doxygen/html/index.html`


# Rudi TODOs
1. Extract interfaces from codebase that form the major parts of integrations and publish