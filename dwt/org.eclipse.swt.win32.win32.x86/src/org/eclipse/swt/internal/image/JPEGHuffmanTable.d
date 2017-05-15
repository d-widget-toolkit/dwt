/*******************************************************************************
 * Copyright (c) 2000, 2005 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * Port to the D programming language:
 *     Frank Benoit <benoit@tionex.de>
 *******************************************************************************/
module org.eclipse.swt.internal.image.JPEGHuffmanTable;

import org.eclipse.swt.internal.image.JPEGVariableSizeSegment;
import org.eclipse.swt.internal.image.LEDataInputStream;
import org.eclipse.swt.internal.image.JPEGFileFormat;

import java.lang.System;
/**
 * JPEGHuffmanTable class actually represents two types of object:
 * 1) A DHT (Define Huffman Tables) segment, which may represent
 *  as many as 4 Huffman tables. In this case, the tables are
 *  stored in the allTables array.
 * 2) A single Huffman table. In this case, the allTables array
 *  will be null.
 * The 'reference' field is stored in both types of object, but
 * 'initialize' is only called if the object represents a DHT.
 */
final class JPEGHuffmanTable : JPEGVariableSizeSegment {
    JPEGHuffmanTable[] allTables;
    int tableClass;
    int tableIdentifier;
    int[] dhMaxCodes;
    int[] dhMinCodes;
    int[] dhValPtrs;
    int[] dhValues;
    int[] ehCodes;
    byte[] ehCodeLengths;
    static byte[] DCLuminanceTable = [
        cast(byte)255, cast(byte)196, 0, 31, 0, 0, 1, 5, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0,
        0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11
    ];
    static byte[] DCChrominanceTable = [
        cast(byte)255, cast(byte)196, 0, 31, 1, 0, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0,
        0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11
    ];
    static byte[] ACLuminanceTable = [
        cast(byte)255, cast(byte)196, 0, cast(byte)181, 16, 0, 2, 1, 3, 3, 2, 4, 3, 5, 5, 4, 4, 0, 0, 1, 125,
        1, 2, 3, 0, 4, 17, 5, 18, 33, 49, 65, 6, 19, 81, 97, 7, 34, 113, 20,
        50, cast(byte)129, cast(byte)145, cast(byte)161, 8, 35, 66, cast(byte)177, cast(byte)193, 21, 82, cast(byte)209, cast(byte)240, 36, 51, 98,
        114, cast(byte)130, 9, 10, 22, 23, 24, 25, 26, 37, 38, 39, 40, 41, 42, 52, 53,
        54, 55, 56, 57, 58, 67, 68, 69, 70, 71, 72, 73, 74, 83, 84, 85, 86, 87,
        88, 89, 90, 99, 100, 101, 102, 103, 104, 105, 106, 115, 116, 117, 118,
        119, 120, 121, 122, cast(byte)131, cast(byte)132, cast(byte)133, cast(byte)134, cast(byte)135, cast(byte)136, cast(byte)137, cast(byte)138, cast(byte)146, cast(byte)147, cast(byte)148,
        cast(byte)149, cast(byte)150, cast(byte)151, cast(byte)152, cast(byte)153, cast(byte)154, cast(byte)162, cast(byte)163, cast(byte)164, cast(byte)165, cast(byte)166, cast(byte)167, cast(byte)168, cast(byte)169, cast(byte)170,
        cast(byte)178, cast(byte)179, cast(byte)180, cast(byte)181, cast(byte)182, cast(byte)183, cast(byte)184, cast(byte)185, cast(byte)186, cast(byte)194, cast(byte)195, cast(byte)196, cast(byte)197, cast(byte)198, cast(byte)199,
        cast(byte)200, cast(byte)201, cast(byte)202, cast(byte)210, cast(byte)211, cast(byte)212, cast(byte)213, cast(byte)214, cast(byte)215, cast(byte)216, cast(byte)217, cast(byte)218, cast(byte)225, cast(byte)226, cast(byte)227,
        cast(byte)228, cast(byte)229, cast(byte)230, cast(byte)231, cast(byte)232, cast(byte)233, cast(byte)234, cast(byte)241, cast(byte)242, cast(byte)243, cast(byte)244, cast(byte)245, cast(byte)246, cast(byte)247, cast(byte)248,
        cast(byte)249, cast(byte)250
    ];
    static byte[] ACChrominanceTable = [
        cast(byte)255, cast(byte)196, 0, cast(byte)181, 17, 0, 2, 1, 2, 4, 4, 3, 4, 7, 5, 4, 4, 0,
        1, 2, 119, 0, 1, 2, 3, 17, 4, 5, 33, 49, 6, 18, 65, 81, 7, 97, 113, 19, 34,
        50, cast(byte)129, 8, 20, 66, cast(byte)145, cast(byte)161, cast(byte)177, cast(byte)193, 9, 35,
        51, 82, cast(byte)240, 21, 98, 114, cast(byte)209, 10, 22, 36, 52, cast(byte)225, 37,
        cast(byte)241, 23, 24, 25, 26, 38, 39, 40, 41, 42, 53, 54, 55, 56, 57, 58, 67,
        68, 69, 70, 71, 72, 73, 74, 83, 84, 85, 86, 87, 88, 89, 90, 99, 100, 101, 102,
        103, 104, 105, 106, 115, 116, 117, 118, 119, 120, 121, 122, cast(byte)130,
        cast(byte)131, cast(byte)132, cast(byte)133, cast(byte)134, cast(byte)135, cast(byte)136, cast(byte)137,
        cast(byte)138, cast(byte)146, cast(byte)147, cast(byte)148, cast(byte)149, cast(byte)150, cast(byte)151,
        cast(byte)152, cast(byte)153, cast(byte)154, cast(byte)162, cast(byte)163, cast(byte)164, cast(byte)165,
        cast(byte)166, cast(byte)167, cast(byte)168, cast(byte)169, cast(byte)170, cast(byte)178, cast(byte)179,
        cast(byte)180, cast(byte)181, cast(byte)182, cast(byte)183, cast(byte)184, cast(byte)185, cast(byte)186,
        cast(byte)194, cast(byte)195, cast(byte)196, cast(byte)197, cast(byte)198, cast(byte)199, cast(byte)200,
        cast(byte)201, cast(byte)202, cast(byte)210, cast(byte)211, cast(byte)212, cast(byte)213, cast(byte)214,
        cast(byte)215, cast(byte)216, cast(byte)217, cast(byte)218, cast(byte)226, cast(byte)227, cast(byte)228,
        cast(byte)229, cast(byte)230, cast(byte)231, cast(byte)232, cast(byte)233, cast(byte)234, cast(byte)242,
        cast(byte)243, cast(byte)244, cast(byte)245, cast(byte)246, cast(byte)247, cast(byte)248, cast(byte)249,
        cast(byte)250
    ];

public this(byte[] reference) {
    super(reference);
}

public this(LEDataInputStream byteStream) {
    super(byteStream);
    initialize();
}

public JPEGHuffmanTable[] getAllTables() {
    return allTables;
}

public static JPEGHuffmanTable getDefaultACChrominanceTable() {
    JPEGHuffmanTable result = new JPEGHuffmanTable(ACChrominanceTable);
    result.initialize();
    return result;
}

public static JPEGHuffmanTable getDefaultACLuminanceTable() {
    JPEGHuffmanTable result = new JPEGHuffmanTable(ACLuminanceTable);
    result.initialize();
    return result;
}

public static JPEGHuffmanTable getDefaultDCChrominanceTable() {
    JPEGHuffmanTable result = new JPEGHuffmanTable(DCChrominanceTable);
    result.initialize();
    return result;
}

public static JPEGHuffmanTable getDefaultDCLuminanceTable() {
    JPEGHuffmanTable result = new JPEGHuffmanTable(DCLuminanceTable);
    result.initialize();
    return result;
}

public int[] getDhMaxCodes() {
    return dhMaxCodes;
}

public int[] getDhMinCodes() {
    return dhMinCodes;
}

public int[] getDhValPtrs() {
    return dhValPtrs;
}

public int[] getDhValues() {
    return dhValues;
}

public int getTableClass() {
    return tableClass;
}

public int getTableIdentifier() {
    return tableIdentifier;
}

void initialize() {
    int totalLength = getSegmentLength() - 2;
    int ofs = 4;
    int[] bits = new int[16];
    JPEGHuffmanTable[] huffTables = new JPEGHuffmanTable[8]; // maximum is 4 AC + 4 DC
    int huffTableCount = 0;
    while (totalLength > 0) {
        int tc = (reference[ofs] & 0xFF) >> 4; // table class: AC (1) or DC (0)
        int tid = reference[ofs] & 0xF; // table id: 0-1 baseline, 0-3 prog/ext
        ofs++;

        /* Read the 16 count bytes and add them together to get the table size. */
        int count = 0;
        for (int i = 0; i < bits.length; i++) {
            int bCount = reference[ofs + i] & 0xFF;
            bits[i] = bCount;
            count += bCount;
        }
        ofs += 16;
        totalLength -= 17;

        /* Read the table. */
        int[] huffVals = new int[count];
        for (int i = 0; i < count; i++) {
            huffVals[i] = reference[ofs + i] & 0xFF;
        }
        ofs += count;
        totalLength -= count;

        /* Calculate the lengths. */
        int[] huffCodeLengths = new int[50]; // start with 50 and increment as needed
        int huffCodeLengthsIndex = 0;
        for (int i = 0; i < 16; i++) {
            for (int j = 0; j < bits[i]; j++) {
                if (huffCodeLengthsIndex >= huffCodeLengths.length) {
                    int[] newHuffCodeLengths = new int[huffCodeLengths.length + 50];
                    System.arraycopy(huffCodeLengths, 0, newHuffCodeLengths, 0, huffCodeLengths.length);
                    huffCodeLengths = newHuffCodeLengths;
                }
                huffCodeLengths[huffCodeLengthsIndex] = i + 1;
                huffCodeLengthsIndex++;
            }
        }

        /* Truncate huffCodeLengths to the correct size. */
        if (huffCodeLengthsIndex < huffCodeLengths.length) {
            int[] newHuffCodeLengths = new int[huffCodeLengthsIndex];
            System.arraycopy(huffCodeLengths, 0, newHuffCodeLengths, 0, huffCodeLengthsIndex);
            huffCodeLengths = newHuffCodeLengths;
        }

        /* Calculate the Huffman codes. */
        int[] huffCodes = new int[50]; // start with 50 and increment as needed
        int huffCodesIndex = 0;
        int k = 1;
        int code = 0;
        int si = huffCodeLengths[0];
        int p = 0;
        while (p < huffCodeLengthsIndex) {
            while ((p < huffCodeLengthsIndex) && (huffCodeLengths[p] is si)) {
                if (huffCodesIndex >= huffCodes.length) {
                    int[] newHuffCodes = new int[huffCodes.length + 50];
                    System.arraycopy(huffCodes, 0, newHuffCodes, 0, huffCodes.length);
                    huffCodes = newHuffCodes;
                }
                huffCodes[huffCodesIndex] = code;
                huffCodesIndex++;
                code++;
                p++;
            }
            code *= 2;
            si++;
        }

        /* Truncate huffCodes to the correct size. */
        if (huffCodesIndex < huffCodes.length) {
            int[] newHuffCodes = new int[huffCodesIndex];
            System.arraycopy(huffCodes, 0, newHuffCodes, 0, huffCodesIndex);
            huffCodes = newHuffCodes;
        }

        /* Calculate the maximum and minimum codes */
        k = 0;
        int[] maxCodes = new int[16];
        int[] minCodes = new int[16];
        int[] valPtrs = new int[16];
        for (int i = 0; i < 16; i++) {
            int bSize = bits[i];
            if (bSize is 0) {
                maxCodes[i] = -1;
            } else {
                valPtrs[i] = k;
                minCodes[i] = huffCodes[k];
                k += bSize;
                maxCodes[i] = huffCodes[k - 1];
            }
        }

        /* Calculate the eHuffman codes and lengths. */
        int[] eHuffCodes = new int[256];
        byte[] eHuffSize = new byte[256];
        for (int i = 0; i < huffCodesIndex; i++) {
            eHuffCodes[huffVals[i]] = huffCodes[i];
            eHuffSize[huffVals[i]] = cast(byte)huffCodeLengths[i];
        }

        /* Create the new JPEGHuffmanTable and add it to the allTables array. */
        JPEGHuffmanTable dhtTable = new JPEGHuffmanTable(reference);
        dhtTable.tableClass = tc;
        dhtTable.tableIdentifier = tid;
        dhtTable.dhValues = huffVals;
        dhtTable.dhMinCodes = minCodes;
        dhtTable.dhMaxCodes = maxCodes;
        dhtTable.dhValPtrs = valPtrs;
        dhtTable.ehCodes = eHuffCodes;
        dhtTable.ehCodeLengths = eHuffSize;
        huffTables[huffTableCount] = dhtTable;
        huffTableCount++;
    }
    allTables = new JPEGHuffmanTable[huffTableCount];
    System.arraycopy(huffTables, 0, allTables, 0, huffTableCount);
}

public override int signature() {
    return JPEGFileFormat.DHT;
}
}
