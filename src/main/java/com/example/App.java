package com.example;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class App {
    private static final Logger LOG = LogManager.getLogger(App.class);

    public static void main(String[] args) {
        // Учебный пример: пользовательский ввод попадает в лог (вектор Log4Shell при log4j < 2.17)
        String user = args.length > 0 ? args[0] : "guest";
        LOG.info("Hello, {}", user);
    }
}
