package com.assessment.platform;

import com.assessment.platform.api.LogicalDocumentGrouper;

import java.nio.file.Path;
import java.util.List;
import java.util.Map;

public class Main {

    public static void main(String[] args) throws Exception {

        List<Map<String,Object>> docs =
                LogicalDocumentGrouper.group(
                        Path.of("C:\\Users\\vishn\\Downloads\\landing.json"));

        System.out.println("\n==================== DOCUMENTS ====================");
        for (int i = 0; i < docs.size(); i++) {
            System.out.println("\n--- Document " + (i + 1) + " ---");
            System.out.println(docs.get(i));
        }
        System.out.println("\n=====================================================\n");
    }
}