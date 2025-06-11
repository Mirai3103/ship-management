package com.ship.management.ssr;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;


@Controller
@RequestMapping("")
public class MainController {
    @GetMapping("")
    public String index(@RequestParam(value = "name", required = false, defaultValue = "World") String name) {
        return "index"; // This will resolve to src/main/resources/templates/index.html
    }
    
    
}
