package com.example;

import org.junit.jupiter.api.Test;
import java.io.ByteArrayOutputStream;
import java.io.PrintStream;
import java.nio.charset.StandardCharsets;
import java.util.List;
import static org.junit.jupiter.api.Assertions.assertEquals;

class MainTest {
    @Test
    void printsExpectedWelcomeAndSequence() {
        PrintStream original = System.out;
        ByteArrayOutputStream captured = new ByteArrayOutputStream();
        try (PrintStream output = new PrintStream(captured, true, StandardCharsets.UTF_8)) {
            System.setOut(output);
            Main.main(new String[0]);
        } finally {
            System.setOut(original);
        }
        assertEquals(List.of("Hello and welcome!", "i = 1", "i = 2",
                "i = 3", "i = 4", "i = 5"),
                captured.toString(StandardCharsets.UTF_8).lines().toList());
    }
}
