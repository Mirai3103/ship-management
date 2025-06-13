package com.ship.management.ssr;

import java.security.Principal;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import jakarta.servlet.http.HttpSession;


@Controller
@RequestMapping("")
public class MainController {
    @GetMapping("")
    public String index() {
        
        return "redirect:/login";
    }

    @GetMapping("/login")
    public String login(Principal principal) {
        if (principal != null) {
            return "redirect:/dashboard";
        }
        return "login";
    }
    
   
    @GetMapping("/dashboard")
    @PreAuthorize("isAuthenticated()")
    public String dashboard() {

        return "dashboard";
    }
    @GetMapping("/ships")
    public String ships() {

        return "ships";
    }
    @GetMapping("/companies")
    public String companies() {
        return "companies";
    }
    @GetMapping("/roles")
    public String roles() {
        return "roles";
    }
 
    @GetMapping("/users")
    public String users() {

        return "users";
    }
    @GetMapping("/reviews-ship")
    public String reviewsShip() {

        return "reviews-ship";
    }
}
