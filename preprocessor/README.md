# Z Open Editor Preprocessor samples

This folder augments the [user documentation](https://ibm.github.io/zopeneditor-about/Docs/advanced_preprocessor.html) with examples for running simple COBOL or PL/I Preprocessor examples written in Java as well as REXX for you to try the Z Open Editor preprocessor support. Once you were able to run our sample you should be able to use your own preprocessor in a similar way by replacing the command line and parameters in the ZAPP files.

To be able to use the Z Open Editor Preprocessor feature and this example you need to have imported a valid trial or license key in the Welcome page that activies the feature.

## Review the ZAPP file and create ZAPP user or workspace variables

Open the samples [ZAPP file](../zapp.yaml) and find the `local-cobol` or `local-pli` preprocessor profile defined there. It references three variables for executing the preprocessor: `${JAVA_HOME}`, `${WORKSPACE}`, and `${HLQ}` (used for the remote preprocessor examples only). You find placeholders for these three in this [samples workspace settings file](../.vscode/settings.json). Open that file and either (a) replace the three values with your absolute `$JAVA_HOME` path and the absolute path of this workspace, i.e. where you cloned this Git repository on your development machine, or (b) move these variables to your user settings as these are specific to your local setup, or (c) just replace the variables in the ZAPP profiles shown below with their conrete values.

## Local preprocessor examples

### Prepare the sample preprocessor program

To use the sample preprocessor you need to build it using Java. The folder [preprocessor/<COBOL|PLI>/local-preprocessor](./local-preprocessor/) contains a Java Maven project that you can use to build it by running `mvn package` from that folder. Altenatively, use the [Extension Pack for Java](https://marketplace.visualstudio.com/items?itemName=vscjava.vscode-java-pack) to build it from VS Code (Java and Maven required in your path).

Local Cobol profile sample :

```yaml
    - name: local-cobol
        language: cobol
        type: preprocessor
        location: local
        settings:
          command: ${JAVA_HOME}/bin/java -jar ${WORKSPACE}/preprocessor/COBOL/local-preprocessor/target/local-cobol-preprocessor-1.0-SNAPSHOT.jar {input_file} ${output_file}
          outputPath: ./preprocessor/output
          fileExtension: cee
          environmentVariables:
            some: var
```

Local PL1 profile sample :

```yaml
    - name: local-pli
        language: pl1
        type: preprocessor
        location: local
        settings:
          command: ${JAVA_HOME}/bin/java -jar ${WORKSPACE}/preprocessor/PLI/local-preprocessor/target/local-pl1-preprocessor-1.0-SNAPSHOT.jar ${input_file} ${output_file}
          outputPath: ./preprocessor/output
          fileExtension: pci
          environmentVariables:
            some: var
```

Note, that if you are using Windows and have a space in the path (e.g. `Program Files`), you will need to replace the portion of the path that has spaces with the Windows shorthand. Generally, this will be the first 6 non-whitespace characters in the path followed by `~1`, for example, for `Program Files` this would be `Progra~1`, for a directory like `test files` this would be `testfi~1`. If the path is shorter than 6 non-whitespace characters, you will need to use `Cmd` to get the shorthand. To do this, open `Cmd`, go to the directory above the directory you need the shorthand for, e.g. `C:/` for `C:/Program Files`. Run `dir /x`, and the directories will be listed with their shorthands.

Also note the location of the `outputPath` setting in the profile pointing to the directory [preprocessor/output](./output/). This is the folder were the preprocessed programs will be generated in.

### Running the local preprocessor from Z Open Editor

Now you are ready to run the preprocessor on our sample programs. Open either the file [preprocessor/COBOL/PrintApp.cbl](./COBOL/PrintApp.cbl) or [preprocessor/PLI/PrintApp.cbl](./PLI/PrintApp.pli). You will see that Z Open Editor will show many syntax errors as it contains macros such as `+ID`, `+DD`, etc. The sample preprocessor will replace them with valid COBOL or Pl/I code behind the covers to enable our language to parse them.

Right-click inside the editor and select "Execute local preprocessor command".

A progress bar will open and as a result all the syntax errors will go away. If something goes wrong check the log output for error messages in the VS Code Output view under the Z Open Editor drop-down value.

You can now hover over the preprocessor macros and see the code that has been used to replace them in a hover. For example the `+ID.` COBOL statement will show in the hover that it was replaced with `IDENTIFICATION DIVISION.`. The PL/I `+DL` statement will show a replacement with `DECLARE`.

Open the generated output file [preprocessor/output/PrintApp.cee](./output/PrintApp.cee) in the editor. You see the file generated by the preprocessor, which is a valid COBOL or PL/I program. The Z Open Editor language server will use that program file to parse for errors and overlay the results to the original programs with macros in the editor.

Go back to [preprocessor/COBOL/PrintApp.cbl](./COBOL/PrintApp.cbl) or [preprocessor/PLI/PrintApp.cbl](./PLI/PrintApp.pli) and select "Compare preprocessor input and putput files" from the context menu. It will of a Diff editor showing you the two files and their differences side by side.

Open you user settings and find `zopeneditor.autoPreprocessor`. From the drop-down select `all`. Switch back to the editor and make changes to the sample program. You might see syntax errors if you use the macros in your statements. However, when you save the program you can see that the preprocessor is execute automatically and the errors related to the macros will go away. Examine the other drop-down values for when the preprocessor should be triggered.

## Remote preprocessor example

### Review the ZAPP file and prepare your data sets

To run the remote preprocessor example that performs on z/OS we assume you have created a Zowe Explorer profile for RSE API or z/OSMF and made it your default using the `zopeneditor.zowe": {"profile-name"}` user setting. The profile name should be displayed in the status bar of the editor. Note, that for z/OSMF you must also define a TSO Zowe CLI profile as our REXX preprocessor example will be executed using TSO. For RSE API profiles this is not required as RSE API has a TSO interface built-in.

Open the samples [ZAPP file](../zapp.yaml) and find the `remote-cobol` or `remote-pli` preprocessor profile defined there. It references several data set names and the `${HLQ}` variable. Either replace the variabe with your high-level qualifier or define a ZAPP variable in your user or workspace settings as described above.

Remote Cobol profile sample :

```yaml
    - name: remote-cobol
      language: cobol
      type: preprocessor
      location: mvs
      settings:
        commandDataSet: ${HLQ}.PREPROC(CBLPRPC)
        tempDataHLQ: ${HLQ}
        outputDataSet: ${HLQ}.PREPROC.OUTPUT()
        commandParameters: ""
```

Remote PL1 profile sample :

```yaml
    - name: remote-pli
      language: pl1
      type: preprocessor
      location: mvs
      settings:
        commandDataSet: ${HLQ}.PREPROC(PLIPRPC)
        tempDataHLQ: ${HLQ}
        outputDataSet: ${HLQ}.PREPROC.OUTPUT()
        commandParameters: ""
```

Create a PDSE for `commandDataSet` and `outputDataSet`. You can use the suggested names from the ZAPP or create them using other names and update the ZAPP profile with these names. You also need to create or reuse an existing PDSE for the COBOL sample program [preprocessor/COBOL/PrintApp.cbl](./COBOL/PrintApp.cbl), such as `${HLQ}.PREPROC.COBOL` and the equivalent for PL/I. It needs to have the words `COBOL` or `CBL` (`PLI` or `PL1`) in its name so Z Open Editor will use its default file assoications to open the file with the COBOL language server. The sample preprocessor will also create a temporal sequential data set using your HLQ and delete it after completion.

Use Zowe Explorer to upload the REXX sample preprocessor program [preprocessor/remote-preprocessor/CBLPRPC.rexx](./COBOL/remote-preprocessor/CBLPRPC.rexx) to the `commandDataSet` you created in the previous step. Upload the [preprocessor/COBOL/PrintApp.cbl](./COBOL/PrintApp.cbl) to the PDSE you have created for it in the previous step, such as `${HLQ}.PREPROC.COBOL`. For Pl/I use the equivalent files.

### Running the remote preprocessor from Z Open Editor

Open the `PRINTAPP` via Zowe Explorer and ensure that it was recognized as a COBOL or PL/I program showing you syntax highlighting, an outline view, etc. If your PDSE does not contain the keywords required then you can click the status bar in VS Code to select `COBOL` as the language to use for this file. The sample program was not processed, yet, so it will show syntax errors.

Right-click inside the editor and select "Execute remote preprocessor command". A progress bar will open and as a result all the syntax errors will go away. If something goes wrong check the log output for error messages in the VS Code Output view under the Z Open Editor drop-down value.

You can now hover over the preprocessor macros and see the code that has been used to replace them in a hover. For example the `+ID.` statement will show in the hover that it was replaced with `IDENTIFICATION DIVISION.`.

Open the generated output file that was created in the `outputDataSet` in the editor. You see the file generated by the preprocessor, which is a valid COBOL program. The Z Open Editor language server will use that program file to parse for errors and overlay the results to the original programs with macros in the editor.

Open you user settings and find `zopeneditor.autoPreprocessor`. From the drop-down select `all`. Switch back to the editor and make changes to the sample program. You might see syntax errors if you use the macros in your statements. However, when you save the program you can see that the preprocessor is execute automatically and the errors related to the macros will go away. Examine the other drop-down values for when the preprocessor should be triggered.

### Expanding PL/I macros using a remote preprocessor

To expand the PL/I macros using remote preprocessor, we assume that your z/OS has a PL/I compiler and you have created a Zowe Explorer profile for RSE API or z/OSMF and made it your default using the `zopeneditor.zowe": {"profile-name"}` user setting.

Open the samples [ZAPP file](../zapp.yaml) and find the `remote-pli-macro` preprocessor profile defined there. As the first preprocessor profile gets picked up on the basis of language and location make sure whichever profile you want to run is ordered at the top under the preprocessor section or you can comment out the other preprocessor profiles. It references several data set names and a `HLQ` variable. Either replace the variabe with your high-level qualifier or define a ZAPP variable in your user or workspace settings. Also comment out the PL/I property groups that were defined for the PSAM example as these do not work with the preprocessor example.

```yaml
    - name: remote-pli-macro
      language: pl1
      type: preprocessor
      location: mvs
      settings:
        commandDataSet: ${HLQ}.SFELSAMP(FEKRNPLI)
        tempDataHLQ: ${HLQ}
        outputDataSet: ${HLQ}.PREPROC.OUTPUT()
        commandParameters: <SYSPRINT>${HLQ}.LOG.OUTPUT()</SYSPRINT>
```

Create a PDSE for `commandDataSet` with PL/I macro preprocessor [preprocessor/PLI/remote-preprocessor/FEKRNPLI.rexx](./PLI/remote-preprocessor/FEKRNPLI.rexx) as a member in it, and `outputDataSet`. You can use the suggested names from the ZAPP or create them using other names and update the ZAPP profile with these names. To append `<SYSPRINT>` tag in the XML use `commandParameters` in the ZAPP profile. For creating the `SYSPRINT` dataset `${HLQ}.LOG.OUTPUT()` use following dataset attributes:

```ascii
    Record Format (recfm): VBA
    Record Length (lrecl): 137
    Dataset Type (dsntp): LIBRARY
```

In `FEKRNPLI.rexx` you need to replace the `".V6R1M0.SIBMZCMP(IBMZPLI)"` from `compiler = compiler_hlq||".V6R1M0.SIBMZCMP(IBMZPLI)"` in line `82` with the PL/I compiler in your current z/OS system. You also need to create or reuse an existing PDSE for the PLI sample program [PLI/CITYCODE.pli](../PLI/CITYCODE.pli), such as `${HLQ}.PREPROC.PLI`. It needs to have the words `PLI` or `PL1` in its name so Z Open Editor will use its default file assoications to open the file with the PL/I language server. The sample preprocessor will also create a temporal sequential data set using your HLQ and delete it after completion.

Open the `CITYCODE` via Zowe Explorer and ensure that it was recognized as a PL/I program showing you syntax highlighting, an outline view, etc. If your PDSE does not contain the keywords required then you can click the status bar in VS Code to select `PLI` as the language to use for this file. The sample program was not processed, yet, so it will show syntax errors.

Right-click inside the editor and select "Execute remote preprocessor command".

A progress bar will open and as a result all the syntax errors will go away. You can now hover over the preprocessor macros and see the code that has been used to replace them in a hover. For example the macro statements including `%` will be resolved and removed. For example in the `CITYCODE.pli` file from line `14` to `16` which are macros will be removed. Similarly other macro statements will get resolved.

```ascii
 %DCL USE CHAR;
 %USE = 'FUN' /* FOR SUBROUTINE, %USE = 'SUB' */ ;
 %IF USE = 'FUN' %THEN %DO;
```

**Note:** Using this sample will still result in a RC=12 from the PL/I compiler even though it does produce a valid output file. This is expected and still means this preprocessor has finished successfully.

## Remote preprocessor for local files example

### Review the remote ZAPP profile and prepare your data sets with programDataSet

You can also run a remote preprocessor on files that you edit locally, e.g. as part of your Git repository. For that Z Open Editor will upload the program file you are currently editing to a dedicated PDSE, execute the preprocessor on z/OS and then fetch the output file back to the local file system.

To run the remote preprocessor example on local files, ensure that [Remote preprocessor example](#remote-preprocessor-example) works as expected. Review the ZAPP file and find the profiles `remote-cobol` or `remote-pli`. Comment out the last line with the `programDataSet` property, which will be location  where the local file will be uploaded. Create such a PDSE and provide the value for this property.

You can use the suggested names from the ZAPP file or create them using other names and update the ZAPP profile with these names.

Remote Cobol profile sample:

```yaml
    - name: remote-cobol
      language: cobol
      type: preprocessor
      location: mvs
      settings:
        commandDataSet: ${HLQ}.PREPROC(CBLPRPC)
        tempDataHLQ: ${HLQ}
        outputDataSet: ${HLQ}.PREPROC.OUTPUT()
        commandParameters: ""
        programDataSet: ${HLQ}.PREPROC.COBOL()
```

Remote PL1 profile sample:

```yaml
    - name: remote-pli
      language: pl1
      type: preprocessor
      location: mvs
      settings:
        commandDataSet: ${HLQ}.PREPROC(PLIPRPC)
        tempDataHLQ: ${HLQ}
        outputDataSet: ${HLQ}.PREPROC.OUTPUT()
        commandParameters: ""
        programDataSet: ${HLQ}.PREPROC.COBOL()
```

### Running the remote preprocessor for local files from Z Open Editor

Open either the file [preprocessor/COBOL/PrintApp.cbl](./COBOL/PrintApp.cbl) or [preprocessor/PLI/PrintApp.cbl](./PLI/PrintApp.pli). You will see that Z Open Editor will show many syntax errors as it contains macros such as `+ID`, `+DD`, etc. The sample preprocessor will replace them with valid COBOL or Pl/I code behind the covers to enable our language to parse them.

Right-click inside the editor and select "Execute remote preprocessor command for local file".

A progress bar will open and as a result all the syntax errors will go away. You can now hover over the preprocessor macros and see the code that has been used to replace them in a hover. For example the `+ID.` statement will show in the hover that it was replaced with `IDENTIFICATION DIVISION.`.

Open the generated output file that was created in the `outputDataSet` in the editor. You see the file generated by the preprocessor, which is a valid COBOL program. The Z Open Editor language server will use that program file to parse for errors and overlay the results to the original programs with macros in the editor.
