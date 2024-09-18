/*******************************************************************************
 * Licensed Materials - Property of IBM
 * (C) Copyright IBM Corporation 2024. All Rights Reserved.
 *
 * Note to U.S. Government Users Restricted Rights:
 * Use, duplication or disclosure restricted by GSA ADP Schedule
 * Contract with IBM Corp.
 *******************************************************************************/

package com.ibm.zopeneditor.preprocessor;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;

public class LocalPl1Preprocessor {
    public static void main(String[] args) {
        File in = new File(args[0]);
        File out = new File(args[1]);

        if (in.exists()) {
            BufferedReader reader = null;
            FileWriter writer = null;
            try {
                reader = new BufferedReader(new FileReader(in));
                writer = new FileWriter(out);
                String line;

                while ((line = reader.readLine()) != null) {
                    line = line.replace("+PT", "PUT");
                    line = line.replace("+DL", "DECLARE");

                    writer.write(line);
                    writer.write("\n");
                }
                writer.flush();
            } catch (Exception exception) {
                exception.printStackTrace();
            } finally {
                try {
                    if (writer != null)
                        writer.close();
                    if (reader != null)
                        reader.close();
                } catch (IOException exception) {
                    exception.printStackTrace();
                }
            }
        }
    }
}