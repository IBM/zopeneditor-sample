/*******************************************************************************
 * Licensed Materials - Property of IBM
 * (C) Copyright IBM Corporation 2026. All Rights Reserved.
 *
 * Note to U.S. Government Users Restricted Rights:
 * Use, duplication or disclosure restricted by GSA ADP Schedule
 * Contract with IBM Corp.
 *******************************************************************************/

package com.ibm.zcodescan.cobol.api.impl;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;

// COBOL AST APIs
import com.ibm.etools.cobol.application.model.cobol.ASTNode;
import com.ibm.etools.cobol.application.model.cobol.IdentificationDivision;
import com.ibm.etools.cobol.application.model.cobol.Program;

// ZCodeScan APIs
import com.ibm.zcodescan.api.IZCodeScanIssue;
import com.ibm.zcodescan.api.IZCodeScanLocation;
import com.ibm.zcodescan.api.IZCodeScanRule;
import com.ibm.zcodescan.api.IZCodeScanTextRange;
import com.ibm.zcodescan.api.ZCodeScanFactory;
import com.ibm.zcodescan.cobol.api.AbstractCOBOLVisitor;
import com.ibm.zcodescan.cobol.api.COBOLVisitorAdapter;
import com.ibm.zcodescan.cobol.api.IZCodeScanCobolRule;
import com.ibm.zcodescan.lsp.common.core.errors.ZCodeScanException;

public class CobolProgramIdRule implements IZCodeScanCobolRule, IZCodeScanRule {
    private static final String LENGTH_PARAM = "length";

    /**
     * Text-based scan implementation (not used - AST scan is used instead)
     */
    @Override
    public List<IZCodeScanIssue> scan(String uri, String source, Map<String, String> parameters) {
        return Collections.emptyList();
    }

    /**
     * AST-based scan - uses COBOLVisitorAdapter to traverse the COBOL AST,
     * checks PROGRAM-ID length, and creates issues for violations
     */
    @Override
    public List<IZCodeScanIssue> scan(final String uri, final String source, final ASTNode astNode,
            final Map<String, String> parameters) {

        final List<IZCodeScanIssue> issues = new ArrayList<>();

        // Get max length parameter from rule configuration
        final int maxLength = (int) Double.parseDouble(parameters.get(LENGTH_PARAM));
        if (maxLength < 0) {
            throw new ZCodeScanException("Parameter must be non-negative: " + LENGTH_PARAM);
        }

        // Use visitor pattern to traverse AST and find Program nodes
        final ASTNode baseNode = astNode;
        final COBOLVisitorAdapter adapter = new COBOLVisitorAdapter();
        adapter.accept(baseNode, new AbstractCOBOLVisitor() {
            @Override
            public void unimplementedVisitor(final String value) {
            }

            @Override
            public boolean visit(final Program program) {
                // Check PROGRAM-ID and create issue if it exceeds max length
                final IZCodeScanTextRange textRange = checkProgramId(program, source, maxLength);
                if (textRange != null) {
                    final ZCodeScanFactory factory = ZCodeScanFactory.getInstance();
                    final IZCodeScanIssue issue = factory.createIssue();
                    final IZCodeScanLocation primaryLocation = factory.createLocation();
                    issue.setPrimaryLocation(primaryLocation);
                    primaryLocation.setTextRange(textRange);
                    issues.add(issue);
                }
                return true;
            }

        });
        return issues;
    }

    /**
     * Validates PROGRAM-ID length against max allowed length.
     * Returns text range for violation location or null if valid.
     */
    public static IZCodeScanTextRange checkProgramId(final Program program, final String source,
            final int maxLength) {
        final IdentificationDivision identificationDivision = program.getIdentificationDivision();
        final String programId = identificationDivision.getProgramId();

        if (programId.length() > maxLength) {
            // Create text range pointing to IDENTIFICATION DIVISION location
            final IZCodeScanTextRange textRange = ZCodeScanFactory.getInstance().createTextRange();
            textRange.setStartLine(identificationDivision.getBeginLine());
            textRange.setEndLine(identificationDivision.getEndLine());
            textRange.setStartColumn(identificationDivision.getBeginColumn());
            textRange.setEndColumn(identificationDivision.getEndColumn());

            final int startOffset = source.indexOf(programId);
            textRange.setStartOffset(startOffset);
            return textRange;
        }
        return null;
    }

}

// Made with Bob
